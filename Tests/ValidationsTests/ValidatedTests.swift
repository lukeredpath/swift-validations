import XCTest

@testable import Validations

class ValidatingTests: XCTestCase {
    func testRevalidatesWhenValueChanges() {
        var validatedInt = Validating<Int>(wrappedValue: 0, .isEven)
        XCTAssert(validatedInt.isValid)
        
        validatedInt.wrappedValue = 1
        XCTAssertFalse(validatedInt.isValid)
        
        validatedInt.wrappedValue = 2
        XCTAssert(validatedInt.isValid)
    }

    func testAllowsIndirectAccessToErrors() {
        var validatedInt = Validating<Int>(wrappedValue: 0, .isEven)
        validatedInt.wrappedValue = 1
        
        XCTAssertEqual(["must be even"], validatedInt.errors?.errors)
    }
    
    func testPropertyWrapperUsage() {
        struct ValidatingContainer {
            @Validating(.isGreaterThan(3))
            var intValue: Int = 0
            
            @Validating(.itsLength(.isAtLeast(5)))
            var stringValue: String = ""
            
            @Validating(.its(\.first, .isEqualTo(1)))
            var numbers: [Int] = []
            
            var isValid: Bool {
                zip(self.$intValue,
                    self.$stringValue).isValid
            }
        }
        
        var container = ValidatingContainer(numbers: [])
        XCTAssertFalse(container.isValid)
        
        container.intValue = 2
        XCTAssertFalse(container.isValid)
        
        container.stringValue = "foo"
        XCTAssertFalse(container.isValid)
        
        container.stringValue = "foobar"
        container.intValue = 4
        XCTAssert(container.isValid)
    }
}
