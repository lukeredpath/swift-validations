# Validations

![Swift](https://github.com/lukeredpath/swift-validations/workflows/Swift/badge.svg)

## Overview

Validations is a high-level validation library, written in a functional style. It was created to explore functional API design as outlined in the [Pointfree.co series on protocol witnesses](https://www.pointfree.co/collections/protocol-witnesses) as an alternative to the usual protocol-oriented approach. 

The library builds on top of the `Validated` type provided by the [Validated](https://github.com/pointfreeco/swift-validated) library.

[API Documentation](https://lukeredpath.github.io/swift-validations/)

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
func lengthLongerThan(_ lowerBound: Int) -> ValidatorOf<String, String> {
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
func lengthLongerThan(_ lowerBound: Int) -> ValidatorOf<String, String> {
    return longerThan(lowerBound).pullback { $0.count }
}
```

As of Swift 5.2, we can shorten this further due to support for passing a keypath as a function parameter:

```swift
func lengthLongerThan(_ lowerBound: Int) -> ValidatorOf<String, String> {
    return longerThan(lowerBound).pullback(\.count)
}
```

Finally, we can improve the error message to add back the "length " prefix by using `mapError`:

```swift
func lengthLongerThan(_ lowerBound: Int) -> ValidatorOf<String, String> {
    return longerThan(lowerBound)
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

### Handling optional values

It is possible to create a validator over an optional value, expressed as a type `ValidatorOf<T?, Error>` - when doing so, it is up to you to define how to handle nil values. If a value is optional, you can permit nil values by returning a `.valid` result - if a value is required then you should return an invalid result with an appropriate error message. 

For example, a validator on an optional `Int` that allows nil values can be defined as:

```swift
let optionalInt = ValidatorOf<Int?, String> { optionalValue in
    if let value = optionalValue {
        // your validation logic here
    }
    return .valid(optionalValue)
}
```

Alternatively, if you always require a value in order for the validator to return a valid result, you could instead write the following:

```swift
let optionalInt = ValidatorOf<Int?, String> { optionalValue in
    if let value = optionalValue {
        // your validation logic here
    }
    return .error("is required")
}
```

Validators that operate on optional types will return a `Validated<T?, Error>` result type.

The library provides an `optional()` operator in two different forms that can be used to convert an existing validator that operates on a non-optional type to one that operates on an optional - in both cases you are required to specify how missing values should be handled.

The generic overload requires that you pass in an optional error value of type `Error?` - if an error value is given then nil values will be treated as an error and will return an invalid result using the error value you give it. If no error value is given, then nil values will be treated as valid:

```swift
let ageMustBeOverTen: ValidatorOf<Int, String> = ...
let optionalAgeValidator = ageMustBeOverTen.optional(errorOnNil: "is required")

optionalAgeValidator.validate(11)   // returns Validated<Int?, String>.valid
optionalAgeValidator.validate(10)   // returns Validated<Int?, String>.error("must be over 10")
optionalAgeValidator.validate(nil)  // returns Validated<Int?, String>.error("is required")
```

All of the built-in validators and most of the validators you write yourself will use a `String` error type - in this case, you can use the alternative form `optional(allowNil: Bool)`, simply specifying if nil values are allowed or not - if you pass `false` then a default value of "is required" will be used:

```swift
let v1 = ValidatorOf<String, String>.hasPrefix("foo").optional(allowNil: true)
v1.validate(nil)    // returns Validated<String?, String>.valid

let v2 = ValidatorOf<String, String>.hasPrefix("foo").optional(allowNil: false)
v2.validate(nil)    // returns Validated<String?, String>.error("is required")
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

### Optional values

Whilst the Swift type system allows you to express whether or not a value is required using optional or non-optional values, there are times when you may have a required value but not have a sensible default value that you can set to satisfy the compiler - this is often the case when you have some kind of value that represents user input. In this case, it is preferable to make the value optional and then use a validation to enforce that it is non-nil.

If you need to handle optional values, you can use the optional counterpart  `OptionalValidating`. Like `Validating` this can be used standalone or as a property-wrapper. You do not need to pass in validators on optional types as they are converted to optional forms automatically. 

`OptionalValidating` can be initialized with or without an initial value. When initialised with a default value, it will treat nil values as invalid by default - this can be changed by explicitly passing in the `required` parameter. When initialised without a default value, you must explicitly state whether the value is required or not.

The following example demonstrates various uses as a property wrapper:

```swift
struct FormViewModel {
    // no default value means it is implicitly required and will start as invalid
    @OptionalValidating(.greaterThan(10))
    var requiredAge: Int?
    
    // if you can specify a default value, but still require it be non-nil you can be explicit
    @OptionalValidating(required: true, .myPostcodeValidator)
    var postcode: String? = ""
    
    // you can make a field truly optional by explicitly stating that it is not required
    @OptionalValidating(required: false, .myPhoneNumberValidator)
    var phoneNumber: String
}
```
