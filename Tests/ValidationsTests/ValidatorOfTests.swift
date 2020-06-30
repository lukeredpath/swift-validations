import XCTest
import Validated
@testable import Validations

final class ValidatorOfTests: XCTestCase {
    func testBasicValidator() {
        let numberValidator = ValidatorOf<Int> { value in
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
        let numberValidator = ValidatorOf<Int> { value in
            if value > 5 {
                return .valid(value)
            }
            return .error("must be greater than 5")
        }
        
        let stringLengthValidator: ValidatorOf<String> = numberValidator.pullback(\.count)
        
        XCTAssert(
            stringLengthValidator.validate("foobar").isValid)
        XCTAssertFalse(
            stringLengthValidator.validate("foo").isValid)
    }
    
    func testMapErrors() {
        let numberValidator = ValidatorOf<Int> { value in
            if value > 5 {
                return .valid(value)
            }
            return .error("must be greater than 5")
        }
        
        let stringLengthValidator: ValidatorOf<String> = numberValidator
            .pullback(\.count)
            .mapErrors { error in "length \(error)" }
                
        XCTAssertEqual(
            "length must be greater than 5",
            stringLengthValidator.validate("foo").errors?.first)
    }
}
