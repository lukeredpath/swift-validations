extension ValidatorOf where Value: Equatable, Error == String {
    public static func equalTo(_ other: Value) -> Self {
        Self { value in
            if value == other {
                return .valid(value)
            }
            return .error("must be equal to '\(other)'")
        }
    }
}
