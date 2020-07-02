extension ValidatorOf where Value: Collection, Error == String {
    /// Validates the collection's count against the given numeric validator.
    ///
    /// This validator allows you to flexibly validate the collection count using any other `Int` validator, for example:
    ///
    ///     .hasLengthOf(.greaterThan(1))
    ///
    /// - Parameters:
    ///     - validator: A numeric validator used to validate the collection's `count`.
    ///
    public static func hasLengthOf(_ validator: ValidatorOf<Int, Error>) -> Self {
        return validator.pullback(\.count)
    }
    
    /// Validates the collection's count is exactly the given value.
    ///
    /// This validator is a convenience and is equivalent to passing `.isExactly(count)` to `hasLengthOf(validator:)`.
    ///
    /// - Parameters:
    ///     - count: The collection's expected count.
    ///
    public static func hasLengthOf(_ count: Int) -> Self {
        return ValidatorOf<Int, String>.isExactly(count).pullback(\.count)
    }
}

extension ValidatorOf where Value: Collection, Value.Element: Equatable, Error == String {
    /// Validate that the collection contains the given element.
    ///
    /// - Parameters:
    ///     - element: The element that the collection is expected to contain.
    ///
    public static func contains(_ element: Value.Element) -> Self {
        Self { value in
            if value.contains(element) {
                return .valid(value)
            }
            return .error("must contain \(element)")
        }
    }
}
