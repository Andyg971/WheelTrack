import SwiftUI

// MARK: - View Extension for TextEditor Placeholder
public extension View {
    /// Ajoute un placeholder à un TextEditor ou tout autre View
    /// - Parameters:
    ///   - shouldShow: Condition pour afficher le placeholder
    ///   - alignment: Alignement du placeholder (par défaut: topLeading)
    ///   - placeholder: Le contenu du placeholder
    /// - Returns: Une vue avec le placeholder superposé
    @ViewBuilder
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .topLeading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
} 