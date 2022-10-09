//: [Previous](@previous)

import Foundation

// MARK: - Basics of Thread API

// class that can be subclassed
// Thread is built over lower POSIX threads or pthreads

func threadBasics() {
    Thread.detachNewThread {
        Thread.sleep(forTimeInterval: 1)
        
        // does not print since async (unless main thread was frozen like done at the bottom)
        print(Thread.current)
    }
    
    // unordered, no determinism over detached threads
    Thread.detachNewThread {
        print("2", Thread.current)
    }
    
    Thread.detachNewThread {
        print("3", Thread.current)
    }
    
    Thread.detachNewThread {
        print("4", Thread.current)
    }
    
    Thread.detachNewThread {
        print("5", Thread.current)
    }
    
    print(Thread.current)
    
    // freezes main thread, which will make the print on the detached
    // to be printed
    Thread.sleep(forTimeInterval: 1.1)
}

// MARK: - Priority and cancellation

func threadPriorityAndCancellation() {
    let thread = Thread {
        let start = Date()
        defer { print("Finished in", Date().timeIntervalSince(start)) }

        // cancellation state has to be manually checked
        guard thread.isCancelled == false else {
            print("Cancelled before interval")

            return
        }

        print("thread", Thread.current)

        // will wait the full time, even if cancelled
        Thread.sleep(forTimeInterval: 1)

        // cancellation state has to be manually checked
        guard thread.isCancelled == false else {
            print("Cancelled after interval")

            return
        }

        print("thread prop 2", Thread.current)
    }

    // 0 to 1 (hidden definition of how threads get prioritized based on that)
    thread.threadPriority = 0.75
    thread.start()

    // cancellation does not work as expected.. sleeping less then inside the thread context
    // still makes the thread block to fully perform its work without being cancelled
    Thread.sleep(forTimeInterval: 0.01)
    thread.cancel()

    // freezes main thread, which will make the print on the detached
    // to be printed
    Thread.sleep(forTimeInterval: 1.1)
}

// MARK: - Threads dictionaries



//: [Next](@next)
