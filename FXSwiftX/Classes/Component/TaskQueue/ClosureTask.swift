//
//  ClosureTask.swift
//  
//
//  Created by aria on 2022/12/16.
//

import Foundation
import Combine

@available(iOS 13.0, *)
class ClosureTask: TaskProtocol {
    var taskCompletable: TaskCompletable?
    
    let closure: TaskQueue.Task
    
    init(closure: @escaping TaskQueue.Task) {
        self.closure = closure
    }
    
    func start() {
        guard let taskCompletable else { return }
        closure(taskCompletable)
    }
    
    func cancel() {
        taskCompletable?.cancel(task: self)
    }
    
}

@available(iOS 13.0, *)
public extension TaskQueue {
    
    typealias Task = (TaskCompletable) -> ()
    
    @discardableResult
    func appendSyncTask(priority: PriorityType = .user, _ closure: @escaping () -> Void) -> Cancellable {
        appendAsyncTask(priority: priority) { task in
            closure()
            task.finish()
        }
    }
    
    @discardableResult
    func appendSyncTasks(priority: PriorityType = .user, _ closures:  [() -> Void]) -> [Cancellable] {
        closures.map { appendSyncTask(priority: priority, $0) }
    }
    
    @discardableResult
    func appendAsyncTask(priority: PriorityType = .user, _ closure: @escaping Task) -> Cancellable {
        let task = ClosureTask(closure: closure)
        appendTask(task: task, priority: priority)
        return task
    }
    
    @discardableResult
    func appendAsyncTasks(priority: PriorityType = .user, _ closures: [Task]) -> [Cancellable] {
        closures.map { appendAsyncTask(priority: priority, $0) }
    }
}
