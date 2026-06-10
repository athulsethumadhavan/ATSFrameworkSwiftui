import SwiftUI
import Observation

/// Observable router driving a `NavigationStack`, sheets, and full-screen covers.
///
/// Generic over your app's route type:
///
/// ```swift
/// enum AppRoute: Routable {
///     case profile(userID: Int)
///     case settings
///
///     var id: String {
///         switch self {
///         case .profile(let id): "profile-\(id)"
///         case .settings: "settings"
///         }
///     }
/// }
///
/// let router = Router<AppRoute>()
/// router.push(.profile(userID: 42))
/// ```
public protocol Routable: Hashable, Identifiable, Sendable {}

public extension Routable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Observable
@MainActor
public final class Router<Route: Routable> {
    public var path: [Route] = []
    public var presentedSheet: Route?
    public var presentedFullScreen: Route?

    public init() {}

    // MARK: Stack

    public func push(_ route: Route) {
        path.append(route)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path.removeAll()
    }

    /// Replaces the entire stack (useful for deep links).
    public func setStack(_ routes: [Route]) {
        path = routes
    }

    // MARK: Modals

    public func presentSheet(_ route: Route) {
        presentedSheet = route
    }

    public func presentFullScreen(_ route: Route) {
        presentedFullScreen = route
    }

    public func dismissModal() {
        presentedSheet = nil
        presentedFullScreen = nil
    }
}
