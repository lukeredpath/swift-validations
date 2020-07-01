extension ValidatorOf where Value == Bool, Error == String {
    public static let isTrue = Self {
        ($0 == true) ? .valid(true) : .error("must be true")
    }
    
    public static let isFalse = isTrue
        .negated(withError: "must be false")
}
