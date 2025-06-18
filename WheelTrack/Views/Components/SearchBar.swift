import SwiftUI

// MARK: - FilterChip Component (Compatible avec tous les écrans)
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    init(title: String, isSelected: Bool, color: Color = .blue, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        } else {
                            Color(.systemBackground)
                        }
                    }
                )
                .clipShape(Capsule())
                .shadow(
                    color: isSelected ? color.opacity(0.3) : .black.opacity(0.05),
                    radius: isSelected ? 8 : 2,
                    x: 0,
                    y: isSelected ? 4 : 1
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - ModernSearchBar Component
struct ModernSearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { 
                    withAnimation(.easeInOut(duration: 0.2)) {
                        text = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - ModernCard Component (Deprecated - Use WheelTrack/Views/Components/ModernCard.swift)
// Ce composant est maintenant unifié dans ModernCard.swift

// MARK: - ModernHeaderIcon Component
struct ModernHeaderIcon: View {
    let systemName: String
    let color: Color
    let size: CGFloat
    
    init(systemName: String, color: Color, size: CGFloat = 56) {
        self.systemName = systemName
        self.color = color
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.15), color.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            Image(systemName: systemName)
                .font(.system(size: size * 0.43, weight: .medium))
                .foregroundColor(color)
        }
    }
}

// MARK: - EmptyStateView Component
struct ModernEmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let buttonTitle: String
    let buttonAction: () -> Void
    let color: Color
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 20) {
                // Illustration moderne
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.1), color.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: icon)
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(color.opacity(0.6))
                }
                
                VStack(spacing: 12) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
            }
            
            Button(action: buttonAction) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text(buttonTitle)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [color, color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: color.opacity(0.3), radius: 12, x: 0, y: 6)
            }
        }
        .padding(.vertical, 60)
    }
}

#Preview {
    VStack(spacing: 20) {
        ModernSearchBar(text: .constant(""), placeholder: "Rechercher...")
        
        HStack {
            FilterChip(title: "Tous", isSelected: true, color: .blue) {}
            FilterChip(title: "Récents", isSelected: false, color: .blue) {}
        }
        
        // Exemple simple sans ModernCard
        Text("Contenu de la carte")
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
    }
    .padding()
} 