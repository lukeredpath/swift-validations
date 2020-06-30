extension ValidatorOf where Value: Collection, Error == String {
    public static func hasLengthOf(_ validator: ValidatorOf<Int, Error>) -> Self {
        return validator.pullback(\.count)
    }
}

extension ValidatorOf where Value: Collection, Value.Element: Equatable, Error == String {
    public static func contains(_ element: Value.Element) -> Self {
        Self { value in
            if value.contains(element) {
                return .valid(value)
            }
            return .error("must contain \(element)")
        }
    }
}
