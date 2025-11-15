import SwiftUI
import MapKit
import CoreLocation

public struct GaragesView: View {
    @StateObject private var viewModel = GaragesViewModel()
    @ObservedObject private var locationService = LocationService.shared
    @ObservedObject private var freemiumService = FreemiumService.shared
    @State private var favoriteGarages: Set<String> = []  // IDs des garages favoris
    @State private var showingLocationAlert = false
    @State private var showOnlyFavorites = false  // Nouveau toggle pour les favoris
    @State private var showingLocationPrompt = false
    @State private var showingAddGarage = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // ✅ Migration vers système centralisé
    @EnvironmentObject var localizationService: LocalizationService

    public init() {
        // Charger les favoris existants depuis UserDefaults
        if let savedFavorites = UserDefaults.standard.array(forKey: "favoriteGarages") as? [String] {
            _favoriteGarages = State<Set<String>>(initialValue: Set(savedFavorites))
        } else {
            _favoriteGarages = State<Set<String>>(initialValue: Set<String>())
        }
        
        print("🏢 GaragesView initialisée avec \(_favoriteGarages.wrappedValue.count) favoris")
    }
    

    
    // Propriété calculée pour filtrer les garages
    private var displayedGarages: [Garage] {
        if showOnlyFavorites {
            return viewModel.garages.filter { favoriteGarages.contains($0.id.uuidString) }
        } else {
            return viewModel.garages
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if freemiumService.hasAccess(to: .garageModule) {
                    // Vue liste des garages uniquement
                    garageListView
                } else {
                    PremiumOverlay(feature: .garageModule)
                }
            }
            .navigationTitle(showOnlyFavorites ? L(CommonTranslations.myFavorites) : L(CommonTranslations.myGarages))
            .navigationBarTitleDisplayMode(.large)

            .onAppear {
                // Demander la géolocalisation si pas encore autorisée
                if locationService.currentLocation == nil {
                    locationService.requestLocationPermission()
                }
            }
            // ✅ Optimisation de la réactivité du service
            .onChange(of: viewModel.garages.count) {
                // Force la mise à jour de l'affichage quand les garages changent
            }
            .alert(L(CommonTranslations.locationRequired), isPresented: $showingLocationAlert) {
                Button(L(CommonTranslations.settings)) {
                    openSettings()
                }
                Button(L(CommonTranslations.later), role: .cancel) { }
            } message: {
                Text(L(CommonTranslations.locationRequiredMessage))
            }
            .sheet(isPresented: $freemiumService.showUpgradeAlert) {
                if let blockedFeature = freemiumService.blockedFeature {
                    NavigationView {
                        PremiumUpgradeAlert(feature: blockedFeature)
                    }
                }
            }
        }
    }
    
    // MARK: - Garages List View
    private var garageListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Message d'état de la géolocalisation (seulement en mode tous les garages)
                if !showOnlyFavorites {
                    locationStatusView
                }
                
                // Bouton pour basculer entre favoris et tous les garages
                HStack {
                    Text(showOnlyFavorites ? L(CommonTranslations.myFavorites) : L(CommonTranslations.myGarages))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Menu d'actions pour les garages
                    Menu {
                        Button {
                            refreshNearbyGarages()
                        } label: {
                            Label(L(CommonTranslations.nearbyGarages), systemImage: "location.circle.fill")
                        }
                        
                        Button {
                            openAppleMapsWithPOI()
                        } label: {
                            Label(L(CommonTranslations.openAppleMaps), systemImage: "map.fill")
                        }
                        
                        if favoriteGarages.count > 0 {
                            Divider()
                            Button(role: .destructive) {
                                clearAllFavorites()
                            } label: {
                                Label(L(CommonTranslations.deleteAllFavorites), systemImage: "star.slash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showOnlyFavorites.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: showOnlyFavorites ? "star.fill" : "star")
                                .font(.body)
                                .fontWeight(.semibold)
                            Text(showOnlyFavorites ? L(CommonTranslations.all) : L(CommonTranslations.favorites))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: showOnlyFavorites ? 
                                    [Color.yellow, Color.orange] : 
                                    [Color.gray, Color.gray.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: showOnlyFavorites ? .yellow.opacity(0.3) : .gray.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .accessibilityIdentifier("favoritesToggleButton")
                    .accessibilityLabel(showOnlyFavorites ? L(CommonTranslations.showAllGarages) : L(CommonTranslations.showOnlyFavorites))
                    .accessibilityHint(L(CommonTranslations.toggleGaragesFavorites))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                // En-tête avec statistiques
                GaragesHeaderView(
                    garageCount: displayedGarages.count,
                    favoriteCount: favoriteGarages.count,
                    locationEnabled: locationService.currentLocation != nil,
                    locationBasedLoaded: viewModel.locationBasedGaragesLoaded,
                    showingFavorites: showOnlyFavorites
                )
                
                // Indicateur de chargement (seulement en mode tous les garages)
                if viewModel.isLoading && !showOnlyFavorites {
                    ProgressView(L(CommonTranslations.searchingNearby))
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                
                // Message si aucun garage
                if displayedGarages.isEmpty && !viewModel.isLoading {
                    if showOnlyFavorites {
                        EmptyFavoritesMessageView(
                            onShowAllGarages: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showOnlyFavorites = false
                                }
                            }
                        )
                    } else {
                        EmptyGaragesView(
                            hasLocation: locationService.currentLocation != nil,
                            onRequestLocation: {
                                locationService.requestLocationPermission()
                            },
                            onRefreshNearby: {
                                refreshNearbyGarages()
                            }
                        )
                    }
                }
                
                // Liste des garages avec favoris
                ForEach(displayedGarages) { garage in
                    ModernGarageCard(
                        garage: garage,
                        isFavorite: favoriteGarages.contains(garage.id.uuidString),
                        onToggleFavorite: { _ in toggleFavorite(garage) },
                        userLocation: locationService.currentLocation?.coordinate,
                        onLoadHours: {
                            _ = await viewModel.fetchHours(for: garage)
                        }
                    )
                }
                
                // Attribution Google Places (obligatoire pour conformité API)
                if !displayedGarages.isEmpty && !showOnlyFavorites {
                    GooglePlacesAttributionView()
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .refreshable {
            // Pull-to-refresh pour actualiser les garages
            if !showOnlyFavorites {
                await refreshGaragesAsync()
            }
        }
    }
    
    // MARK: - Location Status View
    private var locationStatusView: some View {
        Group {
            if locationService.currentLocation == nil {
                LocationPermissionBanner(
                    onRequestPermission: {
                        locationService.requestLocationPermission()
                    },
                    onOpenSettings: {
                        showingLocationAlert = true
                    }
                )
            } else if viewModel.locationBasedGaragesLoaded {
                LocationSuccessBanner()
            }
        }
    }
    
    // MARK: - Actions
    
    private func refreshNearbyGarages() {
        // ✅ Optimisation : Invalider le cache avant le refresh
        viewModel.invalidateCache()
        
        if locationService.currentLocation != nil {
            viewModel.refreshLocationBasedGarages()
        } else {
            showingLocationAlert = true
        }
    }
    
    private func toggleFavorite(_ garage: Garage) {
        // Vérification freemium pour les garages favoris
        if !freemiumService.hasAccess(to: .garageModule) {
            freemiumService.requestUpgrade(for: .garageModule)
            return
        }
        
        let garageId = garage.id.uuidString
        
        if favoriteGarages.contains(garageId) {
            favoriteGarages.remove(garageId)
        } else {
            favoriteGarages.insert(garageId)
        }
        
        // Sauvegarder dans UserDefaults
        UserDefaults.standard.set(Array(favoriteGarages), forKey: "favoriteGarages")
        
        // Animation de feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    /// Ouvre Apple Maps avec votre géolocalisation uniquement
    private func openAppleMapsWithPOI() {
        // Récupérer la position de l'utilisateur ou une position par défaut (Paris)
        let userLocation = locationService.currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
        
        // Créer l'URL pour Apple Maps avec seulement la géolocalisation
        var urlComponents = URLComponents(string: "http://maps.apple.com/")!
        urlComponents.queryItems = [
            URLQueryItem(name: "ll", value: "\(userLocation.latitude),\(userLocation.longitude)"),
            URLQueryItem(name: "z", value: "13") // Niveau de zoom
        ]
        
        if let url = urlComponents.url {
            UIApplication.shared.open(url)
            print("🗺️ Ouverture d'Apple Maps avec géolocalisation uniquement")
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func clearAllFavorites() {
        favoriteGarages.removeAll()
        UserDefaults.standard.removeObject(forKey: "favoriteGarages")
        // Animation de feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Garages Header View
struct GaragesHeaderView: View {
    let garageCount: Int
    let favoriteCount: Int
    let locationEnabled: Bool
    let locationBasedLoaded: Bool
    let showingFavorites: Bool
    // ✅ Migration vers système centralisé
    @EnvironmentObject var localizationService: LocalizationService
    
    // MARK: - Localization
    // ✅ Migration terminée - plus besoin de localText
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(showingFavorites ? L(CommonTranslations.myFavorites) : (locationBasedLoaded ? L(CommonTranslations.nearbyGarages) : L(CommonTranslations.myGarages)))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if showingFavorites {
                        Text("\(garageCount) \(garageCount > 1 ? L(CommonTranslations.favoriteGarages) : L(CommonTranslations.favoriteGarage))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(garageCount) \(garageCount > 1 ? L(CommonTranslations.garagesFound) : L(CommonTranslations.garageFound))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                
                // Icône décorative avec indicateur approprié
                Image(systemName: showingFavorites ? "star.fill" : (locationEnabled ? "location.fill" : "building.2.fill"))
                    .font(.title2)
                    .foregroundColor(showingFavorites ? .yellow : (locationEnabled ? .green : .blue))
                    .frame(width: 44, height: 44)
                    .background((showingFavorites ? Color.yellow : (locationEnabled ? Color.green : Color.blue)).opacity(0.1))
                    .clipShape(Circle())
            }
            
            // Indicateur de statut de localisation (seulement si pas en mode favoris)
            if !showingFavorites && locationBasedLoaded {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(L(CommonTranslations.garagesLoadedLocation))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Statistiques des favoris (seulement si pas en mode favoris)
            if !showingFavorites && favoriteCount > 0 {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(favoriteCount) \(favoriteCount > 1 ? L(CommonTranslations.favoriteGarages) : L(CommonTranslations.favoriteGarage)) \(L(CommonTranslations.inFavorites))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Modern Garage Card
struct ModernGarageCard: View {
    let garage: Garage
    let isFavorite: Bool
    let onToggleFavorite: (Garage) -> Void
    let userLocation: CLLocationCoordinate2D?
    let onLoadHours: () async -> Void
    // ✅ Migration vers système centralisé - @EnvironmentObject utilisé
    
    // Calcul de la distance
    private var distance: String? {
        guard let userLocation = userLocation else { return nil }
        
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let garageCLLocation = CLLocation(latitude: garage.latitude, longitude: garage.longitude)
        let distanceInMeters = userCLLocation.distance(from: garageCLLocation)
        
        if distanceInMeters < 1000 {
            return String(format: "%.0f m", distanceInMeters)
        } else {
            return String(format: "%.1f km", distanceInMeters / 1000)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header avec nom, favori et distance
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(garage.nom)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(garage.ville)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let distance = distance {
                            Text("•")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(distance)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: { onToggleFavorite(garage) }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.title2)
                        .foregroundColor(isFavorite ? .yellow : .gray)
                }
            }
            
            // Informations
            VStack(spacing: 12) {
                ClickableAddressRow(garage: garage)
                ClickablePhoneRow(phoneNumber: garage.telephone)
                OnDemandHoursRow(
                    icon: "clock.fill",
                    title: L(CommonTranslations.hours),
                    value: garage.horaires,
                    color: .orange,
                    onLoad: onLoadHours
                )
                
                // Services disponibles
                if !garage.services.isEmpty {
                    GarageServicesRow(services: garage.services)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Garage Info Row
struct GarageInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

// MARK: - On Demand Hours Row
struct OnDemandHoursRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let onLoad: () async -> Void
    
    @State private var isLoading = false
    
    private var needsFetch: Bool {
        value == L(("Chargement des horaires...", "Loading hours...")) ||
        value == L(("Horaires non disponibles", "Hours not available"))
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if needsFetch {
                    if isLoading {
                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text(L(("Récupération...", "Fetching...")))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Button {
                            isLoading = true
                            Task {
                                await onLoad()
                                isLoading = false
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.caption)
                                Text(L(("Afficher les horaires", "Show hours")))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(color)
                            .clipShape(Capsule())
                        }
                    }
                } else {
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Clickable Phone Row
struct ClickablePhoneRow: View {
    let phoneNumber: String
    // ✅ Migration vers système centralisé - @EnvironmentObject utilisé
    
    private var cleanPhoneNumber: String {
        // Enlève les espaces et formatage pour créer le lien tel:
        phoneNumber.replacingOccurrences(of: " ", with: "")
    }
    
    private var isPhoneAvailable: Bool {
        phoneNumber != L(CommonTranslations.notAvailable) && !phoneNumber.isEmpty
    }
    
    var body: some View {
        if isPhoneAvailable {
            // Numéro cliquable si disponible
            Button(action: {
                makePhoneCall()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L(CommonTranslations.phone))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(phoneNumber)
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "phone.badge.plus")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.green.opacity(0.2), lineWidth: 1)
            )
        } else {
            // Affichage simple si numéro non disponible
            HStack(spacing: 12) {
                Image(systemName: "phone.slash")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                        Text(L(CommonTranslations.phone))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(L(CommonTranslations.notAvailable))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private func makePhoneCall() {
        guard let phoneURL = URL(string: "tel:\(cleanPhoneNumber)") else {
            print("❌ Numéro de téléphone invalide: \(phoneNumber)")
            return
        }
        
        if UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL)
            print("📞 Appel vers \(phoneNumber)")
            
            // Feedback haptique
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        } else {
            print("❌ Impossible d'effectuer l'appel depuis ce dispositif")
        }
    }
}

// MARK: - Garage Services Row
struct GarageServicesRow: View {
    let services: [String]
    // ✅ Migration vers système centralisé - @EnvironmentObject utilisé
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .foregroundColor(.purple)
                    .frame(width: 20)
                
                Text(L(CommonTranslations.services))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 6) {
                ForEach(services.prefix(4), id: \.self) { service in
                    Text(service)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.1))
                        .foregroundColor(.purple)
                        .clipShape(Capsule())
                }
            }
            
            if services.count > 4 {
                Text(String(format: L(CommonTranslations.otherServices), services.count - 4))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Empty Favorites Message View
struct EmptyFavoritesMessageView: View {
    let onShowAllGarages: () -> Void
    // ✅ Migration vers système centralisé - @EnvironmentObject utilisé
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.slash")
                .font(.system(size: 48))
                .foregroundColor(.yellow)
                .frame(width: 80, height: 80)
                .background(Color.yellow.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 8) {
                Text(L(CommonTranslations.noFavoriteGarage))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(L(CommonTranslations.addFavoritesMessage))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(L(CommonTranslations.viewAllGarages)) {
                onShowAllGarages()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(32)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Empty Garages View
struct EmptyGaragesView: View {
    let hasLocation: Bool
    let onRequestLocation: () -> Void
    let onRefreshNearby: () -> Void
    // ✅ Migration vers système centralisé - @EnvironmentObject utilisé
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: hasLocation ? "building.2" : "location.slash")
                .font(.system(size: 48))
                .foregroundColor(.gray)
                .frame(width: 80, height: 80)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 8) {
                Text(hasLocation ? L(CommonTranslations.noGarageFound) : L(CommonTranslations.locationRequiredEmpty))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(hasLocation ? 
                     L(CommonTranslations.tryRefresh) :
                     L(CommonTranslations.authorizeLocation))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if hasLocation {
                Button(L(CommonTranslations.refresh)) {
                    onRefreshNearby()
                }
                .buttonStyle(PrimaryButtonStyle())
            } else {
                Button(L(CommonTranslations.authorizeGeolocation)) {
                    onRequestLocation()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(32)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Location Permission Banner
struct LocationPermissionBanner: View {
    let onRequestPermission: () -> Void
    let onOpenSettings: () -> Void
    // ✅ Migration vers système centralisé - @EnvironmentObject utilisé
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "location.slash")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(L(CommonTranslations.locationDisabled))
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(L(CommonTranslations.authorizeAccess))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Button(L(CommonTranslations.authorize)) {
                    onRequestPermission()
                }
                .buttonStyle(BorderedButtonStyle())
                
                Button(L(CommonTranslations.settings)) {
                    onOpenSettings()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Location Success Banner
struct LocationSuccessBanner: View {
    // ✅ Migration vers système centralisé - @EnvironmentObject utilisé
    
    var body: some View {
        HStack {
            Image(systemName: "location.fill")
                .foregroundColor(.green)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(L(CommonTranslations.nearbyGaragesLoaded))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(L(CommonTranslations.basedCurrentLocation))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Clickable Address Row
struct ClickableAddressRow: View {
    let garage: Garage
    // ✅ Migration vers système centralisé - @EnvironmentObject utilisé
    
    var body: some View {
        Button(action: {
            openInMaps()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(L(CommonTranslations.address))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(garage.adresse)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "map")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func openInMaps() {
        let addressString = "\(garage.adresse), \(garage.ville)"
        
        // Construire l'URL pour Apple Maps avec l'adresse et les coordonnées
        var urlComponents = URLComponents(string: "http://maps.apple.com/")!
        urlComponents.queryItems = [
            URLQueryItem(name: "ll", value: "\(garage.latitude),\(garage.longitude)"),
            URLQueryItem(name: "q", value: garage.nom),
            URLQueryItem(name: "address", value: addressString)
        ]
        
        if let mapsURL = urlComponents.url, UIApplication.shared.canOpenURL(mapsURL) {
            UIApplication.shared.open(mapsURL)
            print("🗺️ Ouverture d'Apple Maps pour: \(garage.nom)")
            
            // Feedback haptique
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        } else {
            print("❌ Impossible d'ouvrir Apple Maps")
        }
    }
}

// MARK: - Google Places Attribution
struct GooglePlacesAttributionView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 6) {
            // Texte "powered by"
            Text("powered by")
                .font(.system(size: 10))
                .foregroundColor(colorScheme == .dark ? Color(white: 0.7) : Color(white: 0.4))
            
            // Logo Google avec les couleurs officielles
            HStack(spacing: 0) {
                Text("G")
                    .foregroundColor(Color(red: 66/255, green: 133/255, blue: 244/255)) // Bleu Google
                Text("o")
                    .foregroundColor(Color(red: 234/255, green: 67/255, blue: 53/255)) // Rouge Google
                Text("o")
                    .foregroundColor(Color(red: 251/255, green: 188/255, blue: 5/255)) // Jaune Google
                Text("g")
                    .foregroundColor(Color(red: 66/255, green: 133/255, blue: 244/255)) // Bleu Google
                Text("l")
                    .foregroundColor(Color(red: 52/255, green: 168/255, blue: 83/255)) // Vert Google
                Text("e")
                    .foregroundColor(Color(red: 234/255, green: 67/255, blue: 53/255)) // Rouge Google
            }
            .font(.system(size: 13, weight: .medium))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .accessibilityLabel("Powered by Google")
    }
}

// MARK: - GaragesView Extension
extension GaragesView {
    /// Actualise les garages de manière asynchrone (pour pull-to-refresh) - OPTIMISÉ
    private func refreshGaragesAsync() async {
        // ✅ Délai réduit pour une meilleure réactivité
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconde
        
        await MainActor.run {
            // ✅ Forcer l'invalidation du cache pour un refresh complet
            viewModel.invalidateCache()
            refreshNearbyGarages()
        }
    }
}

#Preview {
    GaragesView()
} 
