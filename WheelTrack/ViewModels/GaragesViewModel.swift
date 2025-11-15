import Foundation
import SwiftUI
import CoreLocation
import MapKit

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
    
    /// Indique si la géolocalisation est activée
    @Published var locationBasedGaragesLoaded = false
    
    // MARK: - Services
    
    private let cloudKitService = CloudKitGarageService()
    private let locationService = LocationService.shared
    private let cloudKitCache = CloudKitCacheService()
    
    // ✅ Cache pour optimiser les performances
    private var cachedGarages: [Garage] = []
    private var lastCacheTime: Date?
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutes
    
    // MARK: - Initialisation
    
    init() {
        loadGarages()
        setupLocationObserver()
    }
    
    // MARK: - Méthodes publiques
    
    /// Charge tous les garages avec cache optimisé
    func loadGarages() {
        // ✅ 1. Affichage immédiat du cache si disponible
        if let lastCache = lastCacheTime,
           Date().timeIntervalSince(lastCache) < cacheValidityDuration,
           !cachedGarages.isEmpty {
            garages = cachedGarages
            print("✅ Garages chargés depuis le cache (\(cachedGarages.count) garages)")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            // ✅ 2. Exécution en parallèle : CloudKit + Garages proches
            async let cloudKitGarages = fetchCloudKitGarages()
            async let nearbyGarages = fetchNearbyGaragesAsync()
            
            let (cloudGarages, locationGarages) = await (cloudKitGarages, nearbyGarages)
            
            await MainActor.run {
                // Combiner les résultats
                var allGarages = cloudGarages
                
                // Ajouter les garages proches s'il n'y a pas de doublons
                for nearbyGarage in locationGarages {
                    let isDuplicate = allGarages.contains { existingGarage in
                        self.distance(from: nearbyGarage, to: existingGarage) < 100
                    }
                    if !isDuplicate {
                        allGarages.append(nearbyGarage)
                    }
                }
                
                self.garages = allGarages
                self.isLoading = false
                
                // ✅ 3. Mise en cache pour la prochaine fois
                self.cachedGarages = allGarages
                self.lastCacheTime = Date()
                
                print("✅ Garages chargés et mis en cache (\(allGarages.count) garages)")
            }
        }
    }
    
    /// Récupère les garages CloudKit de façon asynchrone
    private func fetchCloudKitGarages() async -> [Garage] {
        do {
            return try await cloudKitService.fetchGarages()
        } catch {
            print("⚠️ Erreur CloudKit: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Récupère les garages proches de façon asynchrone
    private func fetchNearbyGaragesAsync() async -> [Garage] {
        guard let userLocation = locationService.currentLocation else {
            return []
        }
        return await generateNearbyGarages(location: userLocation, radiusKm: 25.0)
    }
    
    /// Charge des garages proches de la position utilisateur si disponible (OPTIMISÉ)
    func loadNearbyGaragesIfLocationAvailable() {
        // ✅ Vérifier d'abord le cache avant de faire des requêtes réseau
        if let lastCache = lastCacheTime,
           Date().timeIntervalSince(lastCache) < cacheValidityDuration,
           !cachedGarages.isEmpty {
            garages = cachedGarages
            print("✅ Garages proches chargés depuis le cache")
            return
        }
        
        if let userLocation = locationService.currentLocation {
            loadNearbyGarages(near: userLocation)
        } else {
            // Si pas de localisation, ne rien charger (uniquement des vrais garages)
            print("🚫 Géolocalisation requise pour trouver des vrais garages")
        }
    }
    
    /// Charge des garages proches d'une position donnée
    func loadNearbyGarages(near location: CLLocation) {
        Task {
            let nearbyGarages = await generateNearbyGarages(location: location, radiusKm: 25.0)
            await MainActor.run {
                if self.garages.isEmpty {
                    self.garages = nearbyGarages
                    self.locationBasedGaragesLoaded = true
                    print("🏢 \(nearbyGarages.count) garages chargés près de votre position")
                } else {
                    // Ajouter les garages proches aux garages existants (éviter les doublons)
                    let newGarages = nearbyGarages.filter { nearbyGarage in
                        !self.garages.contains { existingGarage in
                            self.distance(from: nearbyGarage, to: existingGarage) < 100 // 100m de tolérance
                        }
                    }
                    self.garages.append(contentsOf: newGarages)
                    self.locationBasedGaragesLoaded = true
                    print("🏢 \(newGarages.count) nouveaux garages ajoutés près de votre position")
                }
            }
        }
    }
    
    /// Actualise les garages basés sur la localisation
    func refreshLocationBasedGarages() {
        guard let userLocation = locationService.currentLocation else {
            errorMessage = "Localisation non disponible"
            return
        }
        
        isLoading = true
        loadNearbyGarages(near: userLocation)
        isLoading = false
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
    
    /// Actualise la liste des garages avec invalidation du cache
    func refreshGarages() {
        // ✅ Invalider le cache pour forcer un rechargement complet
        cachedGarages.removeAll()
        lastCacheTime = nil
        loadGarages()
    }
    
    /// Force l'invalidation du cache
    func invalidateCache() {
        cachedGarages.removeAll()
        lastCacheTime = nil
        print("🗑️ Cache des garages invalidé")
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
    /// NOTE: Cette méthode est désactivée car les favoris sont gérés via UserDefaults dans GaragesView
    /// pour éviter les conflits entre les deux systèmes
    func toggleFavorite(_ garage: Garage) {
        // Cette méthode est désactivée pour éviter les conflits
        // Les favoris sont gérés dans GaragesView avec UserDefaults
        print("⚠️ toggleFavorite désactivé - favoris gérés via UserDefaults dans la vue")
    }
    
    // MARK: - Chargement des horaires à la demande
    
    // Cache des horaires avec durée de validité (24h)
    private let hoursTTL: TimeInterval = 86_400
    private var hoursCache: [String: (value: String, date: Date)] = [:]
    
    /// Charge les horaires d'un garage à la demande, avec cache local, CloudKit partagé et Google API
    func fetchHours(for garage: Garage) async -> String {
        let cacheKey = "\(garage.nom)|\(garage.latitude),\(garage.longitude)"
        
        // 1) Vérifier le cache local en mémoire (le plus rapide)
        if let entry = hoursCache[cacheKey], Date().timeIntervalSince(entry.date) < hoursTTL {
            print("✅ Horaires chargés depuis le cache local pour: \(garage.nom)")
            return entry.value
        }
        
        // 2) Vérifier le cache CloudKit partagé (évite les appels Google)
        if let cloudKitHours = await cloudKitCache.loadHours(placeKey: cacheKey) {
            // Mettre à jour le cache local
            hoursCache[cacheKey] = (cloudKitHours, Date())
            
            // Mettre à jour l'UI
            await updateGarageHours(garage: garage, hours: cloudKitHours)
            return cloudKitHours
        }
        
        // 3) Appel Google Places API (Text Search -> Details)
        let result = await getRealBusinessHours(
            name: garage.nom,
            location: CLLocationCoordinate2D(latitude: garage.latitude, longitude: garage.longitude)
        )
        let value = result ?? L(("Horaires non disponibles", "Hours not available"))
        
        // 4) Mettre à jour les caches (local + CloudKit partagé)
        hoursCache[cacheKey] = (value, Date())
        
        // Sauvegarder dans CloudKit pour les autres utilisateurs (best effort)
        Task.detached(priority: .background) {
            await self.cloudKitCache.saveHours(placeKey: cacheKey, hours: value)
        }
        
        // 5) Mettre à jour l'UI
        await updateGarageHours(garage: garage, hours: value)
        
        return value
    }
    
    /// Met à jour les horaires d'un garage dans la liste
    private func updateGarageHours(garage: Garage, hours: String) async {
        await MainActor.run {
            if let idx = garages.firstIndex(where: { $0.id == garage.id }) {
                let updated = Garage(
                    id: garages[idx].id,
                    nom: garages[idx].nom,
                    adresse: garages[idx].adresse,
                    ville: garages[idx].ville,
                    telephone: garages[idx].telephone,
                    services: garages[idx].services,
                    horaires: hours,
                    latitude: garages[idx].latitude,
                    longitude: garages[idx].longitude,
                    isFavorite: garages[idx].isFavorite
                )
                garages[idx] = updated
            }
        }
    }
    
    // MARK: - Méthodes privées
    
    /// Trouve de vrais garages autour de la position utilisateur avec MapKit (PARALLÉLISÉ)
    private func generateNearbyGarages(location: CLLocation, radiusKm: Double) async -> [Garage] {
        // ✅ Recherche en parallèle pour réduire drastiquement le délai
        let searchTerms = [
            "garage automobile",
            "station-service", 
            "réparation automobile",
            "mécanique auto",
            "garage mécanique",
            "centre auto"
        ]
        
        // ✅ Exécuter toutes les recherches MapKit EN PARALLÈLE au lieu de séquentiellement
        let searchResults = await withTaskGroup(of: [Garage].self) { group in
            var allGarages: [Garage] = []
            
            for searchTerm in searchTerms {
                group.addTask {
                    return await self.searchRealGarages(near: location, searchTerm: searchTerm, radiusKm: radiusKm)
                }
            }
            
            for await garages in group {
                allGarages.append(contentsOf: garages)
            }
            
            return allGarages
        }
        
        // Supprimer les doublons basés sur la proximité (< 100m)
        var realGarages = removeDuplicateGarages(searchResults)
        
        // Limiter à 20 garages maximum et trier par distance
        realGarages = realGarages.sorted { garage1, garage2 in
            let loc1 = CLLocation(latitude: garage1.latitude, longitude: garage1.longitude)
            let loc2 = CLLocation(latitude: garage2.latitude, longitude: garage2.longitude)
            return location.distance(from: loc1) < location.distance(from: loc2)
        }.prefix(20).map { $0 }
        
        print("🏢 \(realGarages.count) vrais garages trouvés en parallèle dans un rayon de \(radiusKm)km")
        
        // ✅ Horaires désactivés en arrière-plan - chargement à la demande uniquement
        // Les horaires seront chargés quand l'utilisateur clique sur "Afficher les horaires"
        
        return realGarages
    }
    

    
    /// Recherche de vrais garages avec MapKit Local Search
    private func searchRealGarages(near location: CLLocation, searchTerm: String, radiusKm: Double) async -> [Garage] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTerm
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radiusKm * 1000 * 2,
            longitudinalMeters: radiusKm * 1000 * 2
        )
        
        let search = MKLocalSearch(request: request)
        var garages: [Garage] = []
        
        do {
            let response = try await search.start()
            
            for item in response.mapItems {
                // Vérifier que c'est bien dans le rayon demandé
                let itemLocation = CLLocation(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)
                let distance = location.distance(from: itemLocation)
                
                guard distance <= (radiusKm * 1000) else { continue }
                
                // Extraire les informations réelles
                let name = item.name ?? "Garage"
                let address = formatAddress(from: item.placemark)
                            let city = item.placemark.locality ?? L(("Ville", "City"))
            let phoneNumber = item.phoneNumber ?? L(CommonTranslations.notAvailable)
                
                // Générer des services réalistes basés sur le type d'établissement
                let services = generateRealisticServices(for: name, category: searchTerm)
                
                // Créer le garage avec horaires temporaires pour un affichage plus rapide
                let garage = Garage(
                    id: UUID(),
                    nom: name,
                    adresse: address,
                    ville: city,
                    telephone: phoneNumber,
                    services: services,
                    horaires: L(("Chargement des horaires...", "Loading hours...")),
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude,
                    isFavorite: false
                )
                
                garages.append(garage)
            }
        } catch {
            print("⚠️ Erreur lors de la recherche de garages: \(error.localizedDescription)")
        }
        
        return garages
    }
    
    /// Formate l'adresse à partir d'un placemark
    private func formatAddress(from placemark: MKPlacemark) -> String {
        var components: [String] = []
        
        if let streetNumber = placemark.subThoroughfare {
            components.append(streetNumber)
        }
        
        if let streetName = placemark.thoroughfare {
            components.append(streetName)
        }
        
        return components.isEmpty ? L(("Adresse non disponible", "Address not available")) : components.joined(separator: " ")
    }
    
    /// Génère des services réalistes selon le type d'établissement
    private func generateRealisticServices(for name: String, category: String) -> [String] {
        let lowercaseName = name.lowercased()
        
        // Services pour stations-service
        if lowercaseName.contains("total") || lowercaseName.contains("shell") || 
           lowercaseName.contains("esso") || lowercaseName.contains("bp") ||
           category.contains("station-service") {
            return ["Carburant", "Lavage auto", "Gonflage pneus", "Boutique"]
        }
        
        // Services pour garages spécialisés
        if lowercaseName.contains("speedy") || lowercaseName.contains("midas") || 
           lowercaseName.contains("norauto") || lowercaseName.contains("feu vert") {
            return ["Vidange", "Pneumatiques", "Freinage", "Amortisseurs", "Échappement"]
        }
        
        // Services pour garages de marque
        if lowercaseName.contains("renault") || lowercaseName.contains("peugeot") || 
           lowercaseName.contains("citroën") || lowercaseName.contains("ford") {
            return ["Révision", "Réparation", "Pièces d'origine", "Diagnostic", "Garantie"]
        }
        
        // Services généraux pour autres garages
        return ["Mécanique générale", "Réparation", "Entretien", "Diagnostic"]
    }
    
    /// Récupère les vrais horaires depuis Google Places API
    private func getRealBusinessHours(name: String, location: CLLocationCoordinate2D) async -> String? {
        print("🕒 Recherche d'horaires pour: \(name)")
        
        // Recherche du place_id avec Google Places Text Search
        guard let placeId = await findGooglePlaceId(name: name, location: location) else {
            print("❌ Aucun place_id trouvé pour: \(name)")
            return nil
        }
        
        print("✅ Place ID trouvé pour \(name): \(placeId)")
        
        // Récupération des détails incluant les horaires
        let horaires = await getPlaceDetails(placeId: placeId)
        
        if let horaires = horaires {
            print("✅ Horaires récupérés pour \(name): \(horaires)")
        } else {
            print("❌ Aucun horaire disponible pour: \(name)")
        }
        
        return horaires
    }
    
    /// Trouve le place_id Google pour un établissement
    private func findGooglePlaceId(name: String, location: CLLocationCoordinate2D) async -> String? {
        // Clé API Google Places depuis Secrets.plist
        let apiKey = Secrets.googlePlacesKey
        
        // Si pas de clé API configurée, retourner nil
        guard !apiKey.isEmpty else {
            print("⚠️ Clé API Google Places non configurée dans Secrets.plist")
            return nil
        }
        
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(encodedName)&location=\(location.latitude),\(location.longitude)&radius=100&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                // Vérifier s'il y a des erreurs API
                if let error = json["error_message"] as? String {
                    print("🚨 Erreur Google Places API: \(error)")
                    return nil
                }
                
                if let status = json["status"] as? String {
                    print("📡 Status Google Places: \(status)")
                }
                
                if let results = json["results"] as? [[String: Any]],
                   let firstResult = results.first,
                   let placeId = firstResult["place_id"] as? String {
                    return placeId
                } else {
                    print("❌ Aucun résultat trouvé dans la réponse Google Places")
                }
            }
        } catch {
            print("⚠️ Erreur lors de la recherche Google Places: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    /// Récupère les détails d'un lieu Google incluant les horaires
    private func getPlaceDetails(placeId: String) async -> String? {
        let apiKey = Secrets.googlePlacesKey
        
        guard !apiKey.isEmpty else {
            return nil
        }
        
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeId)&fields=opening_hours&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let result = json["result"] as? [String: Any],
               let openingHours = result["opening_hours"] as? [String: Any],
               let weekdayText = openingHours["weekday_text"] as? [String] {
                
                // Formater les horaires en français
                return formatOpeningHours(weekdayText)
            }
        } catch {
            print("⚠️ Erreur lors de la récupération des détails: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    /// Formate les horaires d'ouverture en français
    private func formatOpeningHours(_ weekdayText: [String]) -> String {
        let dayMapping = [
            "Monday": "Lun",
            "Tuesday": "Mar", 
            "Wednesday": "Mer",
            "Thursday": "Jeu",
            "Friday": "Ven",
            "Saturday": "Sam",
            "Sunday": "Dim"
        ]
        
        var formattedHours: [String] = []
        
        for dayText in weekdayText {
            var frenchText = dayText
            
            // Remplacer les jours en anglais par français
            for (english, french) in dayMapping {
                frenchText = frenchText.replacingOccurrences(of: english, with: french)
            }
            
            // Remplacer d'autres termes
            frenchText = frenchText.replacingOccurrences(of: "Closed", with: "Fermé")
            frenchText = frenchText.replacingOccurrences(of: "Open 24 hours", with: "Ouvert 24h/24")
            frenchText = frenchText.replacingOccurrences(of: "AM", with: "h")
            frenchText = frenchText.replacingOccurrences(of: "PM", with: "h")
            
            formattedHours.append(frenchText)
        }
        
        // Grouper les jours consécutifs avec les mêmes horaires
        return groupConsecutiveDays(formattedHours)
    }
    
    /// Groupe les jours consécutifs avec les mêmes horaires
    private func groupConsecutiveDays(_ hours: [String]) -> String {
        if hours.isEmpty { return L(("Horaires non disponibles", "Hours not available")) }
        
        // Si peu d'horaires, les afficher tels quels
        if hours.count <= 3 {
            return hours.joined(separator: ", ")
        }
        
        // Sinon, essayer de regrouper (version simplifiée)
        var grouped: [String] = []
        var i = 0
        
        while i < hours.count {
            if i < hours.count - 1 && hours[i].hasSuffix(hours[i + 1].components(separatedBy: ": ").last ?? "") {
                // Deux jours consécutifs avec mêmes horaires
                let day1 = hours[i].components(separatedBy: ": ").first ?? ""
                let day2 = hours[i + 1].components(separatedBy: ": ").first ?? ""
                let time = hours[i].components(separatedBy: ": ").last ?? ""
                grouped.append("\(day1)-\(day2): \(time)")
                i += 2
            } else {
                grouped.append(hours[i])
                i += 1
            }
        }
        
        return grouped.prefix(3).joined(separator: ", ") + (grouped.count > 3 ? "..." : "")
    }
    
    /// Supprime les garages en doublon basés sur la proximité
    private func removeDuplicateGarages(_ garages: [Garage]) -> [Garage] {
        var uniqueGarages: [Garage] = []
        
        for garage in garages {
            let isDuplicate = uniqueGarages.contains { existingGarage in
                let loc1 = CLLocation(latitude: garage.latitude, longitude: garage.longitude)
                let loc2 = CLLocation(latitude: existingGarage.latitude, longitude: existingGarage.longitude)
                return loc1.distance(from: loc2) < 100 // 100m de tolérance
            }
            
            if !isDuplicate {
                uniqueGarages.append(garage)
            }
        }
        
        return uniqueGarages
    }
    
    /// Calcule la distance entre deux garages
    private func distance(from garage1: Garage, to garage2: Garage) -> Double {
        let location1 = CLLocation(latitude: garage1.latitude, longitude: garage1.longitude)
        let location2 = CLLocation(latitude: garage2.latitude, longitude: garage2.longitude)
        return location1.distance(from: location2)
    }
    

    
    /// Charge les horaires des garages en arrière-plan pour améliorer les performances
    @MainActor
    private func loadBusinessHoursInBackground(for garages: [Garage]) async {
        for garage in garages {
            // Trouver l'index du garage dans la liste actuelle
            if let garageIndex = self.garages.firstIndex(where: { $0.id == garage.id }) {
                // Récupérer les vrais horaires
                let realHours = await getRealBusinessHours(name: garage.nom, location: CLLocationCoordinate2D(latitude: garage.latitude, longitude: garage.longitude))
                
                // Mettre à jour les horaires dans la liste
                let updatedHours = realHours ?? L(("Horaires non disponibles", "Hours not available"))
                let updatedGarage = self.garages[garageIndex]
                
                // Créer un nouveau garage avec les horaires mis à jour
                let newGarage = Garage(
                    id: updatedGarage.id,
                    nom: updatedGarage.nom,
                    adresse: updatedGarage.adresse,
                    ville: updatedGarage.ville,
                    telephone: updatedGarage.telephone,
                    services: updatedGarage.services,
                    horaires: updatedHours,
                    latitude: updatedGarage.latitude,
                    longitude: updatedGarage.longitude,
                    isFavorite: updatedGarage.isFavorite
                )
                
                self.garages[garageIndex] = newGarage
                print("✅ Horaires mis à jour pour: \(garage.nom)")
            }
            
            // ✅ Pause réduite pour un chargement plus rapide tout en respectant les limites API
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconde
        }
    }
    
    private func setupLocationObserver() {
        // Observer les changements de localisation
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("LocationUpdated"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                if let self = self, !self.locationBasedGaragesLoaded {
                    self.loadNearbyGaragesIfLocationAvailable()
                }
            }
        }
    }
} 