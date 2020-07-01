extension ValidatorOf where Value: Equatable, Error == String {
    public static func isIncluded(in collection: [Value]) -> Self {
        Self { value in
            if collection.contains(value) {
                return .valid(value)
            }
            return .error("must be included in \(collection)")
        }
    }
    
    public static func isExcluded(from collection: [Value]) -> Self {
        isIncluded(in: collection).negated(withError: "must be excluded from \(collection)")
    }
}

extension ValidatorOf where Value: Hashable, Error == String {
    public static func isIncluded(in set: Set<Value>) -> Self {
        Self { value in
            if set.contains(value) {
                return .valid(value)
            }
            return .error("must be included in set")
        }
    }
    
    public static func isExcluded(from set: Set<Value>) -> Self {
        isIncluded(in: set).negated(withError: "must be excluded from set")
    }
}
