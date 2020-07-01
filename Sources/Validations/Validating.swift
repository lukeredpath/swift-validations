@_exported import Validated

@dynamicMemberLookup @propertyWrapper
public struct Validating<Value> {
    public struct Errors {
        public var key: String? = nil
        public var errors: [String] = []
        
        func combine(with otherErrors: [String]) -> Errors {
            return Errors(key: key, errors: errors + otherErrors)
        }
    }
    
    public var wrappedValue: Value {
        didSet {
            validatedValue = validator.validate(wrappedValue)
        }
    }
    let validator: ValidatorOf<Value, String>
    var validatedValue: Validated<Value, String>
    var errorKey: String?
    
    public var projectedValue: Validated<Value, String> { validatedValue }
    
    public var errors: Errors? {
        switch validatedValue {
        case .valid:
            return nil
        case let .invalid(errorStrings):
            return Errors(key: errorKey, errors: Array(errorStrings))
        }
    }
    
    public init(wrappedValue: Value, _ validator: ValidatorOf<Value, String>, errorKey: String? = "") {
        self.wrappedValue = wrappedValue
        self.validator = validator
        self.errorKey = errorKey
        self.validatedValue = validator.validate(wrappedValue)
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Validated<Value, String>, T>) -> T {
        return validatedValue[keyPath: keyPath]
    }
}
