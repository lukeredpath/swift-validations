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
    
    public func pullback<LocalValue>(_ transform: @escaping (LocalValue) -> Value) -> ValidatorOf<LocalValue, Error> {
        return ValidatorOf<LocalValue, Error> { localValue in
            self.validate(transform(localValue)).map { _ in localValue }
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

extension ValidatorOf {
    static func its<T>(_ transform: @escaping (Value) -> T, _ validator: ValidatorOf<T, Error>) -> Self {
        validator.pullback(transform)
    }
}
