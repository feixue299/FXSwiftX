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
    
    func appendSyncTask(laterTask: Bool = false, _ closure: @escaping () -> Void) -> Cancellable {
        appendAsyncTask(laterTask: laterTask) { task in
            closure()
            task.finish()
        }
    }
    
    func appendSyncTasks(laterTask: Bool = false, _ closures:  [() -> Void]) -> [Cancellable] {
        closures.map { appendSyncTask(laterTask: laterTask, $0) }
    }
    
    func appendAsyncTask(laterTask: Bool = false, _ closure: @escaping Task) -> Cancellable {
        let task = ClosureTask(closure: closure)
        appendTask(task: task, laterTask: laterTask)
        return task
    }
    
    func appendAsyncTasks(laterTask: Bool = false, _ closures: [Task]) -> [Cancellable] {
        closures.map { appendAsyncTask(laterTask: laterTask, $0) }
    }
}
