extension ValidatorOf where Value == Int, Error == String {
    public static func exactly(_ amount: Int) -> Self {
        Self.equalTo(amount)
            .mapErrors { _ in "must be exactly \(amount)" }
    }
    
    public static let odd = Self { value in
        if value % 2 == 1 {
            return .valid(value)
        }
        return .error("must be odd")
    }
    
    public static let even = Self { value in
        if value % 2 == 0 {
            return .valid(value)
        }
        return .error("must be even")
    }
}
