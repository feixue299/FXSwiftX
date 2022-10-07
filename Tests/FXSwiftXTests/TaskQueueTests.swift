//
//  TaskQueueTests.swift
//  
//
//  Created by aria on 2022/9/15.
//

import XCTest
@testable import FXSwiftX

@available(iOS 13.0, *)
class TaskQueueTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testARC() {
        testTaskQueueSync()
    }

    func testTaskQueueSync() {
        let expectation = expectation(description: "未完成")
        var initCount = 3
        let taskQueue = TaskQueue()
        taskQueue.appendSyncTasks([
            {
                print("1111")
                initCount *= 5
            },
            {
                print("2222")
                initCount -= 2
            },
            {
                print("3333")
                initCount /= 3
            },
            {
                print("4444")
                initCount += 4
            },
            {
                print("5555")
                initCount *= 2
                expectation.fulfill()
            },
        ])
        waitForExpectations(timeout: 10)
        XCTAssert(initCount == ((3 * 5 - 2) / 3 + 4) * 2)
    }

    func testTaskQueueAsync() {
        let expectation = expectation(description: "未完成")
        var initCount = 3
        let taskQueue = TaskQueue()
        taskQueue.appendAsyncTasks([
            { task in
                print("0000:\(Date().timeIntervalSince1970)")
                task.finish()
            },
            { task in
                DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                    print("1111:\(Date().timeIntervalSince1970)")
                    initCount *= 5
                    task.finish()
                }
            },
            { task in
                print("2222:\(Date().timeIntervalSince1970)")
                initCount -= 2
                task.finish()
            },
            { task in
                DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
                    print("3333:\(Date().timeIntervalSince1970)")
                    initCount /= 3
                    task.finish()
                }
            },
            { task in
                print("4444:\(Date().timeIntervalSince1970)")
                initCount += 4
                task.finish()
            },
            { task in
                DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                    print("5555:\(Date().timeIntervalSince1970)")
                    initCount *= 2
                    task.finish()
                    expectation.fulfill()
                }
            },
        ])
        waitForExpectations(timeout: 10)
        XCTAssert(initCount == ((3 * 5 - 2) / 3 + 4) * 2)
    }
    
    func testSegmentTaskQueueAsync() {
        let expectation = expectation(description: "未完成")
        var sign = 3
        let taskQueue = TaskQueue()
        taskQueue.taskInterval = .randomRange(0.1..<3)
        taskQueue.appendAsyncTask { task in
            print("0000:\(Date().timeIntervalSince1970)")
            task.finish()
        }
        
        taskQueue.appendAsyncTask { task in
            DispatchQueue.global().asyncAfter(deadline: .now()) {
                print("1111:\(Date().timeIntervalSince1970)")
                sign *= 5
                task.finish()
            }
        }
        taskQueue.appendAsyncTask { task in
            print("2222:\(Date().timeIntervalSince1970)")
            sign -= 2
            task.finish()
        }
        taskQueue.appendAsyncTask { task in
            print("3333:\(Date().timeIntervalSince1970)")
            sign /= 3
            task.finish()
        }
        taskQueue.appendAsyncTask { task in
            print("4444:\(Date().timeIntervalSince1970)")
            sign += 4
            task.finish()
        }
        taskQueue.appendAsyncTask { task in
            DispatchQueue.global().asyncAfter(deadline: .now()) {
                print("5555:\(Date().timeIntervalSince1970), :\(Thread.callStackSymbols)")
                sign *= 2
                task.finish()
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 20)
        XCTAssert(sign == ((3 * 5 - 2) / 3 + 4) * 2)
    }
    
    func testLaterSegmentTaskQueueAsync() {
        let expectation = expectation(description: "未完成")
        var sign = 3
        let taskQueue = TaskQueue()
        taskQueue.taskInterval = .randomRange(0.1..<3)
        
        taskQueue.appendAsyncTask { task in
            print("0000:\(Date().timeIntervalSince1970)")
            task.finish()
        }
        
        taskQueue.appendAsyncTask(laterTask: true) { task in
            DispatchQueue.global().asyncAfter(deadline: .now()) {
                print("5555:\(Date().timeIntervalSince1970)")
                sign *= 2
                task.finish()
                expectation.fulfill()
            }
        }
        
        taskQueue.appendAsyncTask { task in
            DispatchQueue.global().asyncAfter(deadline: .now()) {
                print("1111:\(Date().timeIntervalSince1970)")
                sign *= 5
                task.finish()
            }
        }
        taskQueue.appendAsyncTask { task in
            print("2222:\(Date().timeIntervalSince1970)")
            sign -= 2
            task.finish()
        }
        taskQueue.appendAsyncTask { task in
            print("3333:\(Date().timeIntervalSince1970)")
            sign /= 3
            task.finish()
        }
        taskQueue.appendAsyncTask { task in
            print("4444:\(Date().timeIntervalSince1970)")
            sign += 4
            task.finish()
        }
        waitForExpectations(timeout: 20)
        print("sign:\(sign), ((3 * 5 - 2) / 3 + 4) * 2:\(((3 * 5 - 2) / 3 + 4) * 2)")
        XCTAssert(sign == ((3 * 5 - 2) / 3 + 4) * 2)
    }

}
