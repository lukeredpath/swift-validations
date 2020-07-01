extension ValidatorOf where Value == Int, Error == String {
    public static func isExactly(_ amount: Int) -> Self {
        Self.isEqualTo(amount)
            .mapErrors { _ in "must be exactly \(amount)" }
    }
    
    public static let isEven = Self { value in
        if value % 2 == 0 {
            return .valid(value)
        }
        return .error("must be even")
    }
    
    public static let isOdd = isEven.negated(withError: "must be odd")
}
