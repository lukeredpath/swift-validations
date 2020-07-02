@_exported import Validated

extension Validated {
    func mapErrors<LocalError>(_ transform: (Error) -> LocalError) -> Validated<Value, LocalError> {
        switch self {
        case let .valid(value):
            return .valid(value)
        case let .invalid(errors):
            return .invalid(errors.map(transform))
        }
    }
    
    func reduceErrors<T>(_ initialValue: T, _ reducer: (T, Error) -> T) -> Validated<Value, T> {
        switch self {
        case let .valid(value):
            return .valid(value)
        case let .invalid(errors):
            return .error(errors.reduce(initialValue, reducer))
        }
    }
}

/// A type that acts as a generic wrapper around a validate function.
///
/// This type is the building block for all validations provided by the library.
///
/// When writing your own validators - either from scratch, or by composing existing ones - it is recommended that you encapsulate these by creating static variables (or functions, if your validator takes parameters) on extensions of `ValidatorOf`, constrainted to the type value type that the validator operates on.
///
/// You should also constrain your extension on the particular type of error that you return - in most cases this will simply be a `String`.
///
/// The following example shows you can define your own validator that operates on an `Int`:
///
///     extension ValidatorOf where Value == String, Error == String {
///         static func myIntValidator(someParameter: Int) -> Self {
///             return Self { value in
///                 // your validation logic
///             }
///         }
///     }
///
/// Defining your validators in this way allows you to pass an instance into anything that takes a `ValidatorOf<Int, String>` (such as the `@Validating` property wrapper) in concise form by taking advantage of Swift type-inference, e.g.:
///
///     @Validating(.myIntValidator(someParameter: 1))
///
public struct ValidatorOf<Value, Error> {
    /// A closure type that encapsulates validation logic.
    ///
    /// - Parameters:
    ///     - value: The value to be validated.
    ///
    /// - Returns: The validation result, either `.valid(Value)` or `.invalid(Error)`.
    public typealias Validator = (_ value: Value) -> Validated<Value, Error>
    
    /// The validate function. Call this as a function to perform validation on a given  value.
    public let validate: Validator
    
    /// Initialises an instance with the given `Validator` closure.
    ///
    /// Swift's trailing closure syntax allows for validator types to be defined quite succinctly:
    ///
    ///     let myIntValidator = ValidatorOf<Int, String> { value in
    ///         // your validation logic here
    ///     }
    ///
    /// - Parameters:
    ///     - validate: The validator function.
    public init(validate: @escaping Validator) {
        self.validate = validate
    }
    
    /// Returns a new validator derived from self that operates on values of type `LocalValue`.
    ///
    /// Validator pullback allows you to re-use existing validator logic that works on one type `A` against a different type `B` by providing a  function that knows how to transform type `B` to `A`.
    ///
    /// For example, say you have an `ageValidator` that operates on type `Int`,  a `struct Person` that has an `age: Int` property and you want to define a `personValidator` that validates the person's age.
    ///
    /// Instead of writing a validator from scratch, you can simply use your existing `ageValidator`, pulled back to operate on type `Person`, providing a function that returns `Person.age`:
    ///
    ///     let personValidator: ValidatorOf<Person, String> = ageValidator.pullback { person in person.age }
    ///
    /// Since Swift 5.2 allows you to pass a `KeyPath` as a function, the you can pass in any `KeyPath<LocalValue, Value>` instead:
    ///
    ///     let personValidator: ValidatorOf<Person, String> = ageValidator.pullback(\.age)
    ///
    /// - Parameters:
    ///     - transform: A function that converts some other type `LocalValue` to self's `Value` type.
    ///     - localValue: The value passed to `validate` on the derived validator.
    ///
    /// - Returns: A new validator that operates on `LocalValue`.
    ///
    public func pullback<LocalValue>(_ transform: @escaping (_ localValue: LocalValue) -> Value) -> ValidatorOf<LocalValue, Error> {
        return ValidatorOf<LocalValue, Error> { localValue in
            self.validate(transform(localValue)).map { _ in localValue }
        }
    }
    
    /// Returns a new optional validator that operates on `Value?` instead of `Value`.
    ///
    /// This operator allows you to re-use an existing validator on non-optional types with an optional of the same type.
    ///
    /// This can be useful in situations where you cannot rely on the Swift type system to enforce optional behaviour, for example if you are capturing some user input that you require be non-nil but cannot use a non-optional type as there is no sensible default that you can use.
    ///
    /// Whenever possible, if you have a value that is required and you are able to provide a sensible default you should prefer to use the Swift type system to enforce it and use a non-optional property and validator.
    ///
    /// This generic form takes an optional error value that will be used to determine if a value is required in order to be valid.
    ///
    /// - Parameters:
    ///     - errorOnNil: An optional error value. If an error value is given, `nil` values will be treated as invalid and the error value given will be used in the `.invalid` result. If no error value is given, `nil` values will always produce a `.valid` result.
    ///
    /// - See Also: `optional(allowNil:)`
    ///
    public func optional(errorOnNil: Error?) -> ValidatorOf<Value?, Error> {
        ValidatorOf<Value?, Error> { optionalValue in
            if let value = optionalValue {
                return self.validate(value).map(Optional.init)
            }
            if let error = errorOnNil {
                return .error(error)
            }
            return .valid(nil)
        }
    }
    
    /// Returns a validator that is the logical inverse of self.
    ///
    /// If you have some validator that performs some kind of boolean logic, you can easily produce a negated version using this operator.
    ///
    /// Example:
    ///
    ///     let isTrue = ValidatorOf<Bool, String> {
    ///         if $0 == true { return .valid(true) }
    ///         return .error("must be true")
    ///     }
    ///
    ///     let isFalse = isTrue.negated(withError: "must be false")
    ///
    /// - Parameters:
    ///     - error: The error to use for the negated invalid case.
    ///
    public func negated(withError error: Error) -> Self {
        Self {
            switch self.validate($0) {
            case .valid:
                return .error(error)
            case .invalid:
                return .valid($0)
            }
        }
    }
    
    /// Returns a new validator whose errors are transformed by the provided closure.
    ///
    /// This operator can be used to modify or replace errors on an existing validator whilst not changing the actual validation logic itself.
    ///
    /// All validators that produce an invalid result will hold on to a non-empty array of errors although many will typically only have one error. In this case you can simply return a brand new error value from your `transform` closure and it will replace that single error.
    ///
    /// However, it is possible for a validator to hold more than one error, for instance, any validators that you have composed using `combine`. In this case, you should use this method to derive a new error from the existing one. If you need to replace all errors with a single error you should use `reduceErrors` instead.
    ///
    /// - Parameters:
    ///     - transform: A closure that is called with each error in turn and should return a new local error.
    ///     - error: The error from the original validator.
    ///
    /// - Returns: A new validator whose errors are automatically mapped.
    ///
    public func mapErrors<LocalError>(_ transform: @escaping (_ error: Error) -> LocalError) -> ValidatorOf<Value, LocalError> {
        return ValidatorOf<Value, LocalError> { value in
            self.validate(value).mapErrors(transform)
        }
    }

    /// Returns a new validator whose errors are reduced to a single error using the provided closure.
    ///
    /// This operator can be used to create a validator that may produce multiple errors and reduce them into a single error.
    ///
    /// This method can be usedful if you only want to produce a single error that you present to a user e.g. by joining them into a single sentence, or you could use this method to wrap the errors in some other container object.
    ///
    /// - Parameters:
    ///     - initialValue: The initial value passed into the reducer.
    ///     - reducer: A closure that receives the initialValue on the first call, then the accumulated value, and each error in turn. It should return a new value that will be passed into the reducer on the next call.
    ///     - result: The accumulated error value
    ///     - error: Each error from the original validator.
    ///
    func reduceErrors<ReducedError>(
        _ initialValue: ReducedError,
        reducer: @escaping (_ result: ReducedError, _ error: Error) -> ReducedError) -> ValidatorOf<Value, ReducedError> {
        return ValidatorOf<Value, ReducedError> { value in
            self.validate(value).reduceErrors(initialValue, reducer)
        }
    }
    
    /// Composes multiple validators into a single validator.
    ///
    /// This form takes a variadic list of validators/
    ///
    /// - See Also: `combine(validators:)`
    ///
    public static func combine<Value, Error>(_ validators: ValidatorOf<Value, Error>...) -> ValidatorOf<Value, Error> {
        combine(validators)
    }
    
    /// Composes an array of validators into a single validator.
    ///
    /// Returns a new validator that accumulates the results of each composed validator, returning a `.valid` result if all validators are valid or an `.invalid` result containing an aggregate of all errors if any of them are invalid.
    ///
    /// - Parameters:
    ///     - validators: A homogenous collection of validators that operate on the same `Value` and `Error`.
    ///
    /// - Returns: A new composite validator.
    ///
    public static func combine<Value, Error>(_ validators: [ValidatorOf<Value, Error>]) -> ValidatorOf<Value, Error> {
        return ValidatorOf<Value, Error> { value in
            validators.reduce(.valid(value)) { validated, validator in
                return zip(validated, validator.validate(value)).map { _ in value }
            }
        }
    }
}

extension ValidatorOf where Error == String {
    /// Returns a new optional validator that operates on `Value?` instead of `Value`.
    ///
    /// This operator allows you to re-use an existing validator on non-optional types with an optional of the same type.
    ///
    /// This operator is similar to `optional(errorOnNil:)` except instead of taking an error value, it simply takes a boolean to indicate whether nil is allowed. If `allowNil` is `true` then nil values will be treated as valid, otherwise they will be treated as invalid, using a default string error message.
    ///
    /// Whilst you could use `mapErrors` or `reduceErrors` to modify the default message, if you need to use a specific error you should use `optional(errorOnNil:)` and pass the required error directly.
    ///
    /// - Parameters:
    ///     - errorOnNil: An optional error value. If an error value is given, `nil` values will be treated as invalid and the error value given will be used in the `.invalid` result. If no error value is given, `nil` values will always produce a `.valid` result.
    ///
    /// - See Also: `optional(errorOnNil:)`
    ///
    public func optional(allowNil: Bool) -> ValidatorOf<Value?, Error> {
        ValidatorOf<Value?, Error> { optionalValue in
            if let value = optionalValue {
                return self.validate(value).map(Optional.init)
            }
            return allowNil ? .valid(nil) : .error("is required")
        }
    }
}

extension ValidatorOf {
    /// Syntatic sugar for pulling back a validator to a new type.
    ///
    /// Example:
    ///
    ///     let validateFirstItem: ValidatorOf<[Int], String> = .its(\.first, .isGreaterThan(0))
    ///
    /// - Parameters:
    ///     - transform: A closure that derives a value `T` from another value.
    ///     - value: The value to be transformed.
    ///     - validator: The validator to pull back on.
    ///
    /// - Returns: A validator on type `T`.
    ///
    static func its<T>(_ transform: @escaping (_ value: Value) -> T, _ validator: ValidatorOf<T, Error>) -> Self {
        validator.pullback(transform)
    }
    
    #if compiler(<5.3)
    /*
    There seems to be a bug or undefined using a keypath as a function inside a property-wrapper call on Swift 5.2,
     so to workaround it we can can provide overload that takes a key path explicitly.
    https://forums.swift.org/t/keypath-as-function-inside-property-wrapper-doesnt-compile-in-5-2-fine-in-5-3/38074
    */
    /// A version of `its` that provides explicit support for a `KeyPath`.
    ///
    /// This provides keypath support for versions of Swift prior to 5.2 (which supports passing a `KeyPath` as a function directly).
    ///
    /// - See Also: `its(transform:, validator:)`
    ///
    static func its<T>(_ keyPath: KeyPath<Value, T>, _ validator: ValidatorOf<T, Error>) -> Self {
        validator.pullback { $0[keyPath: keyPath] }
    }
    #endif
    
    /// Syntatic sugar for the `negated()` operator.
    ///
    /// This allows for a more expressive definition of a negated validator, e.g.:
    ///
    ///     let notEqualTo: ValidatorOf<String, String> = .not(.equalTo("foo"), error: "must not equal foo").
    ///
    /// - Parameters:
    ///     - validator: The validator to negate.
    ///     - error: The error to use for invalid results on the negated validator.
    ///
    /// - See Also: `negated(withError:)`
    ///
    static func not(_ validator: Self, error: Error) -> Self {
        return validator.negated(withError: error)
    }
}
