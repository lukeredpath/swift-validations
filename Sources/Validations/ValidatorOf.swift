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

struct ValidatorOf<Value> {
    let validate: (Value) -> Validated<Value, String>
    
    func pullback<LocalValue>(_ transform: @escaping (LocalValue) -> Value) -> ValidatorOf<LocalValue> {
        return ValidatorOf<LocalValue> { localValue in
            self.validate(transform(localValue)).map { _ in localValue }
        }
    }
    
    func mapErrors(_ transform: @escaping (String) -> String) -> ValidatorOf<Value> {
        return ValidatorOf<Value> { value in
            self.validate(value).mapErrors(transform)
        }
    }
}
