extension ValidatorOf where Value == Bool, Error == String {
    /// Validates that a boolean value is true.
    public static let isTrue = Self {
        ($0 == true) ? .valid(true) : .error("must be true")
    }
    
    /// Validates that a boolean value is false.
    public static let isFalse = isTrue
        .negated(withError: "must be false")
}
