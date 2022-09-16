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
    
    public typealias Task = (TaskCompletable) -> ()
    
    private var taskGroup: [Task] = []
    public var autoStart: Bool = true
    private let taskComplete = TaskComplete()
    private var isStartingTask: Bool = false
    private let bag = DisposeBag()
    private var waitFinished = false
    public var taskInterval: Double = 0
    
    public init() {
        taskComplete.finishSubject.sink { [weak self] in
            guard let self = self else { return }
            self.waitFinished = false
            DispatchQueue.main.asyncAfter(deadline: .now() + self.taskInterval) {
                self._startTask()
            }
        }.dispose(by: bag)
    }
    
    public func appendSyncTask(_ closure: @escaping () -> Void) {
        appendSyncTasks([closure])
    }
    
    public func appendSyncTasks(_ closures:  [() -> Void]) {
        appendAsyncTasks(closures.map { closure in
            { task in
                closure()
                task.finish()
            }
        })
    }
    
    public func appendAsyncTask(_ closure: @escaping Task) {
        appendAsyncTasks([closure])
    }
    
    public func appendAsyncTasks(_ closures: [Task]) {
        taskGroup.append(contentsOf: closures)
        if autoStart {
            startTask()
        }
    }
    
    public func startTask() {
        isStartingTask = true
        _startTask()
    }
    
    private func _startTask() {
        guard let firstTask = taskGroup.first, isStartingTask, !waitFinished else { return }
        waitFinished = true
        taskGroup.removeFirst()
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
