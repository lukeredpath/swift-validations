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

    /// - Returns: A new validator that operates on `LocalValue`.
    public func pullback<LocalValue>(_ transform: @escaping (LocalValue) -> Value) -> ValidatorOf<LocalValue, Error> {
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
    
    public func mapErrors<LocalError>(_ transform: @escaping (Error) -> LocalError) -> ValidatorOf<Value, LocalError> {
        return ValidatorOf<Value, LocalError> { value in
            self.validate(value).mapErrors(transform)
        }
    }
    
    func reduceErrors<ReducedError>(
        _ initialValue: ReducedError,
        reducer: @escaping (ReducedError, Error) -> ReducedError) -> ValidatorOf<Value, ReducedError> {
        return ValidatorOf<Value, ReducedError> { value in
            self.validate(value).reduceErrors(initialValue, reducer)
        }
    }
    
    public static func combine<Value, Error>(_ validators: ValidatorOf<Value, Error>...) -> ValidatorOf<Value, Error> {
        combine(validators)
    }
    
    public static func combine<Value, Error>(_ validators: [ValidatorOf<Value, Error>]) -> ValidatorOf<Value, Error> {
        return ValidatorOf<Value, Error> { value in
            validators.reduce(.valid(value)) { validated, validator in
                return zip(validated, validator.validate(value)).map { _ in value }
            }
        }
    }
}

extension ValidatorOf where Error == String {
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
    static func its<T>(_ transform: @escaping (Value) -> T, _ validator: ValidatorOf<T, Error>) -> Self {
        validator.pullback(transform)
    }
    
    #if compiler(<5.3)
    /*
    There seems to be a bug or undefined using a keypath as a function inside a property-wrapper call on Swift 5.2,
     so to workaround it we can can provide overload that takes a key path explicitly.
    https://forums.swift.org/t/keypath-as-function-inside-property-wrapper-doesnt-compile-in-5-2-fine-in-5-3/38074
    */
    static func its<T>(_ keyPath: KeyPath<Value, T>, _ validator: ValidatorOf<T, Error>) -> Self {
        validator.pullback { $0[keyPath: keyPath] }
    }
    #endif
    
    static func not(_ validator: Self, error: Error) -> Self {
        return validator.negated(withError: error)
    }
}
