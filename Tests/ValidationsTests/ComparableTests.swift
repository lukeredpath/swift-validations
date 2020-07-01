import XCTest

@testable import Validations

final class ComparableTests: XCTestCase {
    func testGreaterThan() {
        let validation = ValidatorOf.isGreaterThan(4)
        
        assertValid(validation, given: 5)
        assertNotValid(validation, given: 4, errors: ["must be greater than 4"])
        assertNotValid(validation, given: 3)
    }
    
    func testLessThan() {
        let validation = ValidatorOf.isLessThan(4)
        
        assertValid(validation, given: 3)
        assertNotValid(validation, given: 4, errors: ["must be less than 4"])
        assertNotValid(validation, given: 5)
    }
    
    func testAtLeast() {
        let validation = ValidatorOf.isAtLeast(4)
        
        assertValid(validation, given: 5)
        assertValid(validation, given: 4)
        assertNotValid(validation, given: 3, errors: ["must be at least 4"])
    }
    
    func testAtMost() {
        let validation = ValidatorOf.isAtMost(4)
        
        assertValid(validation, given: 3)
        assertValid(validation, given: 4)
        assertNotValid(validation, given: 5, errors: ["must be at most 4"])
    }
    
    func testIsInClosedRange() {
        let validation = ValidatorOf.isInRange(1...5)
        
        assertValid(validation, given: 1)
        assertValid(validation, given: 3)
        assertValid(validation, given: 5)
        assertNotValid(validation, given: 6, errors: ["must be in range 1...5"])
    }
    
    func testIsInHalfClosedRange() {
        let validation = ValidatorOf.isInRange(1..<5)
        
        assertValid(validation, given: 1)
        assertValid(validation, given: 3)
        assertNotValid(validation, given: 5, errors: ["must be in range 1..<5"])
        assertNotValid(validation, given: 6, errors: ["must be in range 1..<5"])
    }
}
