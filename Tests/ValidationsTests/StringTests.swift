import XCTest

@testable import Validations

final class StringTests: XCTestCase {
    func testHasLengthOf() {
        let validation = ValidatorOf<String, String>.itsLength(.isExactly(3))
        
        assertValid(validation, given: "foo")
        assertNotValid(validation, given: "foobar", errors: ["length must be exactly 3"])
    }

    func testBeginsWith() {
        let validation = ValidatorOf<String, String>.beginsWith("foo")
        
        assertValid(validation, given: "foobar")
        assertNotValid(validation, given: "bar", errors: ["must begin with 'foo'"])
    }
    
    func testEndsWith() {
        let validation = ValidatorOf<String, String>.endsWith("bar")
        
        assertValid(validation, given: "foobar")
        assertNotValid(validation, given: "foo", errors: ["must end with 'bar'"])
    }
    
    func testEqualTo() {
        let validation = ValidatorOf<String, String>.isEqualTo("foo")
        assertValid(validation, given: "foo")
        assertNotValid(validation, given: "foobar", errors: ["must be equal to 'foo'"])
    }
}
