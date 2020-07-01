import XCTest

@testable import Validations

final class ElementTests: XCTestCase {
    func testInclusionInArray() {
        let validation = ValidatorOf.isIncluded(in: [1, 2, 3])
        
        assertValid(validation, given: 3)
        assertNotValid(validation, given: 4, errors: ["must be included in [1, 2, 3]"])
    }
    
    func testInclusionInSet() {
        let validation = ValidatorOf.isIncluded(in: Set([1, 2, 3]))
        
        assertValid(validation, given: 3)
        assertNotValid(validation, given: 4, errors: ["must be included in set"])
    }
    
    func testExclusionInArray() {
        let validation = ValidatorOf.isExcluded(from: [1, 2, 3])
        
        assertValid(validation, given: 4)
        assertNotValid(validation, given: 3, errors: ["must be excluded from [1, 2, 3]"])
    }
    
    func testExclusionInSet() {
        let validation = ValidatorOf.isExcluded(from: Set([1, 2, 3]))
        
        assertValid(validation, given: 4)
        assertNotValid(validation, given: 3, errors: ["must be excluded from set"])
    }
}
