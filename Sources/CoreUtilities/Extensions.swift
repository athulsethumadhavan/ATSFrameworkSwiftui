import Foundation
import SwiftUI
import UIKit

// MARK: - String
public extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isBlank: Bool {
        trimmed.isEmpty
    }

    var isValidEmail: Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }
    
    func spaceRemoved() -> String {
        return self.replacingOccurrences(of: " ", with: "%20")
    }
    
    func replaceOccuranceOfPlus() -> String {
        return self.replacingOccurrences(of: "+", with: "%2b")
    }
    
    var imageFromBase64: UIImage? {
        guard let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters),
            let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
}

// MARK: - Date
public extension Date {
    func formatted(_ format: String, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        return formatter.string(from: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}

// MARK: - Task
public extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        try await sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}

// MARK: - Image
public extension Image {
    @MainActor func toBase64String() -> String? {
        let uiImage: UIImage = self.asUIImage()
        if let imageData = uiImage.pngData() {
            return imageData.base64EncodedString()
        }
        return nil
    }
}

// MARK: - View
public extension View {
    func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        controller.view.backgroundColor = .clear
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.connectedScenes
            .compactMap({$0 as? UIWindowScene})
            .flatMap({$0.windows}).first(where: {$0.isKeyWindow})?.rootViewController?.view.addSubview(controller.view)

        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        let image = controller.view.asUIImageComponent()
        controller.view.removeFromSuperview()
        return image
    }
}

// MARK: - UIView
extension UIView {
    func asUIImageComponent() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
