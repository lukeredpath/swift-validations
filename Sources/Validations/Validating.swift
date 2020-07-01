@_exported import Validated

@dynamicMemberLookup @propertyWrapper
public struct Validating<Value> {
    public var wrappedValue: Value {
        didSet {
            validatedValue = validator.validate(wrappedValue)
        }
    }
    let validator: ValidatorOf<Value, String>
    var validatedValue: Validated<Value, String>
    
    public var projectedValue: Validated<Value, String> { validatedValue }
    
    public init(wrappedValue: Value, _ validator: ValidatorOf<Value, String>) {
        self.wrappedValue = wrappedValue
        self.validator = validator
        self.validatedValue = validator.validate(wrappedValue)
    }
    
    public init(wrappedValue: Value, _ validators: ValidatorOf<Value, String>...) {
        self.init(wrappedValue: wrappedValue, .combine(validators))
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Validated<Value, String>, T>) -> T {
        return validatedValue[keyPath: keyPath]
    }
}
