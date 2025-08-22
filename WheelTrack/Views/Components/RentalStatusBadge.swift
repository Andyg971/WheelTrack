import SwiftUI

// Badge pour afficher le statut de location d'un véhicule
struct RentalStatusBadge: View {
    let vehicle: Vehicle
    private var rentalService: RentalService { RentalService.shared }
    
    // ✅ Timer pour mettre à jour automatiquement les statuts des contrats
    @State private var updateTimer: Timer?
    
    private var activeContracts: [RentalContract] {
        rentalService.getRentalContracts(for: vehicle.id).filter { $0.isActive() }
    }
    
    private var upcomingContracts: [RentalContract] {
        let now = Date()
        return rentalService.getRentalContracts(for: vehicle.id).filter { $0.startDate > now }
    }
    
    // ✅ Nouveaux contrats pré-remplis
    private var prefilledContracts: [RentalContract] {
        rentalService.getRentalContracts(for: vehicle.id).filter { 
            $0.renterName.trimmingCharacters(in: .whitespaces).isEmpty 
        }
    }
    
    var body: some View {
        Group {
            if !prefilledContracts.isEmpty {
                // ✅ Badge orange pour contrats pré-remplis (vérifié en premier)
                Text(L(("Prêt", "Ready")))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .clipShape(Capsule())
                    .fixedSize(horizontal: true, vertical: false)
            } else if !activeContracts.isEmpty {
                Text(L(("En location", "Rented")))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .clipShape(Capsule())
                    .fixedSize(horizontal: true, vertical: false)
            } else if !upcomingContracts.isEmpty {
                Text(L(("À venir", "Upcoming")))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .clipShape(Capsule())
                    .fixedSize(horizontal: true, vertical: false)
            } else {
                Text(L(CommonTranslations.available))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .onAppear {
            startPeriodicUpdates()
        }
        .onDisappear {
            stopPeriodicUpdates()
        }
    }
    
    // MARK: - Timer Management
    
    /// Démarre les mises à jour périodiques pour détecter automatiquement les contrats expirés
    private func startPeriodicUpdates() {
        // Vérifie toutes les 10 minutes si des contrats ont expiré
        updateTimer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { _ in
            // Force la mise à jour des vues en déclenchant une notification d'objectWillChange
            DispatchQueue.main.async {
                rentalService.objectWillChange.send()
            }
        }
        
        // Démarre aussi une vérification immédiate au démarrage
        rentalService.objectWillChange.send()
        
        print("🔄 RentalStatusBadge - Timer de mise à jour des contrats démarré")
    }
    
    /// Arrête les mises à jour périodiques
    private func stopPeriodicUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
        print("🔄 RentalStatusBadge - Timer de mise à jour des contrats arrêté")
    }
}

#Preview {
    // Exemple de preview avec un véhicule de test
    RentalStatusBadge(vehicle: Vehicle(
        brand: "Toyota",
        model: "Camry",
        year: 2023,
        licensePlate: "ABC-123",
        mileage: 15000,
        fuelType: .gasoline,
        transmission: .automatic,
        color: "Bleu",
        purchaseDate: Date(),
        purchasePrice: 25000,
        purchaseMileage: 10000
    ))
} 