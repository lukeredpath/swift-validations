import XCTest

@testable import Validations

final class BoolTests: XCTestCase {
    func testIsTrue() {
        assertValid(.isTrue, given: true)
        assertNotValid(.isTrue, given: false)
    }
    
    func testIsFalse() {
        assertValid(.isFalse, given: false)
        assertNotValid(.isFalse, given: true)
    }
}
