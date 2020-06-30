@_exported import Validated

@dynamicMemberLookup
public struct Validating<Value> {
    public typealias ErrorType = String
    
    public var value: Value {
        didSet {
            validatedValue = validator.validate(value)
        }
    }
    let validator: ValidatorOf<Value, ErrorType>
    
    private var validatedValue: Validated<Value, ErrorType>
    
    public init(initialValue: Value, validator: ValidatorOf<Value, ErrorType>) {
        self.value = initialValue
        self.validator = validator
        self.validatedValue = validator.validate(value)
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Validated<Value, ErrorType>, T>) -> T {
        return validatedValue[keyPath: keyPath]
    }
}

