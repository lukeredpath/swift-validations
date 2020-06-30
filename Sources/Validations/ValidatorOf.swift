//
//  File.swift
//  
//
//  Created by Luke Redpath on 30/06/2020.
//

import Validated

extension Validated {
    func mapErrors<LocalError>(_ transform: (Error) -> LocalError) -> Validated<Value, LocalError> {
        switch self {
        case let .valid(value):
            return .valid(value)
        case let .invalid(errors):
            return .invalid(errors.map(transform))
        }
    }
}

public struct ValidatorOf<Value, Error> {
    let validate: (Value) -> Validated<Value, Error>
    
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
    
    public static func combine<Value, Error>(_ validators: ValidatorOf<Value, Error>...) -> ValidatorOf<Value, Error> {
        return ValidatorOf<Value, Error> { value in
            validators.reduce(.valid(value)) { validated, validator in
                return zip(validated, validator.validate(value)).map { _ in value }
            }
        }
    }
}
