import XCTest

@testable import Validations

final class CollectionTests: XCTestCase {
    func testContains() {
        let validation = ValidatorOf<Array<Int>, String>.contains(1)
        
        assertValid(validation, given: [1, 2, 3])
        assertNotValid(validation, given: [2, 3], errors: ["must contain 1"])
    }
    
    func testEqualTo() {
        let validation = ValidatorOf<Array<Int>, String>.isEqualTo([1, 2, 3])
        assertValid(validation, given: [1, 2, 3])
        assertNotValid(validation, given: [1, 2], errors: ["must be equal to '[1, 2, 3]'"])
    }
}
