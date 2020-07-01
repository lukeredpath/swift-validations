# Validations

![Swift](https://github.com/lukeredpath/swift-validations/workflows/Swift/badge.svg)

## Overview

Validations is a high-level validation library, written in a functional style. It was created to explore functional API design as outlined in the [Pointfree.co series on protocol witnesses](https://www.pointfree.co/collections/protocol-witnesses) as an alternative to the usual protocol-oriented approach. 

The library builds on top of the `Validated` type provided by the [Validated](https://github.com/pointfreeco/swift-validated) library.

## Core API

Fundamentally, a validator can be expressed as a generic function of type:

```swift
(Value) -> Validated<Value, ErrorType>
```

The `Validated` type is an enum that represents either a valid value or an invalid value. An invalid value has a non-empty collection of errors of type `ErrorType`.

Validations wrapps the above method up in a struct type called `ValidatorOf<T, ErrorType>` where `T` is the the of value being validated. Therefore, any custom validator can be expressed as such:

```swift
let alwaysValid = ValidatorOf<Any, Never> { .valid($0) }

XCTAssert(alwaysValid.validate(1).isValid)
XCTAssert(alwaysValid.validate("foo").isValid)

let alwaysFails = ValidatorOf<Any, String> { .error("failed") }

XCTAssertFalse(alwaysFails.validate(1).isValid)
XCTAssertEquals("failed", alwaysFails.validate(1).errors?.last)
```

### Re-using existing validators

Validators be extended and re-used with other types by using the `pullback` function. For example, given we already have a `greaterThan` validator that works on `Int`:

```swift
func greaterThan(_ lowerBound: Int) -> ValidatorOf<Int, String> {
    return ValidatorOf<Int, String> { value in 
        if value > lowerBound {
            return .valid(value)
        }
        return .error("is not greater than \(lowerBound)")
    }
}
```

If we wanted to write a similar validator for the length of a string, we could write one from scratch:

```swift
func longerThan(_ lowerBound: Int) -> ValidatorOf<String, String> {
    return ValidatorOf<Int, String> { value in 
    if value.count > lowerBound {
            return .valid(value)
        }
        return .error("length is not greater than \(lowerBound)")
    }
}
```

However, we are effectively duplicating the logic of the `greaterThan` validator - the only thing that changes is how we obtain the value to compare against (`value.count` instead of `value`) and the error message is prefixed with "length ".

We can remove the logic duplication by pulling back the `greaterThan` validator to operate on the `value`'s `count`:

```swift
func longerThan(_ lowerBound: Int) -> ValidatorOf<String, String> {
    return ValidatorOf<Int, String>.pullback { $0.count }
}
```

As of Swift 5.2, we can shorten this further due to support for passing a keypath as a function parameter:

```swift
func longerThan(_ lowerBound: Int) -> ValidatorOf<String, String> {
    return ValidatorOf<Int, String>.pullback(\.count)
}
```

Finally, we can improve the error message to add back the "length " prefix by using `mapError`:

```swift
func longerThan(_ lowerBound: Int) -> ValidatorOf<String, String> {
    return ValidatorOf<Int, String>
      .pullback(\.count)
      .mapError { "length \($0)" }
}
```

### Combining validators

Higher-level validators can be formed from existing ones using the `.combine` static method, so long as the operate on the same value type:

```swift
let lowerAgeLimit = ValidatorOf<Int, String>.greaterThan(10)
let upperAgeLimit = ValidatorOf<Int, String>.lessThan(20)
let ageValidator = ValidatorOf<Int, String>.combine(lowerAgeLimit, upperAgeLimit)

XCTAssert(ageValidator.validate(12).isValid)
XCTAssertFalse(ageValidator.validate(9).isValid)
XCTAssertFalse(ageValidator.validate(21).isValid)
```

### Negating validators

A validator that operates as the logical inverse of an existing validator can be produced using the `negated()` method on `ValidatorOf`.

For example, given a validator that checks for odd numbers:

```swift
let isOdd = ValidatorOf<Int, String> { 
    if $0 % 2 == 1 { 
        return .valid($0)
    }
    return .error("is not odd"")
}
```

You could create a validator that checks for even numbers by negating it. When negating a matcher, a new error message should be provided for the negated error case.

```swift
let isEven = isOdd.negated(withError: "is not even")
```

A static function `.not` is provided as syntatic sugar. The above could be re-written as:

```swift
let isEven: Validator<Int, String> = .not(isOdd)
```

### Built-in validators

The following validators are built-in and can be combined to form more domain-specific validations in your code:

* Boolean
    - `isTrue`
    - `isFalse`
* Collection
    - `hasLengthOf`
    - `contains` (where `Collection<T: Equatable>`)
* Comparable
    - `isAtLeast`
    - `isAtMost`
    - `isLessThan`
    - `isGreaterThan`
    - `isInRange(x...y)`
    - `isInRange(x..<y)`
* Collection Membership
    - `isIncluded(in: Array)`
    - `isExcluded(from: Array)`
    - `isIncluded(in: Set)`
    - `isExcluded(from: Set)`
* Equatable
    - `isEqualTo`
* Numeric
    - `isExactly`
    - `isOdd`
    - `isEven`
* String
    - `itsLength(<numeric validator type>)`
    - `hasLengthOf`
    - `beginsWith`
    - `endsWith`
    - `matchesPattern(_, as:)` (defaults to `.regularExpression`)

## Validating and @Validating

The library ships with a `Validating` type which can be used either on it's own or as a property wrapper. The `Validating<Value>` wraps both a value of type `Value` and a `ValidatorOf<Value, String>` that re-validates every time `Value` is updated, producing a new `Validated<Value>` which is stored internally. 

The `Validating` type provides dynamic property access to the underlying `Validated<Value>` so you can check if it is valid or access any errors.

### Simple usage

```swift
let validator: ValidatorOf<String, String> = .combine(
    .hasPrefix("foo"), 
    .hasLengthOf(.atLeast(4))
)

var validatingString: Validating<String> = Validating(wrappedValue: "", validator: validator)

XCTAssertEqual("", validatingString.wrappedValue)
XCTAssertFalse(validatingString.isValid)

validatingString.wrappedValue = "foobar"
XCTAssert(validatingString.isValid)
```

### Property wrapper usage

```swift
struct FormViewModel {
    @Validating(
        .hasLengthOf(.atLeast(3))
    )
    var name: String
    
    @Validating(
        .isInRange(13...80)
    )
    var age: Int
}
```
When used as a property wrapper, you can use the `$var` syntax to access the `Validated<Value>` directly to check if they are valid. Using the `zip` function provided by the `Validated` library, you could implement an `isValid()` method for the entire view model:

```swift
extension FormViewModel {
    var isValid: Bool {
        zip($name, $age).isValid
    }
}
```
