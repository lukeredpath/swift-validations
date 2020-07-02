extension ValidatorOf where Value: Equatable, Error == String {
    /// Validates that a value is in a given collection.
    ///
    /// This validation makes it possible to validate that a value is one of a given list of values.
    ///
    /// - Parameters:
    ///     - collection: An array of valid values.
    ///
    public static func isIncluded(in collection: [Value]) -> Self {
        Self { value in
            if collection.contains(value) {
                return .valid(value)
            }
            return .error("must be included in \(collection)")
        }
    }
    
    /// Validates that a value is not in a given collection.
    ///
    /// This validation makes it possible to validate that a value is not one of a given list of values.
    ///
    /// - Parameters:
    ///     - collection: A list of invalid values.
    ///
    public static func isExcluded(from collection: [Value]) -> Self {
        isIncluded(in: collection).negated(withError: "must be excluded from \(collection)")
    }
}

extension ValidatorOf where Value: Hashable, Error == String {
    /// Validates that a value is in a given collection.
    ///
    /// This validation makes it possible to validate that a value is one of a given list of values.
    ///
    /// - Parameters:
    ///     - collection: An set of valid values.
    ///
    public static func isIncluded(in set: Set<Value>) -> Self {
        Self { value in
            if set.contains(value) {
                return .valid(value)
            }
            return .error("must be included in set")
        }
    }
    
    /// Validates that a value is not in a given collection.
    ///
    /// This validation makes it possible to validate that a value is not one of a given list of values.
    ///
    /// - Parameters:
    ///     - collection: A set of invalid values.
    ///
    public static func isExcluded(from set: Set<Value>) -> Self {
        isIncluded(in: set).negated(withError: "must be excluded from set")
    }
}
