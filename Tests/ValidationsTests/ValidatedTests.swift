import XCTest

@testable import Validations

class ValidatingTests: XCTestCase {
    func testRevalidatesWhenValueChanges() {
        var validatedInt = Validating<Int>(initialValue: 0, validator: .even)
        XCTAssert(validatedInt.isValid)
        
        validatedInt.value = 1
        XCTAssertFalse(validatedInt.isValid)
        
        validatedInt.value = 2
        XCTAssert(validatedInt.isValid)
    }

    func testAllowsIndirectAccessToErrors() {
        var validatedInt = Validating<Int>(initialValue: 0, validator: .even)
        validatedInt.value = 1
        
        XCTAssertEqual("must be even", validatedInt.errors!.first)
    }
}
