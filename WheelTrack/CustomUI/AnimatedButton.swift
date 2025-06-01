import SwiftUI

/// Bouton animé réutilisable (rebond au clic)
struct AnimatedButton: View {
    let title: String
    let action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                pressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation { pressed = false }
                action()
            }
        }) {
            Text(title)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(pressed ? Color.blue.opacity(0.7) : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .scaleEffect(pressed ? 0.92 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AnimatedButton(title: "Clique-moi !") {
        print("Bouton animé cliqué !")
    }
}

/*
// Pour utiliser ce composant :
AnimatedButton(title: "Valider") {
    // Action à exécuter
}
*/ 