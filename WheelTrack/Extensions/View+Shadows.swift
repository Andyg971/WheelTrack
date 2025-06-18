import SwiftUI

// MARK: - Standardized Shadow System
public extension View {
    /// Applique une ombre légère standardisée
    func lightShadow() -> some View {
        self.shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    /// Applique une ombre moyenne standardisée (par défaut)
    func mediumShadow() -> some View {
        self.shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    /// Applique une ombre forte standardisée
    func strongShadow() -> some View {
        self.shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
    }
    
    /// Applique une ombre colorée pour les boutons
    func coloredShadow(_ color: Color, intensity: CGFloat = 0.3) -> some View {
        self.shadow(color: color.opacity(intensity), radius: 8, x: 0, y: 4)
    }
} 