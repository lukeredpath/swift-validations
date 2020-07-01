extension ValidatorOf where Value: Comparable, Error == String {
    public static func isAtLeast(_ minimum: Value) -> Self {
        Self { value in
            if value >= minimum {
                return .valid(value)
            }
            return .error("must be at least \(minimum)")
        }
    }
    
    public static func isAtMost(_ maximum: Value) -> Self {
        Self { value in
            if value <= maximum {
                return .valid(value)
            }
            return .error("must be at most \(maximum)")
        }
    }
    
    public static func isLessThan(_ upperBound: Value) -> Self {
        Self { value in
            if value < upperBound {
                return .valid(value)
            }
            return .error("must be less than \(upperBound)")
        }
    }
    
    public static func isGreaterThan(_ lowerBound: Value) -> Self {
        Self { value in
            if value > lowerBound {
                return .valid(value)
            }
            return .error("must be greater than \(lowerBound)")
        }
    }
    
    public static func isInRange(_ range: ClosedRange<Value>) -> Self {
        Self { value in
            if range.contains(value) {
                return .valid(value)
            }
            return .error("must be in range \(range)")
        }
    }
    
    public static func isInRange(_ range: Range<Value>) -> Self {
        Self { value in
            if range.contains(value) {
                return .valid(value)
            }
            return .error("must be in range \(range)")
        }
    }
}
