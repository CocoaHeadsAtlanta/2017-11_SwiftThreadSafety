//: Playground - noun: a place where people can play

import UIKit

/* Blocking lock with serial queue */
private var privateData = Data()
private var queue = DispatchQueue(label: "lockQ")
var data: Data {
    set { queue.sync { privateData = newValue} }
    get { return queue.sync { return privateData } }
}

/* RW lock with concurrent queue */
private var privateData2 = Data()
private var queue2 = DispatchQueue(label: "lockQ", qos: .default, attributes: .concurrent)
var data2: Data {
    set { queue.sync(flags: .barrier) { privateData2 = newValue} }
    get { return queue.sync { return privateData2 } }
}

/* RW lock with generic type and concurrent queue */
class Locked<Content> {
    
    private var content: Content
    private var q = DispatchQueue(label: "lockQ", qos: .default, attributes: .concurrent)
    
    init(_ content: Content) {
        self.content = content
    }
    
    func withReadSafety<Return>(_ workItem: (Content) throws -> Return) rethrows -> Return {
        return try q.sync {
            return try workItem(content)
        }
    }
    
    func withWriteSafety<Return>(_ workItem: (inout Content) throws -> Return) rethrows -> Return {
        return try q.sync(flags: .barrier) {
            return try workItem(&content)
        }
    }
}

// Test the Locked type
let testData = Locked(Data())
testData.withWriteSafety { (data) -> Void in
    let newData = "Mikey".data(using: .utf8)!
    data.append(newData)
}

// Make sure we're still running
print(arc4random())
