extension ValidatorOf where Value == Int, Error == String {
    public static func isExactly(_ amount: Int) -> Self {
        Self.isEqualTo(amount)
            .mapErrors { _ in "must be exactly \(amount)" }
    }
    
    public static let isOdd = Self { value in
        if value % 2 == 1 {
            return .valid(value)
        }
        return .error("must be odd")
    }
    
    public static let isEven = Self { value in
        if value % 2 == 0 {
            return .valid(value)
        }
        return .error("must be even")
    }
}
