//
//  ClosureTask.swift
//  
//
//  Created by aria on 2022/12/16.
//

import Foundation

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
  
}

@available(iOS 13.0, *)
public extension TaskQueue {
  
  typealias Task = (TaskCompletable) -> ()
  
  func appendSyncTask(laterTask: Bool = false, _ closure: @escaping () -> Void) {
    appendSyncTasks(laterTask: laterTask, [closure])
  }
  
  func appendSyncTasks(laterTask: Bool = false, _ closures:  [() -> Void]) {
    appendAsyncTasks(laterTask: laterTask, closures.map { closure in
      { task in
        closure()
        task.finish()
      }
    })
  }
  
  func appendAsyncTask(laterTask: Bool = false, _ closure: @escaping Task) {
    appendAsyncTasks(laterTask: laterTask, [closure])
  }
  
  func appendAsyncTasks(laterTask: Bool = false, _ closures: [Task]) {
    appendTasks(tasks: closures.map(ClosureTask.init))
  }
}
