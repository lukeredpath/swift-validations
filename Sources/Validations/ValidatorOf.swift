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

public struct ValidatorOf<Value, Error> {
    public let validate: (Value) -> Validated<Value, Error>
    
    public init(validate: @escaping (Value) -> Validated<Value, Error>) {
        self.validate = validate
    }
    
    public func pullback<LocalValue>(_ transform: @escaping (LocalValue) -> Value) -> ValidatorOf<LocalValue, Error> {
        return ValidatorOf<LocalValue, Error> { localValue in
            self.validate(transform(localValue)).map { _ in localValue }
        }
    }
    
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
