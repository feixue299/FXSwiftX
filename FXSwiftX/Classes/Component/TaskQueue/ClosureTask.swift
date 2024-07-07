//
//  ClosureTask.swift
//  
//
//  Created by aria on 2022/12/16.
//

import Foundation
import Combine

@available(macOS 10.15, *)
@available(iOS 13.0, *)
class ClosureTask: TaskProtocol {
    var taskCompletable: TaskCompletable?
    
    enum TaskType {
        case closure(TaskQueue.Task)
        case asyncClosure(TaskQueue.AsyncTask)
    }
    
    let taskType: TaskType
    
    init(closure: @escaping TaskQueue.Task) {
        self.taskType = .closure(closure)
    }
    
    init(asyncClosure: @escaping TaskQueue.AsyncTask) {
        self.taskType = .asyncClosure(asyncClosure)
    }
    
    func start() {
        guard let taskCompletable else { return }
        switch taskType {
        case .closure(let task):
            task(taskCompletable)
        case .asyncClosure(let asyncTask):
            Task {
                defer { taskCompletable.finish() }
                
                try await asyncTask()
            }
        }
    }
    
    func cancel() {
        taskCompletable?.cancel(task: self)
    }
    
}

@available(macOS 10.15, *)
@available(iOS 13.0, *)
public extension TaskQueue {
    
    typealias Task = (TaskCompletable) -> ()
    typealias AsyncTask = () async throws -> Void
    
    @discardableResult
    func appendSyncTask(priority: PriorityType = .user, _ closure: @escaping () -> Void)  -> Cancellable {
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
        appendAsyncTasks(priority: priority, [closure]).first!
    }
    
    @discardableResult
    func appendAsyncTasks(priority: PriorityType = .user, _ closures: [Task]) -> [Cancellable] {
        let tasks = closures.map { ClosureTask(closure: $0) }
        appendTasks(tasks: tasks)
        return tasks
    }
    
    @discardableResult
    func appendConcurrencyAsyncTask(priority: PriorityType = .user, _ closure: @escaping AsyncTask) -> Cancellable {
        let task = ClosureTask(asyncClosure: closure)
        appendTask(task: task, priority: priority)
        return task
    }
    
}
