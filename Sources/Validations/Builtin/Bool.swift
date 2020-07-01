extension ValidatorOf where Value == Bool, Error == String {
    public static let isTrue = Self {
        ($0 == true) ? .valid(true) : .error("must be true")
    }
    
    public static let isFalse = Self {
        ($0 == false) ? .valid(false) : .error("must be false")
    }
}
