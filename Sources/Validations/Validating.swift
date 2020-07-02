@_exported import Validated

/// A type that wraps a value of type `Value` and an associated validator and re-validates every time value is updated.
///
/// This type can be used to associate a value and its validation rules and have that value be re-validated every time it changes, check if it is valid and if not, what the validation errors are. It has dynamic member lookup support to provide direct access to the validated value.
///
/// Its primary use is as a property wrapper that lets you declaratively validate properties on your types. When used this way, you can access the validated version of your property using the $property syntax.
///
///     struct MyViewModel {
///         @Validating(.hasLengthOf(.atLeast(6))
///         var password: String = ""
///     }
///
///     var viewModel = MyViewModel()
///     viewModel.$password.isValid // returns false
///     viewModel.password = "mypassword"
///     viewModel.$password.isValid // returns true
///
@dynamicMemberLookup @propertyWrapper
public struct Validating<Value> {
    /// The wrapped value - changing the value will trigger validation.
    public var wrappedValue: Value {
        didSet {
            validatedValue = validator.validate(wrappedValue)
        }
    }
    
    /// The validator that will be used every time the `wrappedValue` changes.
    let validator: ValidatorOf<Value, String>
    
    /// The result of the last validation. Initially set during initialisation.
    var validatedValue: Validated<Value, String>
    
    /// Returns the `validatedValue` when using `$value` syntax.
    public var projectedValue: Validated<Value, String> { validatedValue }
    
    /// Initialises a new instance.
    ///
    /// - Parameters:
    ///     - wrappedValue: The value being wrapped
    ///     - validator: The validator to use every time `wrappedValue` is changed.
    ///
    /// This method will automatically validate the initial `wrappedValue`, meaning a `validatedValue` will be available immediately after initialisation.
    public init(wrappedValue: Value, _ validator: ValidatorOf<Value, String>) {
        self.wrappedValue = wrappedValue
        self.validator = validator
        self.validatedValue = validator.validate(wrappedValue)
    }
    
    /// A convenience initialiser that takes a variadic list of validators and automatically combines them into a single validator.
    public init(wrappedValue: Value, _ validators: ValidatorOf<Value, String>...) {
        self.init(wrappedValue: wrappedValue, .combine(validators))
    }
    
    /// Provides dynamic access to the underlying validated value's properties.
    public subscript<T>(dynamicMember keyPath: KeyPath<Validated<Value, String>, T>) -> T {
        return validatedValue[keyPath: keyPath]
    }
}

/// A type that wraps an optional of type `Value` and an associated validator and re-validates every time the value is updated.
///
/// This type is the functional equivalent of `Validating` but for optional values. This version should be used when you cannot provide a default value for a property on a type but still need to validate it, including if the value is required or not. Whilst it is preferable to use the Swift type system to declare whether or not a value is optional, it might not always be possible, e.g. if you need to capture some required value from user input but do not have any meaningful default that you can assign to the variable where it is declared.
///
/// Unless explicitly stated otherwise during initalisation, values are always treated as required, i.e. if the value is `nil` then validation will return an  `.invalid` result. It is possible to specify that a value is not required in which case validation will only be run if the value is non-nil and otherwise will be treated as `.valid`.
///
@dynamicMemberLookup @propertyWrapper
public struct OptionalValidating<Value> {
    /// The optional wrapped value - changing the value will trigger validation.
    public var wrappedValue: Value? {
        didSet {
            validatedValue = validator.validate(wrappedValue)
        }
    }
    
    /// The validator that will be used every time the `wrappedValue` changes.
    let validator: ValidatorOf<Value?, String>
    
    /// The result of the last validation. Initially set during initialisation.
    var validatedValue: Validated<Value?, String>
    
    /// Returns the `validatedValue` when using `$value` syntax.
    public var projectedValue: Validated<Value?, String> { validatedValue }
    
    /// Initialises a new instance.
    ///
    /// This initialiser will be called whenever you use the `@OptionalValidating` property wrapper and specify a default value for the optional property.
    ///
    /// By default, the value will be treated as required, which means any `nil` value will be treated as invalid.
    ///
    /// - Parameters:
    ///     - wrappedValue: The value being wrapped
    ///     - required: If `true`, `nil` values will be treated as invalid. Defaults to `true`.
    ///     - validator: The validator to use every time `wrappedValue` is changed.
    ///
    /// This method will automatically validate the initial `wrappedValue`, meaning a `validatedValue` will be available immediately after initialisation.
    ///
    /// You should pass in a non-optional validator - it will be converted to an optional validator automatically.
    ///
    public init(wrappedValue: Value?, required: Bool = true, _ validator: ValidatorOf<Value, String>) {
        self.wrappedValue = wrappedValue
        self.validator = validator.optional(allowNil: !required)
        self.validatedValue = self.validator.validate(wrappedValue)
    }
    
    /// A convenience initialiser that takes a variadic list of validators and automatically combines them into a single validator.
    public init(wrappedValue: Value?, required: Bool = true, _ validators: ValidatorOf<Value, String>...) {
        self.init(wrappedValue: wrappedValue, required: true, .combine(validators))
    }
    
    /// A convenience initialiser that doesn't require an initial `wrappedValue`.
    ///
    /// This method will be called when using the `@OptionalValidating` property wrapper with a property that has no initial value.
    ///
    /// You must explicitly state whether or not the value is required or not.
    ///
    /// - Parameters:
    ///     - required: If `true`, `nil` values will be treated as invalid. Defaults to `true`.
    ///     - validator: The validator to use every time `wrappedValue` is changed.
    ///
    public init(required: Bool, _ validator: ValidatorOf<Value, String>) {
        self.validator = validator.optional(allowNil: !required)
        self.validatedValue = self.validator.validate(wrappedValue)
    }
    
    /// A convenience initialiser that doesn't require an initial `wrappedValue`.
    ///
    /// This method takes a variadic list of validators and combines them into one automatically.
    ///
    public init(required: Bool, _ validators: ValidatorOf<Value, String>...) {
        self.init(required: required, .combine(validators))
    }

    /// Provides dynamic access to the underlying validated value's properties.
    public subscript<T>(dynamicMember keyPath: KeyPath<Validated<Value?, String>, T>) -> T {
        return validatedValue[keyPath: keyPath]
    }
}
