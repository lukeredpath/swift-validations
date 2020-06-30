extension ValidatorOf where Value == String, Error == String {
    public static func beginsWith(_ prefix: String) -> Self {
        Self { value in
            if value.hasPrefix(prefix) {
                return .valid(value)
            }
            return .error("must begin with '\(prefix)'")
        }
    }
    
    public static func endsWith(_ suffix: String) -> Self {
        Self { value in
            if value.hasSuffix(suffix) {
                return .valid(value)
            }
            return .error("must end with '\(suffix)'")
        }
    }
    
    public static func hasLengthOf(_ validator: ValidatorOf<Int, Error>) -> Self {
        return validator.pullback(\.count).mapErrors { "length \($0)" }
    }
}
