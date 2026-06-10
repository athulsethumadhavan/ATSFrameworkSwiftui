import SwiftUI

/// Hosts a `NavigationStack` bound to a `Router` and renders destinations,
/// sheets, and full-screen covers from a single view-builder.
///
/// ```swift
/// RouterView(router: router) {
///     HomeView()
/// } destination: { route in
///     switch route {
///     case .profile(let id): ProfileView(userID: id)
///     case .settings: SettingsView()
///     }
/// }
/// ```
public struct RouterView<Route: Routable, Root: View, Destination: View>: View {
    @Bindable private var router: Router<Route>
    private let root: Root
    private let destination: (Route) -> Destination

    public init(
        router: Router<Route>,
        @ViewBuilder root: () -> Root,
        @ViewBuilder destination: @escaping (Route) -> Destination
    ) {
        self.router = router
        self.root = root()
        self.destination = destination
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            root
                .navigationDestination(for: Route.self, destination: destination)
        }
        .sheet(item: $router.presentedSheet, content: destination)
        #if os(iOS)
        .fullScreenCover(item: $router.presentedFullScreen, content: destination)
        #endif
    }
}
