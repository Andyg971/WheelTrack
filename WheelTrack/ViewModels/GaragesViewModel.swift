import Foundation
import SwiftUI
import CoreLocation

/// ViewModel pour la gestion des garages
/// Ce ViewModel gère la liste des garages et leurs données
@MainActor
class GaragesViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Liste de tous les garages
    @Published var garages: [Garage] = []
    
    /// État de chargement
    @Published var isLoading = false
    
    /// Message d'erreur s'il y en a un
    @Published var errorMessage: String? = nil
    
    // MARK: - Services
    
    private let cloudKitService = CloudKitGarageService()
    
    // MARK: - Initialisation
    
    init() {
        loadGarages()
    }
    
    // MARK: - Méthodes publiques
    
    /// Charge tous les garages
    func loadGarages() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let loadedGarages = try await cloudKitService.fetchGarages()
                await MainActor.run {
                    self.garages = loadedGarages
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Erreur lors du chargement des garages: \(error.localizedDescription)"
                    self.isLoading = false
                    // Charger des données d'exemple en cas d'erreur
                    self.loadSampleData()
                }
            }
        }
    }
    
    /// Ajoute un nouveau garage
    func addGarage(_ garage: Garage) {
        Task {
            do {
                try await cloudKitService.saveGarage(garage)
                await MainActor.run {
                    self.garages.append(garage)
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Erreur lors de l'ajout du garage: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Supprime un garage
    func deleteGarage(_ garage: Garage) {
        Task {
            do {
                try await cloudKitService.deleteGarage(garage)
                await MainActor.run {
                    self.garages.removeAll { $0.id == garage.id }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Erreur lors de la suppression du garage: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Met à jour un garage existant
    func updateGarage(_ garage: Garage) {
        Task {
            do {
                try await cloudKitService.updateGarage(garage)
                await MainActor.run {
                    if let index = self.garages.firstIndex(where: { $0.id == garage.id }) {
                        self.garages[index] = garage
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Erreur lors de la mise à jour du garage: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Actualise la liste des garages
    func refreshGarages() {
        loadGarages()
    }
    
    /// Filtre les garages par proximité géographique
    func garagesNearLocation(_ location: CLLocation, radiusInKm: Double = 10.0) -> [Garage] {
        return garages.filter { garage in
            let garageLocation = CLLocation(latitude: garage.latitude, longitude: garage.longitude)
            let distance = location.distance(from: garageLocation)
            return distance <= (radiusInKm * 1000) // Conversion en mètres
        }
    }
    
    /// Trie les garages par distance depuis une localisation
    func garagesSortedByDistance(from location: CLLocation) -> [Garage] {
        return garages.sorted { garage1, garage2 in
            let location1 = CLLocation(latitude: garage1.latitude, longitude: garage1.longitude)
            let location2 = CLLocation(latitude: garage2.latitude, longitude: garage2.longitude)
            
            let distance1 = location.distance(from: location1)
            let distance2 = location.distance(from: location2)
            
            return distance1 < distance2
        }
    }
    
    /// Bascule le statut favori d'un garage
    func toggleFavorite(_ garage: Garage) {
        if let index = garages.firstIndex(where: { $0.id == garage.id }) {
            garages[index].isFavorite.toggle()
            
            // Sauvegarder la modification dans CloudKit
            Task {
                do {
                    try await cloudKitService.updateGarage(garages[index])
                } catch {
                    await MainActor.run {
                        // En cas d'erreur, revenir à l'état précédent
                        self.garages[index].isFavorite.toggle()
                        self.errorMessage = "Erreur lors de la mise à jour du favori: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    // MARK: - Méthodes privées
    
    /// Charge des données d'exemple pour les tests
    private func loadSampleData() {
        garages = [
            Garage(
                id: UUID(),
                nom: "Garage Citroën Lyon Vaise",
                adresse: "47 Avenue Barthélémy Buyer, 69009 Lyon",
                ville: "Lyon",
                telephone: "04 72 85 20 30",
                services: ["Vidange", "Révision", "Pneumatiques", "Freinage"],
                horaires: "Lun-Ven: 8h-18h, Sam: 8h-12h",
                latitude: 45.7833,
                longitude: 4.8029,
                isFavorite: false
            ),
            Garage(
                id: UUID(),
                nom: "Euro Repar Car Service",
                adresse: "12 Rue de la République, 69002 Lyon",
                ville: "Lyon",
                telephone: "04 78 37 42 15",
                services: ["Réparation", "Diagnostic", "Climatisation", "Carrosserie"],
                horaires: "Lun-Ven: 7h30-19h, Sam: 8h-16h",
                latitude: 45.7640,
                longitude: 4.8357,
                isFavorite: false
            ),
            Garage(
                id: UUID(),
                nom: "Garage Renault Lyon Part-Dieu",
                adresse: "78 Boulevard Vivier Merle, 69003 Lyon",
                ville: "Lyon",
                telephone: "04 72 60 85 47",
                services: ["Mécanique générale", "Électricité auto", "Dépannage"],
                horaires: "Lun-Ven: 8h-17h30",
                latitude: 45.7606,
                longitude: 4.8566,
                isFavorite: false
            ),
            Garage(
                id: UUID(),
                nom: "Speedy Lyon Bellecour",
                adresse: "25 Cours Franklin Roosevelt, 69006 Lyon",
                ville: "Lyon",
                telephone: "04 78 52 73 64",
                services: ["Vidange express", "Contrôle technique", "Pneumatiques"],
                horaires: "Lun-Ven: 9h-18h, Sam: 9h-13h",
                latitude: 45.7578,
                longitude: 4.8320,
                isFavorite: false
            ),
            Garage(
                id: UUID(),
                nom: "Feu Vert Lyon Villeurbanne",
                adresse: "89 Cours Emile Zola, 69100 Villeurbanne",
                ville: "Villeurbanne",
                telephone: "04 72 44 29 46",
                services: ["Réparation toutes marques", "Peinture", "Contrôle technique"],
                horaires: "Lun-Ven: 8h-18h",
                latitude: 45.7713,
                longitude: 4.8951,
                isFavorite: false
            )
        ]
    }
} 