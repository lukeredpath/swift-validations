extension ValidatorOf where Value: Equatable, Error == String {
    /// Validates that value is equal to another value.
    ///
    /// - Parameters:
    ///     - other: The value to compare against.
    ///
    public static func isEqualTo(_ other: Value) -> Self {
        Self { value in
            if value == other {
                return .valid(value)
            }
            return .error("must be equal to '\(other)'")
        }
    }
}
