import XCTest
import Validations

func _assertValid<Value>(
    _ validator: ValidatorOf<Value, String>,
    given value: Value,
    filePath: StaticString,
    line: UInt = #line
) {
    let result = validator.validate(value)
    
    XCTAssert(
        result.isValid,
        "should be valid given \(value)",
        file: filePath, line: line)
}

func _assertNotValid<Value>(
    _ validator: ValidatorOf<Value, String>,
    given value: Value,
    filePath: StaticString,
    line: UInt = #line
) {
    let result = validator.validate(value)
    
    XCTAssertFalse(
        result.isValid,
        "should not be valid given \(value)",
        file: filePath, line: line)
}

func _assertNotValid<Value, Error>(
    _ validator: ValidatorOf<Value, Error>,
    given value: Value,
    errors: [Error],
    filePath: StaticString,
    line: UInt = #line
) where Error: Comparable {
    let result = validator.validate(value)
    
    XCTAssertFalse(
        result.isValid, "should not be valid given \(value)",
        file: filePath, line: line)
    
    XCTAssertEqual(
        errors.sorted(), Array(result.errors!),
        "expected errors to match: \(errors)",
        file: filePath, line: line)
}

// Remove this once the current source-compatibility breaking change is fixed, hopefully
// before Xcode 12 final drops!
//
// See: https://forums.swift.org/t/revisiting-the-source-compatibility-impact-of-se-0274-concise-magic-file-names/37720/3

#if compiler(>=5.3)
func assertValid<Value>(
    _ validator: ValidatorOf<Value, String>,
    given value: Value,
    filePath: StaticString = #filePath,
    line: UInt = #line
) {
    _assertValid(validator, given: value, filePath: filePath, line: line)
}
func assertNotValid<Value>(
    _ validator: ValidatorOf<Value, String>,
    given value: Value,
    filePath: StaticString = #filePath,
    line: UInt = #line
) {
    _assertNotValid(validator, given: value, filePath: filePath, line: line)
}
func assertNotValid<Value, Error>(
    _ validator: ValidatorOf<Value, Error>,
    given value: Value,
    errors: [Error],
    filePath: StaticString = #filePath,
    line: UInt = #line
) where Error: Comparable {
    _assertNotValid(validator, given: value, errors: errors, filePath: filePath, line: line)
}
#else
func assertValid<Value>(
    _ validator: ValidatorOf<Value, String>,
    given value: Value,
    filePath: StaticString = #file,
    line: UInt = #line
) {
    _assertValid(validator, given: value, filePath: filePath, line: line)
}
func assertNotValid<Value>(
    _ validator: ValidatorOf<Value, String>,
    given value: Value,
    filePath: StaticString = #file,
    line: UInt = #line
) {
    _assertNotValid(validator, given: value, filePath: filePath, line: line)
}
func assertNotValid<Value, Error>(
    _ validator: ValidatorOf<Value, Error>,
    given value: Value,
    errors: [Error],
    filePath: StaticString = #file,
    line: UInt = #line
) where Error: Comparable {
    _assertNotValid(validator, given: value, errors: errors, filePath: filePath, line: line)
}
#endif

