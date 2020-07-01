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
            
            // There seems to be a bug or undefined behaviour when using
            // a keypath as a function inside a property-wrapper call on Swift 5.2
            // https://forums.swift.org/t/keypath-as-function-inside-property-wrapper-doesnt-compile-in-5-2-fine-in-5-3/38074
            
            #if compiler(>=5.3)
            @Validating(.its(\.first, .isEqualTo(1)))
            var numbers: [Int] = []
            #else
            @Validating(.its({ $0.first }, .isEqualTo(1)))
            var numbers: [Int] = []
            #endif
            
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
