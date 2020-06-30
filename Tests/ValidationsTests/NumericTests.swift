import XCTest

@testable import Validations

final class NumericTests: XCTestCase {
    func testGreaterThan() {
        let validation = ValidatorOf.greaterThan(4)
        
        assertValid(validation, given: 5)
        assertNotValid(validation, given: 4, errors: ["must be greater than 4"])
        assertNotValid(validation, given: 3)
    }
    
    func testLessThan() {
        let validation = ValidatorOf.lessThan(4)
        
        assertValid(validation, given: 3)
        assertNotValid(validation, given: 4, errors: ["must be less than 4"])
        assertNotValid(validation, given: 5)
    }
    
    func testAtLeast() {
        let validation = ValidatorOf.atLeast(4)
        
        assertValid(validation, given: 5)
        assertValid(validation, given: 4)
        assertNotValid(validation, given: 3, errors: ["must be at least 4"])
    }
    
    func testAtMost() {
        let validation = ValidatorOf.atMost(4)
        
        assertValid(validation, given: 3)
        assertValid(validation, given: 4)
        assertNotValid(validation, given: 5, errors: ["must be at most 4"])
    }
    
    func testExactly() {
        let validation = ValidatorOf.exactly(4)
        
        assertNotValid(validation, given: 3)
        assertValid(validation, given: 4)
        assertNotValid(validation, given: 5, errors: ["must be exactly 4"])
    }
    
    func testEven() {
        let validation = ValidatorOf.even
        
        assertValid(validation, given: 2)
        assertNotValid(validation, given: 3, errors: ["must be even"])
    }
    
    func testOdd() {
        let validation = ValidatorOf.odd
        
        assertValid(validation, given: 3)
        assertNotValid(validation, given: 4, errors: ["must be odd"])
    }
}
