import XCTest
import Validations

func assertValid<Value>(
    _ validator: ValidatorOf<Value, String>,
    given value: Value,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    let result = validator.validate(value)
    
    XCTAssert(
        result.isValid,
        "should be valid given \(value)",
        file: file, line: line)
}

func assertNotValid<Value>(
    _ validator: ValidatorOf<Value, String>,
    given value: Value,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    let result = validator.validate(value)
    
    XCTAssertFalse(
        result.isValid,
        "should not be valid given \(value)",
        file: file, line: line)
}

func assertNotValid<Value, Error>(
    _ validator: ValidatorOf<Value, Error>,
    given value: Value,
    errors: [Error],
    file: StaticString = #filePath,
    line: UInt = #line
) where Error: Comparable {
    let result = validator.validate(value)
    
    XCTAssertFalse(
        result.isValid, "should not be valid given \(value)",
        file: file, line: line)
    
    XCTAssertEqual(
        errors.sorted(), Array(result.errors!),
        "expected errors to match: \(errors)",
        file: file, line: line)
}
