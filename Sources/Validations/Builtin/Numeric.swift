extension ValidatorOf where Value == Int, Error == String {
    /// Validates that the value is exactly the given amount.
    ///
    /// This validator is effectively the same as `isEqualTo` but with a slightly modified error message.
    ///
    /// - Parameters:
    ///     - amount: The amount that the value should equal.
    ///
    public static func isExactly(_ amount: Int) -> Self {
        Self.isEqualTo(amount)
            .mapErrors { _ in "must be exactly \(amount)" }
    }
    
    /// Validates that a value is even.
    public static let isEven = Self { value in
        if value % 2 == 0 {
            return .valid(value)
        }
        return .error("must be even")
    }
    
    /// Validates that a value is odd.
    public static let isOdd = isEven.negated(withError: "must be odd")
}
