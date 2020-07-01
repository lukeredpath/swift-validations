import XCTest

@testable import Validations

final class NumericTests: XCTestCase {
    func testExactly() {
        let validation = ValidatorOf.isExactly(4)
        
        assertNotValid(validation, given: 3)
        assertValid(validation, given: 4)
        assertNotValid(validation, given: 5, errors: ["must be exactly 4"])
    }
    
    func testEven() {
        let validation = ValidatorOf.isEven
        
        assertValid(validation, given: 2)
        assertNotValid(validation, given: 3, errors: ["must be even"])
    }
    
    func testOdd() {
        let validation = ValidatorOf.isOdd
        
        assertValid(validation, given: 3)
        assertNotValid(validation, given: 4, errors: ["must be odd"])
    }
}
