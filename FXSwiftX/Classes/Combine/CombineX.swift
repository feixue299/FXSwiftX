//
//  CombineX.swift
//  FXSwiftX
//
//  Created by aria on 2022/6/8.
//

import Foundation
import Combine

// MARK: - Disposable

/// Represents a disposable resource.
public protocol Disposable {
    /// Dispose resource.
    func dispose()
}

extension Disposable {
    /// Adds `self` to `bag`
    ///
    /// - parameter bag: `DisposeBag` to add `self` to.
    public func disposed(by bag: DisposeBag) {
        bag.insert(self)
    }
}

extension NSRecursiveLock {
    @inline(__always)
    final func performLocked<T>(_ action: () -> T) -> T {
        lock(); defer { self.unlock() }
        return action()
    }
}

// MARK: - DisposeBag

public final class DisposeBag {
    
    // MARK: Lifecycle
    
    public init() { }

    deinit {
        self.dispose()
    }

    // MARK: Public

    /// Adds `disposable` to be disposed when dispose bag is being deinited.
    ///
    /// - parameter disposable: Disposable to add.
    public func insert(_ disposable: Disposable) {
        _insert(disposable)?.dispose()
    }

    public func insert(_ value: Any) {
        cancelGroup.append(value)
    }
    
    // MARK: Private

    private var lock = NSRecursiveLock()
    
    // state
    private var cancelGroup: [Any] = []
    private var disposables = [Disposable]()
    private var isDisposed = false

    
    private func _insert(_ disposable: Disposable) -> Disposable? {
        lock.performLocked {
            if self.isDisposed {
                return disposable
            }

            self.disposables.append(disposable)

            return nil
        }
    }

    /// This is internal on purpose, take a look at `CompositeDisposable` instead.
    private func dispose() {
        let oldDisposables = _dispose()

        for disposable in oldDisposables {
            disposable.dispose()
        }
    }

    private func _dispose() -> [Disposable] {
        lock.performLocked {
            let disposables = self.disposables
            
            self.disposables.removeAll(keepingCapacity: false)
            self.isDisposed = true
            
            return disposables
        }
    }
}

// MARK: - Dispose

private class Dispose: Disposable {

    // MARK: Lifecycle

    public init(dispose: @escaping () -> Void) {
        _dispose = dispose
    }
    
    deinit {
        dispose()
    }

    // MARK: Public

    public func dispose() {
        lock.performLocked {
            if hasDisposed { return }
            hasDisposed = true
            _dispose()
        }
    }

    // MARK: Private

    private let _dispose: () -> Void
    private var hasDisposed = false
    private let lock = NSRecursiveLock()
}

// MARK: - Observable

@propertyWrapper
public class Observable<T> {

    // MARK: Lifecycle

    public init(wrappedValue: T) {
        value = wrappedValue
    }

    // MARK: Public

    public typealias Observer = (T) -> Void

    
    public var projectedValue: Observable<T> { return self }
    
    public var wrappedValue: T {
        get {
            return lock.performLocked { value }
        }
        set {
            lock.performLocked {
                value = newValue
                observerMap.values.forEach { $0(newValue) }
            }
        }
    }

    // MARK: Private

    private typealias Token = UUID

    
    private var value: T
    private var observerMap: [Token: Observer] = [:]
    private let lock = NSRecursiveLock()
}

extension Observable {
    public func observe(_ observer: @escaping Observer) -> Disposable {
        lock.lock(); defer { lock.unlock() }
        let token = Token()
        observerMap[token] = observer
        return Dispose { [weak self] in
            self?.lock.lock(); defer { self?.lock.unlock() }
            // 当Dispose被释放时移除observer
            self?.observerMap[token] = nil
        }
    }
}

extension Observable {
    // 值类型KeyPath绑定
    public func bind<Target>(to target: Target, at keypath: ReferenceWritableKeyPath<Target, T>) -> Disposable {
        return observe { target[keyPath: keypath] = $0 }
    }
    
    public func bind<Target>(to target: Target, at keypath: ReferenceWritableKeyPath<Target, T?>) -> Disposable {
        return observe { target[keyPath: keypath] = $0 }
    }
    
    public func bind<Target>(to target: Target?, at keypath: ReferenceWritableKeyPath<Target, T>) -> Disposable {
        return observe { target?[keyPath: keypath] = $0 }
    }
    
    public func bind<Target>(to target: Target?, at keypath: ReferenceWritableKeyPath<Target, T?>) -> Disposable {
        return observe { target?[keyPath: keypath] = $0 }
    }
    
    // 引用类型KeyPath绑定
    public func bind<Target: AnyObject>(to target: Target, at keypath: ReferenceWritableKeyPath<Target, T>) -> Disposable {
        return observe { [weak target] newValue in
            target?[keyPath: keypath] = newValue
        }
    }
    
    public func bind<Target: AnyObject>(to target: Target, at keypath: ReferenceWritableKeyPath<Target, T?>) -> Disposable {
        return observe { [weak target] newValue in
            target?[keyPath: keypath] = newValue
        }
    }
    
    public func bind<Target: AnyObject>(to target: Target?, at keypath: ReferenceWritableKeyPath<Target, T>) -> Disposable {
        return observe { [weak target] newValue in
            target?[keyPath: keypath] = newValue
        }
    }
    
    public func bind<Target: AnyObject>(to target: Target?, at keypath: ReferenceWritableKeyPath<Target, T?>) -> Disposable {
        return observe { [weak target] newValue in
            target?[keyPath: keypath] = newValue
        }
    }
}
