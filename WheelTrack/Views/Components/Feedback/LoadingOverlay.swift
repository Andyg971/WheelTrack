import SwiftUI

/// Overlay de chargement moderne avec indicateur de progression
struct LoadingOverlay: View {
    @EnvironmentObject var localizationService: LocalizationService
    
    var body: some View {
        ZStack {
            // Arrière-plan semi-transparent
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // Conteneur du spinner
            VStack(spacing: 16) {
                // Spinner moderne
                ProgressView()
                    .scaleEffect(1.2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                // Message de chargement
                Text(L(CommonTranslations.syncingData))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
        }
        .animation(.easeInOut(duration: 0.2), value: true)
    }
}

#Preview {
    LoadingOverlay()
        .environmentObject(LocalizationService.shared)
}
