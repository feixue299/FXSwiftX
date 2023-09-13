//
//  TaskQueue.swift
//  FXSwiftX
//
//  Created by aria on 2022/9/15.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public protocol TaskCompletableContainer {
    var taskCompletable: TaskCompletable? { set get }
}

@available(iOS 13.0, *)
public protocol TaskProtocol: AnyObject, TaskCompletableContainer, Cancellable {
    func start()
    func cancel()
}

@available(iOS 13.0, *)
public protocol TaskCompletable {
    func finish()
    func cancel(task: TaskProtocol)
}

@available(iOS 13.0, *)
public class TaskQueue {
    
    public enum PriorityType {
        case user
        case background
    }
    
    public enum TaskInterval {
        case interval(Double)
        case randomRange(Range<Double>)
        
        var delay: Double {
            let delay: Double
            switch self {
            case .interval(let value):
                delay = value
            case .randomRange(let range):
                delay = range.random
            }
            return delay
        }
    }
    
    class TaskContainer {
        var task: TaskProtocol
        let priority: PriorityType
        
        init(task: TaskProtocol, priority: PriorityType) {
            self.task = task
            self.priority = priority
        }
    }
    
    public var autoStart: Bool = true
    public var taskInterval: TaskInterval = .interval(0)
    public var laterTaskInterval: TaskInterval = .interval(0)
    
    private var taskGroup: [TaskContainer] = []
    private let taskComplete = TaskComplete()
    private var isStartingTask: Bool = false
    private let bag = DisposeBag()
    public private(set) var waitFinished = false
    private var currentTask: TaskContainer?
    private var timer: Timer?
    private var nextIsNormalTask: Bool {
        return taskGroup.contains(where: { $0.priority == .user })
    }
    private let lock = NSLock()
    
    public init() {
        taskComplete.finishSubject.receive(on: DispatchQueue.main).sink { [weak self] in
            guard let self = self else { return }
            self.currentTask = nil
            self.waitFinished = false
            self.startTimer()
        }.dispose(by: bag)
        
        taskComplete.cancelSubject.sink { [weak self] task in
            guard let self else { return }
            if let index = self.taskGroup.firstIndex(where: { $0 === task }) {
                self.taskGroup.remove(at: index)
            }
        }.dispose(by: bag)
    }
    
    public func appendTask(task: TaskProtocol, priority: PriorityType = .user) {
        appendTasks(tasks: [task], priority: priority)
    }
    
    public func appendTasks(tasks: [TaskProtocol], priority: PriorityType = .user) {
        lock.withLock {
            taskGroup.append(contentsOf: tasks.map({ TaskContainer(task: $0, priority: priority) }))
        }
        if autoStart && (isStartingTask == false || waitFinished == false) {
            startTask()
        }
    }
    
    public func startTask() {
        isStartingTask = true
        _startTask()
        
    }
    
    private func _startTask() {
        lock.withLock {
            cancelTimer()
            guard isStartingTask, !waitFinished else { return }
            let firstTask: TaskContainer?
            if let index = taskGroup.firstIndex(where: { $0.priority == .user }) {
                let task = taskGroup.remove(at: index)
                firstTask = task
            } else if let index = taskGroup.firstIndex(where: { $0.priority == .background }) {
                let task = taskGroup.remove(at: index)
                firstTask = task
            } else {
                firstTask = nil
            }
            guard var firstTask else { return }
            currentTask = firstTask
            waitFinished = true
            DispatchQueue.global().async {
                firstTask.task.taskCompletable = self.taskComplete
                firstTask.task.start()
            }
        }
    }
    
    public func stopTask() {
        isStartingTask = false
    }
    
    private func startTimer() {
        let delay = nextIsNormalTask ? taskInterval.delay : laterTaskInterval.delay
        if delay == 0 {
            /*
             重新开一个线程，避免死锁
             */
            DispatchQueue.global().async {
                self._startTask()
            }
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { [weak self] _ in
                self?._startTask()
            })
        }
    }
    
    private func cancelTimer() {
        timer?.fireDate = .distantFuture
        timer?.invalidate()
        timer = nil
    }
    
}

@available(iOS 13.0, *)
private class TaskComplete: TaskCompletable {

    let finishSubject = PassthroughSubject<Void, Never>()
    let cancelSubject = PassthroughSubject<TaskProtocol, Never>()
    
    func cancel(task: TaskProtocol) {
        cancelSubject.send(task)
    }
    
    func finish() {
        finishSubject.send()
    }
    
}
