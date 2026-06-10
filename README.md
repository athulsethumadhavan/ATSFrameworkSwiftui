# ATSFrameworkSwiftui

Modular Swift package for SwiftUI apps. iOS 17+ / macOS 14+, Swift 5.9.

## Products

| Product | What's inside |
|---|---|
| `Networking` | `WebService` (async/await URLSession), `Endpoint` builder, `NetworkError`, interceptors (bearer token, logging) |
| `Navigation` | `Router` (@Observable), `RouterView` (NavigationStack + sheet + fullScreenCover), `DeepLinkHandler` |
| `Storage` | `@UserDefault` property wrapper, `KeychainStore` |
| `UIComponents` | `Shapes` |
| `CoreUtilities` | `LoadingState<T>`, `Debouncer`, common extensions |

## Installation

Xcode → File → Add Package Dependencies → GitHub → Search "https://github.com/athulsethumadhavan/ATSFrameworkSwiftui.git".
Then add the products you need to your app target.
