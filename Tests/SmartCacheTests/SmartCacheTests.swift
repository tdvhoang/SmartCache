import XCTest
@testable import SmartCache

struct A: SmartInitializable {
    init() { }
}

struct B {
    
}

extension B: StaticSmartInitializable {
    static func getInstance() -> B {
        return B()
    }
}

final class SmartCacheTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        smartCache.printDebugLog = true
        
        // Passed
        _ = smartCache.resolve(A.self) // A conform to SmartInitializable
        _ = smartCache.resolve(B.self)// B conform to StaticSmartInitializable
        _ = smartCache.resolve(Int.self, factory: { return 1 }) // has factory callback
        
        // Crashed
        let doubleIntance = smartCache.resolve(Double.self) // No factory
        XCTAssertNil(doubleIntance)
    }
}
