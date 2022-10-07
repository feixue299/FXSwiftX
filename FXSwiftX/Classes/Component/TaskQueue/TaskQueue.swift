//
//  TaskQueue.swift
//  FXSwiftX
//
//  Created by aria on 2022/9/15.
//

import Foundation
import Combine

public protocol TaskCompletable {
    func finish()
}

@available(iOS 13.0, *)
public class TaskQueue {
    
    public enum TaskInterval {
        case interval(Double)
        case randomRange(Range<Double>)
    }
    
    public typealias Task = (TaskCompletable) -> ()
    
    private var taskGroup: [Task] = []
    private var laterTaskGroup: [Task] = []
    public var autoStart: Bool = true
    private let taskComplete = TaskComplete()
    private var isStartingTask: Bool = false
    private let bag = DisposeBag()
    private var waitFinished = false
    public var taskInterval: TaskInterval = .interval(0)
    
    public init() {
        taskComplete.finishSubject.sink { [weak self] in
            guard let self = self else { return }
            let delay: Double
            switch self.taskInterval {
            case .interval(let value):
                delay = value
            case .randomRange(let range):
                delay = range.random
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.waitFinished = false
                self._startTask()
            }
        }.dispose(by: bag)
    }
    
    public func appendSyncTask(laterTask: Bool = false, _ closure: @escaping () -> Void) {
        appendSyncTasks(laterTask: laterTask, [closure])
    }
    
    public func appendSyncTasks(laterTask: Bool = false, _ closures:  [() -> Void]) {
        appendAsyncTasks(laterTask: laterTask, closures.map { closure in
            { task in
                closure()
                task.finish()
            }
        })
    }
    
    public func appendAsyncTask(laterTask: Bool = false, _ closure: @escaping Task) {
        appendAsyncTasks(laterTask: laterTask, [closure])
    }
    
    public func appendAsyncTasks(laterTask: Bool = false, _ closures: [Task]) {
        if laterTask {
            laterTaskGroup.append(contentsOf: closures)
        } else {
            taskGroup.append(contentsOf: closures)
        }
        if autoStart {
            startTask()
        }
    }
    
    public func startTask() {
        isStartingTask = true
        _startTask()
    }
    
    private func _startTask() {
        guard isStartingTask, !waitFinished else { return }
        let firstTask: Task?
        if !taskGroup.isEmpty {
            firstTask = taskGroup.first
            taskGroup.removeFirst()
        } else if !laterTaskGroup.isEmpty {
            firstTask = laterTaskGroup.first
            laterTaskGroup.removeFirst()
        } else {
            firstTask = nil
        }
        guard let firstTask else { return }
        waitFinished = true
        firstTask(taskComplete)
    }
    
    public func stopTask() {
        isStartingTask = false
    }
    
}

@available(iOS 13.0, *)
private class TaskComplete: TaskCompletable {
    let finishSubject = PassthroughSubject<Void, Never>()
    
    func finish() {
        finishSubject.send()
    }
}
