extension ValidatorOf where Value == Int, Error == String {
    public static func atLeast(_ minimum: Int) -> Self {
        Self { value in
            if value >= minimum {
                return .valid(value)
            }
            return .error("must be at least \(minimum)")
        }
    }
    
    public static func atMost(_ maximum: Int) -> Self {
        Self { value in
            if value <= maximum {
                return .valid(value)
            }
            return .error("must be at most \(maximum)")
        }
    }
    
    public static func exactly(_ amount: Int) -> Self {
        Self.equalTo(amount)
            .mapErrors { _ in "must be exactly \(amount)" }
    }
    
    public static func lessThan(_ upperBound: Int) -> Self {
        Self { value in
            if value < upperBound {
                return .valid(value)
            }
            return .error("must be less than \(upperBound)")
        }
    }
    
    public static func greaterThan(_ lowerBound: Int) -> Self {
        Self { value in
            if value > lowerBound {
                return .valid(value)
            }
            return .error("must be greater than \(lowerBound)")
        }
    }
    
    public static let odd = Self { value in
        if value % 2 == 1 {
            return .valid(value)
        }
        return .error("must be odd")
    }
    
    public static let even = Self { value in
        if value % 2 == 0 {
            return .valid(value)
        }
        return .error("must be even")
    }
}
