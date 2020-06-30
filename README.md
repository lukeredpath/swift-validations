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

