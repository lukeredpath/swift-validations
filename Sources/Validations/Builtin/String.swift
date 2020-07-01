import Foundation

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
    
    public static func itsLength(_ validator: ValidatorOf<Int, Error>) -> Self {
        validator.pullback(\.count).mapErrors { "length \($0)" }
    }
    
    public static func hasLengthOf(_ length: Int) -> Self {
        itsLength(.isExactly(length))
    }
    
    public static func matchesPattern(
        _ pattern: String,
        as options: NSString.CompareOptions = .regularExpression
    ) -> Self {
        Self { value in
            if value.range(of: pattern, options: options) != nil {
                return .valid(value)
            }
            return .error("must match pattern")
        }
    }
    
    public static let isEmpty = Self { value in
        if value == "" {
            return .valid(value)
        }
        return .error("must be empty")
    }
    
    public static let isNotEmpty = isEmpty.negated(withError: "must not be empty")
}

