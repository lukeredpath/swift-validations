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
        
        XCTAssertEqual(["must be even"], Array(validatedInt.errors!))
    }
    
    func testPropertyWrapperUsage() {
        struct ValidatingContainer {
            @Validating(
                .isGreaterThan(3),
                .isLessThan(10)
            )
            var intValue: Int = 0
            
            @Validating(
                .itsLength(.isAtLeast(5))
            )
            var stringValue: String = ""
            
            @Validating(.its(\.first, .isEqualTo(1)))
            var numbers: [Int] = []
            
            var isValid: Bool {
                zip($intValue,
                    $stringValue,
                    $numbers).isValid
            }
        }
        
        var container = ValidatingContainer()
        XCTAssertFalse(container.isValid)
        
        container.intValue = 2
        container.numbers = [2, 3]
        XCTAssertFalse(container.isValid)
        
        container.stringValue = "foo"
        XCTAssertFalse(container.isValid)
        
        container.stringValue = "foobar"
        container.intValue = 11
        container.numbers = [1, 2, 3]
        XCTAssertFalse(container.isValid)
        
        container.intValue = 9
        XCTAssert(container.isValid)
    }
}
