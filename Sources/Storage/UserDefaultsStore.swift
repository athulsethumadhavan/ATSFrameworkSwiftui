import Foundation

/// Type-safe property wrapper over `UserDefaults` for Codable values.
///
/// ```swift
/// enum Prefs {
///     @UserDefault("hasSeenOnboarding", default: false)
///     static var hasSeenOnboarding: Bool
/// }
/// ```
@propertyWrapper
public struct UserDefault<Value: Codable> {
    private let key: String
    private let defaultValue: Value
    private let store: UserDefaults

    public init(_ key: String, default defaultValue: Value, store: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.store = store
    }

    public var wrappedValue: Value {
        get {
            guard let data = store.data(forKey: key),
                  let value = try? JSONDecoder().decode(Value.self, from: data)
            else { return defaultValue }
            return value
        }
        nonmutating set {
            if let data = try? JSONEncoder().encode(newValue) {
                store.set(data, forKey: key)
            }
        }
    }
}
