import SwiftUI

/// Batch Reed - Basket Weaving Log's own palette: distinct from every sibling app in the portfolio.
enum BRTheme {
    static let backdrop = Color(red: 0.965, green: 0.949, blue: 0.902)
    static let card = Color.white

    static let ink = Color(red: 0.176, green: 0.129, blue: 0.078)
    static let inkFaded = Color(red: 0.176, green: 0.129, blue: 0.078).opacity(0.56)

    static let accent = Color(red: 0.588, green: 0.396, blue: 0.204)
    static let accentDeep = Color(red: 0.508, green: 0.316, blue: 0.12399999999999999)
    static let accent2 = Color(red: 0.286, green: 0.494, blue: 0.31)

    static let rule = Color.black.opacity(0.06)

    static let titleFont = Font.system(.title2, design: .rounded).weight(.bold)
    static let displayFont = Font.system(size: 40, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.semibold)
}

struct BRDismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(BRDismissKeyboardOnTap())
    }
}

enum BRHaptics {
    static var enabled: Bool = true

    static func light() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
