import Foundation

///
/// ```swift
/// let debouncer = Debouncer(delay: 0.3)
/// // in onChange(of: searchText):
/// debouncer.call { await viewModel.search(text) }
/// ```
@MainActor
public final class Debouncer {
    private let delay: Double
    private var task: Task<Void, Never>?

    public init(delay: Double) {
        self.delay = delay
    }

    public func call(_ action: @escaping @MainActor () async -> Void) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(seconds: delay)
            guard !Task.isCancelled else { return }
            await action()
        }
    }

    public func cancel() {
        task?.cancel()
    }
}
