protocol EnumEnumerable: Hashable {}

extension EnumEnumerable {
    static var generator: AnySequence<Self> {
        return AnySequence { () -> AnyIterator<Self> in
            var counter = 0
            return AnyIterator {
                defer { counter += 1 }
                let current: Self = withUnsafePointer(to: &counter) {
                    $0.withMemoryRebound(to: Self.self, capacity: 1) { $0.pointee }
                }
                guard current.hashValue == counter else { return nil }
                return current
            }
        }
    }

    static var cases: [Self] {
        return Array(generator)
    }
}
