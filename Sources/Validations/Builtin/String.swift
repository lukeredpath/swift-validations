import Foundation

extension ValidatorOf where Value == String, Error == String {
    /// Validates that a string starts with a given prefix.
    ///
    /// - Parameters:
    ///     - prefix: The expected prefix.
    ///
    public static func beginsWith(_ prefix: String) -> Self {
        Self { value in
            if value.hasPrefix(prefix) {
                return .valid(value)
            }
            return .error("must begin with '\(prefix)'")
        }
    }
    
    /// Validates that a string ends with a given suffix.
    ///
    /// - Parameters:
    ///     - suffix: The expected suffix.
    ///
    public static func endsWith(_ suffix: String) -> Self {
        Self { value in
            if value.hasSuffix(suffix) {
                return .valid(value)
            }
            return .error("must end with '\(suffix)'")
        }
    }
    
    /// Validates that the string's length matches the given numeric validator.
    ///
    /// - Parameters:
    ///     - validator: Used to validate the string's `count`
    ///
    public static func itsLength(_ validator: ValidatorOf<Int, Error>) -> Self {
        validator.pullback(\.count).mapErrors { "length \($0)" }
    }
    
    
    /// Validates that the string's length is equal to the given length.
    ///
    /// - Parameters:
    ///     - length: The expected length.
    ///
    /// This is shorthand for `.itsLength(.isExactly(length))`.
    ///
    public static func hasLengthOf(_ length: Int) -> Self {
        itsLength(.isExactly(length))
    }
    
    /// Validates that a string matches the given pattern.
    ///
    /// This allows you to validate a string against a regular expression or any other supported string comparison type.
    ///
    /// - Parameters:
    ///     - options: String comparison options, defaults to using regular expressions.
    ///
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
    
    /// Validates that string is an empty string (i.e. `""`).
    public static let isEmpty = Self { value in
        if value == "" {
            return .valid(value)
        }
        return .error("must be empty")
    }
    
    /// Validates that a string is non-empty.
    public static let isNotEmpty = isEmpty.negated(withError: "must not be empty")
}

