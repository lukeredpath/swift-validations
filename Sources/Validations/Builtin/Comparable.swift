extension ValidatorOf where Value: Comparable, Error == String {
    /// Validates that a value `>=` the given value.
    ///
    /// - Parameters:
    ///     - minimum: The minimum expected value.
    ///
    public static func isAtLeast(_ minimum: Value) -> Self {
        Self { value in
            if value >= minimum {
                return .valid(value)
            }
            return .error("must be at least \(minimum)")
        }
    }
    
    /// Validates that a value is `<=` the given value.
    ///
    /// - Parameters:
    ///     - maximum: The maximum expected value.
    ///
    public static func isAtMost(_ maximum: Value) -> Self {
        Self { value in
            if value <= maximum {
                return .valid(value)
            }
            return .error("must be at most \(maximum)")
        }
    }
    
    /// Validates that a value is `<` the given value.
    ///
    /// - Parameters:
    ///     - upperBound: The amount that value should be less than.
    ///
    public static func isLessThan(_ upperBound: Value) -> Self {
        Self { value in
            if value < upperBound {
                return .valid(value)
            }
            return .error("must be less than \(upperBound)")
        }
    }
    
    /// Validates that a value is `>` the given value.
    ///
    /// - Parameters:
    ///     - lowerBound: The amount that the value should be greater than.
    ///
    public static func isGreaterThan(_ lowerBound: Value) -> Self {
        Self { value in
            if value > lowerBound {
                return .valid(value)
            }
            return .error("must be greater than \(lowerBound)")
        }
    }
    
    /// Validates that a value is within the given range.
    ///
    /// - Parameters:
    ///     - range: A closed range that the value should be within.
    ///
    public static func isInRange(_ range: ClosedRange<Value>) -> Self {
        Self { value in
            if range.contains(value) {
                return .valid(value)
            }
            return .error("must be in range \(range)")
        }
    }
    
    /// Validates that a value is within the given range.
    ///
    /// - Parameters:
    ///     - range: An unclosed range that the value should be within.
    ///
    public static func isInRange(_ range: Range<Value>) -> Self {
        Self { value in
            if range.contains(value) {
                return .valid(value)
            }
            return .error("must be in range \(range)")
        }
    }
}
