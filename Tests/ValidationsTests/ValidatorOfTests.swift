import XCTest
import Validated

@testable import Validations

final class ValidatorOfTests: XCTestCase {
    func testBasicValidator() {
        let numberValidator = ValidatorOf<Int, String> { value in
            if value > 5 {
                return .valid(value)
            }
            return .error("must be greater than 5")
        }
        
        XCTAssert(
            numberValidator.validate(6).isValid)
        XCTAssertFalse(
            numberValidator.validate(5).isValid)
        XCTAssertEqual(
            "must be greater than 5",
            numberValidator.validate(3).errors?.first)
    }
    
    func testPullback() {
        let numberValidator = ValidatorOf<Int, String> { value in
            if value > 5 {
                return .valid(value)
            }
            return .error("must be greater than 5")
        }
        
        let stringLengthValidator: ValidatorOf<String, String> = numberValidator.pullback(\.count)
        
        XCTAssert(
            stringLengthValidator.validate("foobar").isValid)
        XCTAssertFalse(
            stringLengthValidator.validate("foo").isValid)
    }
    
    func testMapErrors() {
        let numberValidator = ValidatorOf<Int, String> { value in
            if value > 5 {
                return .valid(value)
            }
            return .error("must be greater than 5")
        }
        
        let stringLengthValidator: ValidatorOf<String, String> = numberValidator
            .pullback(\.count)
            .mapErrors { error in "length \(error)" }
                
        XCTAssertEqual(
            "length must be greater than 5",
            stringLengthValidator.validate("foo").errors?.first)
    }
    
    func testMapErrorsToNewType() {
        struct ErrorType {
            let message: String
        }
        
        let alwaysFails = ValidatorOf<Any, String> { _ in
            return .error("always fails")
        }
        
        let alwaysFailsWithError = alwaysFails
            .mapErrors { ErrorType(message: $0) }
        
        XCTAssertEqual(
            "always fails",
            alwaysFailsWithError.validate(0).errors?.first.message)
    }
    
    func testCombineValidators() {
        let greaterThanTwo = ValidatorOf<Int, String> { value in
            if value > 2 {
                return .valid(value)
            }
            return .error("must be greater than 2")
        }
        
        let lessThanTen = ValidatorOf<Int, String> { value in
            if value < 10 {
                return .valid(value)
            }
            return .error("must be less than 10")
        }
        
        let isEven = ValidatorOf<Int, String> { value in
            if value % 2 == 0 {
                return .valid(value)
            }
            return .error("must be even")
        }
        
        let combined = ValidatorOf<Int, String>.combine(
            greaterThanTwo,
            lessThanTen,
            isEven)
        
        XCTAssert(
            combined.validate(4).isValid)
        XCTAssertFalse(
            combined.validate(5).isValid)
        XCTAssertEqual(["must be even"],
            Array(combined.validate(5).errors!))
        XCTAssertFalse(
            combined.validate(1).isValid)
        XCTAssertEqual(["must be even", "must be greater than 2"].sorted(),
            Array(combined.validate(1).errors!).sorted())
    }
    
    func testReduceErrors() {
        let alwaysFailsOne = ValidatorOf<Any, String> { _ in .error("failure one") }
        let alwaysFailsTwo = ValidatorOf<Any, String> { _ in .error("failure two") }
        
        let arrayCollectingValidator = ValidatorOf<Any, String>
            .combine(alwaysFailsOne, alwaysFailsTwo)
            .reduceErrors([]) { collector, error in
                collector + [error]
            }
        
        let validated = arrayCollectingValidator.validate("anything")
        let errorArray = validated.errors!.first
        
        XCTAssertEqual(["failure one", "failure two"], errorArray)
    }
    
    func testItsValidator() {
        let validator = ValidatorOf<String, String>.its(\.first, .isEqualTo("h"))
        
        assertValid(validator, given: "hello")
        assertNotValid(validator, given: "goodbye")
    }
}

