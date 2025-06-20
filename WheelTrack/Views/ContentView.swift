import SwiftUI
import CoreLocation

struct ContentView: View {
    @EnvironmentObject var signInService: AppleSignInService
    @EnvironmentObject var localizationService: LocalizationService
    @StateObject private var vehiclesViewModel = VehiclesViewModel()
    @StateObject private var expensesViewModel = ExpensesViewModel()
    @StateObject private var maintenanceViewModel = MaintenanceViewModel()
    @State private var isLoading = true
    @State private var selectedMainTab = 0
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @ObservedObject private var locationService = LocationService.shared
    
    var body: some View {
        ZStack {
            if isLoading {
                // Écran de chargement amélioré
                AnyView(modernLoadingView)
            } else if signInService.userIdentifier != nil && hasCompletedOnboarding {
                NavigationStack {
                    TabView(selection: $selectedMainTab) {
                        // 1. Tableau de bord - Vue d'ensemble
                        DashboardView(viewModel: expensesViewModel, vehiclesViewModel: vehiclesViewModel)
                            .tabItem {
                                Label(L(CommonTranslations.dashboard), systemImage: "house.fill")
                            }
                            .tag(0)
                            .accessibilityIdentifier("dashboard_tab")
                            .accessibilityLabel(L(CommonTranslations.mainDashboard))
                            .accessibilityHint(L(CommonTranslations.dashboardTab))
                        
                        // 2. Véhicules & Maintenance - Gestion automobile
                        VehiclesAndMaintenanceView(
                            vehiclesViewModel: vehiclesViewModel,
                            expensesViewModel: expensesViewModel,
                            maintenanceViewModel: maintenanceViewModel
                        )
                        .tabItem {
                            Label(L(CommonTranslations.vehicles), systemImage: "car.2.fill")
                        }
                        .tag(1)
                        .accessibilityIdentifier("vehicles_tab")
                        .accessibilityLabel(L(CommonTranslations.vehicleManagement))
                        .accessibilityHint(L(CommonTranslations.vehiclesTab))
                        
                        // 3. Finances - Dépenses & Analytics
                        ExpensesView(viewModel: expensesViewModel, vehiclesViewModel: vehiclesViewModel)
                            .tabItem {
                                Label(L(CommonTranslations.finances), systemImage: "creditcard.fill")
                            }
                            .tag(2)
                            .accessibilityIdentifier("finances_tab")
                            .accessibilityLabel(L(CommonTranslations.financialTracking))
                            .accessibilityHint(L(CommonTranslations.financesTab))
                        
                        // 4. Services - Garages & Location
                        GarageAndRentalView(vehiclesViewModel: vehiclesViewModel)
                            .tabItem {
                                Label("Services", systemImage: "building.2.fill")
                            }
                            .tag(3)
                            .accessibilityIdentifier("services_tab")
                            .accessibilityLabel(L(CommonTranslations.automotiveServices))
                            .accessibilityHint(L(CommonTranslations.servicesTab))
                        
                        // 5. Profil & Réglages
                        ProfileAndSettingsView()
                            .tabItem {
                                Label(L(CommonTranslations.profile), systemImage: "person.circle.fill")
                            }
                            .tag(4)
                            .accessibilityIdentifier("profile_tab")
                            .accessibilityLabel(L(CommonTranslations.userProfile))
                            .accessibilityHint(L(CommonTranslations.profileTab))
                    }

                    .accessibilityElement(children: .contain)
                    .accessibilityLabel(L(CommonTranslations.mainNavigation))
                    .accessibilityHint(L(CommonTranslations.useTabsToNavigate))
                }
                .onAppear {
                    setupAppConfiguration()
                }
            } else {
                // Afficher l'onboarding si l'utilisateur n'est pas connecté OU n'a pas terminé l'onboarding
                OnboardingView()
                    .onReceive(NotificationCenter.default.publisher(for: .userDidSignIn)) { _ in
                        // Marquer l'onboarding comme terminé quand l'utilisateur se connecte
                        withAnimation(.easeInOut(duration: 0.5)) {
                            hasCompletedOnboarding = true
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        }
                    }
            }
        }
        .onAppear {
            checkAuthenticationState()
        }
    }
    
    // MARK: - Modern Loading View
    private var modernLoadingView: some View {
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                // Logo animé
                        Image(systemName: "car.2.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isLoading)
                        
                        Text("WheelTrack")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        ProgressView()
                            .scaleEffect(1.2)
                    .accessibilityLabel(L(CommonTranslations.loadingApplication))
                    .accessibilityHint(L(CommonTranslations.pleaseWaitLoading))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L(CommonTranslations.loadingScreen))
    }
    
    // MARK: - Configuration Methods
    private func setupAppConfiguration() {
        // Configuration de l'apparence de la tab bar pour un footer opaque
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Configuration de la synchronisation bidirectionnelle
        expensesViewModel.configure(with: maintenanceViewModel, vehiclesViewModel: vehiclesViewModel)
        maintenanceViewModel.configure(with: expensesViewModel, vehiclesViewModel: vehiclesViewModel)
        
        // Demande d'autorisation géolocalisation avec feedback amélioré
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            locationService.requestLocationPermission()
        }
    }
    
    /// Vérifie l'état d'authentification de manière optimisée
    private func checkAuthenticationState() {
        let delay = signInService.userIdentifier != nil ? 0.05 : 0.2
        let animationDuration = signInService.userIdentifier != nil ? 0.2 : 0.3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: animationDuration)) {
                isLoading = false
            }
        }
    }
}

// MARK: - New Combined Views

// Vue combinée Véhicules & Maintenance
struct VehiclesAndMaintenanceView: View {
    @ObservedObject var vehiclesViewModel: VehiclesViewModel
    @ObservedObject var expensesViewModel: ExpensesViewModel
    @ObservedObject var maintenanceViewModel: MaintenanceViewModel
    @State private var selectedSubTab = 0
    @EnvironmentObject var localizationService: LocalizationService
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Sub-Tab Picker avec accessibilité améliorée
                HStack(spacing: 0) {
                    AccessibleTabButton(
                        title: L(CommonTranslations.vehicles),
                        icon: "car.fill",
                        isSelected: selectedSubTab == 0,
                        accessibilityLabel: L(CommonTranslations.vehiclesTabLabel),
                        accessibilityHint: L(CommonTranslations.showsVehicleList)
                    ) {
                        withHapticFeedback {
                            selectedSubTab = 0
                        }
                    }
                    
                    AccessibleTabButton(
                        title: L(CommonTranslations.maintenance),
                        icon: "wrench.fill",
                        isSelected: selectedSubTab == 1,
                        accessibilityLabel: L(CommonTranslations.maintenanceTabLabel),
                        accessibilityHint: L(CommonTranslations.manageVehicleMaintenance),
                        color: .orange
                    ) {
                        withHapticFeedback {
                            selectedSubTab = 1
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                
                // Contenu des sous-onglets
                TabView(selection: $selectedSubTab) {
                    VehiclesView(
                        viewModel: vehiclesViewModel,
                        expensesViewModel: expensesViewModel,
                        maintenanceViewModel: maintenanceViewModel
                    )
                    .tag(0)
                    
                    MaintenanceView(
                        vehicles: vehiclesViewModel.vehicles,
                        viewModel: maintenanceViewModel
                    )
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: selectedSubTab)
            }
            .navigationTitle(selectedSubTab == 0 ? "Véhicules" : "Maintenance")
            .navigationBarTitleDisplayMode(.large)
        }
        .accessibilityElement(children: .contain)
    }
    
    private func withHapticFeedback(action: @escaping () -> Void) {
        withAnimation(.easeInOut(duration: 0.3)) {
            action()
        }
    }
}

// Profil & Réglages combinés
struct ProfileAndSettingsView: View {
    @AppStorage("app_language") private var appLanguage: String = "fr"
    
    // Fonction de localisation
    static func localText(_ key: String, language: String) -> String {
        switch key {
        case "Mon Profil":
            return language == "en" ? "My Profile" : "Mon Profil"
        case "Gérez vos informations personnelles":
            return language == "en" ? "Manage your personal information" : "Gérez vos informations personnelles"
        case "Mon profil":
            return language == "en" ? "My profile" : "Mon profil"
        case "Touchez pour modifier vos informations personnelles":
            return language == "en" ? "Tap to edit your personal information" : "Touchez pour modifier vos informations personnelles"
        case "COMPTE":
            return language == "en" ? "ACCOUNT" : "COMPTE"
        case "Réglages":
            return language == "en" ? "Settings" : "Réglages"
        case "Réglages de l'application":
            return language == "en" ? "Application settings" : "Réglages de l'application"
        case "Configurez les paramètres de l'application":
            return language == "en" ? "Configure application settings" : "Configurez les paramètres de l'application"
        case "PARAMÈTRES":
            return language == "en" ? "SETTINGS" : "PARAMÈTRES"
        case "À propos de WheelTrack":
            return language == "en" ? "About WheelTrack" : "À propos de WheelTrack"
        case "Version 1.0":
            return language == "en" ? "Version 1.0" : "Version 1.0"
        case "À propos de WheelTrack, Version 1.0":
            return language == "en" ? "About WheelTrack, Version 1.0" : "À propos de WheelTrack, Version 1.0"
        case "INFORMATIONS":
            return language == "en" ? "INFORMATION" : "INFORMATIONS"
        case "Profil":
            return language == "en" ? "Profile" : "Profil"
        case "Mes Garages":
            return language == "en" ? "My Garages" : "Mes Garages"
        case "Onglet mes garages":
            return language == "en" ? "My garages tab" : "Onglet mes garages"
        case "Affiche la liste de vos garages partenaires":
            return language == "en" ? "Shows your partner garages list" : "Affiche la liste de vos garages partenaires"
        case "Location":
            return language == "en" ? "Rental" : "Location"
        case "Onglet location de véhicules":
            return language == "en" ? "Vehicle rental tab" : "Onglet location de véhicules"
        case "Gérez la location de vos véhicules":
            return language == "en" ? "Manage your vehicle rentals" : "Gérez la location de vos véhicules"
        case "Sélectionné":
            return language == "en" ? "Selected" : "Sélectionné"
        case "Non sélectionné":
            return language == "en" ? "Not selected" : "Non sélectionné"
        case "Location de véhicule":
            return language == "en" ? "Vehicle Rental" : "Location de véhicule"
        case "Supprimer":
            return language == "en" ? "Delete" : "Supprimer"
        case "Confirmer la suppression":
            return language == "en" ? "Confirm deletion" : "Confirmer la suppression"
        case "Annuler":
            return language == "en" ? "Cancel" : "Annuler"
        case "Annuler la suppression":
            return language == "en" ? "Cancel deletion" : "Annuler la suppression"
        case "Êtes-vous sûr de vouloir supprimer ce véhicule et tous ses contrats de location ? Cette action est irréversible.":
            return language == "en" ? "Are you sure you want to delete this vehicle and all its rental contracts? This action cannot be undone." : "Êtes-vous sûr de vouloir supprimer ce véhicule et tous ses contrats de location ? Cette action est irréversible."
        case "Aucun véhicule disponible":
            return language == "en" ? "No Vehicle Available" : "Aucun véhicule disponible"
        case "Ajoutez des véhicules pour gérer leurs contrats de location":
            return language == "en" ? "Add vehicles to manage their rental contracts" : "Ajoutez des véhicules pour gérer leurs contrats de location"
        case "Ajouter un véhicule":
            return language == "en" ? "Add Vehicle" : "Ajouter un véhicule"
        case "Ajouter votre premier véhicule":
            return language == "en" ? "Add your first vehicle" : "Ajouter votre premier véhicule"
        case "Ouvre le formulaire pour ajouter un nouveau véhicule à votre flotte":
            return language == "en" ? "Opens the form to add a new vehicle to your fleet" : "Ouvre le formulaire pour ajouter un nouveau véhicule à votre flotte"
        case "Aucun véhicule disponible. Ajoutez des véhicules pour gérer leurs contrats de location.":
            return language == "en" ? "No vehicle available. Add vehicles to manage their rental contracts." : "Aucun véhicule disponible. Ajoutez des véhicules pour gérer leurs contrats de location."
        case "contrat":
            return language == "en" ? "contract" : "contrat"
        case "contrats":
            return language == "en" ? "contracts" : "contrats"
        case "Voir les contrats":
            return language == "en" ? "View contracts" : "Voir les contrats"
        case "Véhicule":
            return language == "en" ? "Vehicle" : "Véhicule"
        case "plaque":
            return language == "en" ? "plate" : "plaque"
        case "Touchez pour voir les contrats de location de ce véhicule":
            return language == "en" ? "Tap to view this vehicle's rental contracts" : "Touchez pour voir les contrats de location de ce véhicule"
        case "Supprimer le véhicule":
            return language == "en" ? "Delete vehicle" : "Supprimer le véhicule"
        case "Prêt":
            return language == "en" ? "Ready" : "Prêt"
        case "Statut: Contrat prêt à finaliser":
            return language == "en" ? "Status: Contract ready to finalize" : "Statut: Contrat prêt à finaliser"
        case "En location":
            return language == "en" ? "Rented" : "En location"
        case "Statut: En location":
            return language == "en" ? "Status: Currently rented" : "Statut: En location"
        case "À venir":
            return language == "en" ? "Upcoming" : "À venir"
        case "Statut: Location à venir":
            return language == "en" ? "Status: Upcoming rental" : "Statut: Location à venir"
        case "Disponible":
            return language == "en" ? "Available" : "Disponible"
        case "Statut: Disponible pour location":
            return language == "en" ? "Status: Available for rental" : "Statut: Disponible pour location"
        case "Ajouter un nouveau véhicule":
            return language == "en" ? "Add a new vehicle" : "Ajouter un nouveau véhicule"
        case "Ouvre le formulaire pour ajouter un véhicule à votre flotte":
            return language == "en" ? "Opens the form to add a vehicle to your fleet" : "Ouvre le formulaire pour ajouter un véhicule à votre flotte"
        case "Véhicules":
            return language == "en" ? "Vehicles" : "Véhicules"
        case "véhicules au total":
            return language == "en" ? "vehicles total" : "véhicules au total"
        case "véhicules actuellement en location":
            return language == "en" ? "vehicles currently rented" : "véhicules actuellement en location"
        case "Disponibles":
            return language == "en" ? "Available" : "Disponibles"
        case "véhicules disponibles pour location":
            return language == "en" ? "vehicles available for rental" : "véhicules disponibles pour location"
        case "Statistiques de location":
            return language == "en" ? "Rental statistics" : "Statistiques de location"
        default:
            return key
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Section Profil
                Section {
                    NavigationLink {
                        UserProfileView()
                    } label: {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 32))
                                .accessibilityHidden(true)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(ProfileAndSettingsView.localText("Mon Profil", language: appLanguage))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text(ProfileAndSettingsView.localText("Gérez vos informations personnelles", language: appLanguage))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .accessibilityLabel(ProfileAndSettingsView.localText("Mon profil", language: appLanguage))
                    .accessibilityHint(ProfileAndSettingsView.localText("Touchez pour modifier vos informations personnelles", language: appLanguage))
                } header: {
                    Text(ProfileAndSettingsView.localText("COMPTE", language: appLanguage))
                        .accessibilityAddTraits(.isHeader)
                }
                
                // Section Réglages
                Section {
                    NavigationLink(destination: SettingsView()) {
                        HStack {
                            Image(systemName: "gear")
                                .foregroundColor(.gray)
                                .frame(width: 24, height: 24)
                                .accessibilityHidden(true)
                            
                            Text(ProfileAndSettingsView.localText("Réglages", language: appLanguage))
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityLabel(ProfileAndSettingsView.localText("Réglages de l'application", language: appLanguage))
                    .accessibilityHint(ProfileAndSettingsView.localText("Configurez les paramètres de l'application", language: appLanguage))
                } header: {
                    Text(ProfileAndSettingsView.localText("PARAMÈTRES", language: appLanguage))
                        .accessibilityAddTraits(.isHeader)
                }
                
                // Section Informations
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                            .accessibilityHidden(true)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ProfileAndSettingsView.localText("À propos de WheelTrack", language: appLanguage))
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text(ProfileAndSettingsView.localText("Version 1.0", language: appLanguage))
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(ProfileAndSettingsView.localText("À propos de WheelTrack, Version 1.0", language: appLanguage))
                    .accessibilityAddTraits(.isStaticText)
                } header: {
                    Text(ProfileAndSettingsView.localText("INFORMATIONS", language: appLanguage))
                        .accessibilityAddTraits(.isHeader)
                }
            }
            .navigationTitle(ProfileAndSettingsView.localText("Profil", language: appLanguage))
            .navigationBarTitleDisplayMode(.large)
        }
        .accessibilityIdentifier("ProfileAndSettingsView")
    }
}

// Composant de bouton d'onglet accessible amélioré
struct AccessibleTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let accessibilityLabel: String
    let accessibilityHint: String
    let color: Color
    let action: () -> Void
    
    init(
        title: String,
        icon: String,
        isSelected: Bool,
        accessibilityLabel: String,
        accessibilityHint: String,
        color: Color = .blue,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .accessibilityHidden(true)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : .secondary)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color(.systemGray5)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityValue(isSelected ? ProfileAndSettingsView.localText("Sélectionné", language: UserDefaults.standard.string(forKey: "app_language") ?? "fr") : ProfileAndSettingsView.localText("Non sélectionné", language: UserDefaults.standard.string(forKey: "app_language") ?? "fr"))
    }
}

// Vue temporaire intégrée pour les Garages et Location (améliorée)
struct GarageAndRentalView: View {
    @ObservedObject var vehiclesViewModel: VehiclesViewModel
    @State private var selectedTab = 0
    @AppStorage("app_language") private var appLanguage: String = "fr"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Tab Picker avec accessibilité améliorée
                HStack(spacing: 0) {
                    AccessibleTabButton(
                        title: ProfileAndSettingsView.localText("Mes Garages", language: appLanguage),
                        icon: "building.2.fill",
                        isSelected: selectedTab == 0,
                        accessibilityLabel: ProfileAndSettingsView.localText("Onglet mes garages", language: appLanguage),
                        accessibilityHint: ProfileAndSettingsView.localText("Affiche la liste de vos garages partenaires", language: appLanguage)
                    ) {
                        withHapticFeedback {
                            selectedTab = 0
                        }
                    }
                    
                    AccessibleTabButton(
                        title: ProfileAndSettingsView.localText("Location", language: appLanguage),
                        icon: "key.fill",
                        isSelected: selectedTab == 1,
                        accessibilityLabel: ProfileAndSettingsView.localText("Onglet location de véhicules", language: appLanguage),
                        accessibilityHint: ProfileAndSettingsView.localText("Gérez la location de vos véhicules", language: appLanguage),
                        color: .green
                    ) {
                        withHapticFeedback {
                            selectedTab = 1
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                
                // Contenu des onglets
                TabView(selection: $selectedTab) {
                    GaragesView()
                        .tag(0)
                    
                    VehicleRentalView(vehiclesViewModel: vehiclesViewModel)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
            }
            .navigationTitle(selectedTab == 0 ? ProfileAndSettingsView.localText("Mes Garages", language: appLanguage) : ProfileAndSettingsView.localText("Location de véhicule", language: appLanguage))
            .navigationBarTitleDisplayMode(.large)
        }
        .accessibilityElement(children: .contain)
    }
    
    private func withHapticFeedback(action: @escaping () -> Void) {
        withAnimation(.easeInOut(duration: 0.3)) {
            action()
        }
    }
}

// Vue améliorée pour les locations avec badges d'état et accessibilité
struct VehicleRentalView: View {
    @ObservedObject var vehiclesViewModel: VehiclesViewModel
    @State private var showingAddVehicle = false
    @State private var vehicleToDelete: Vehicle?
    @State private var showingDeleteAlert = false
    @State private var isRefreshing = false
    @ObservedObject private var rentalService = RentalService.shared
    @AppStorage("app_language") private var appLanguage: String = "fr"
    
    // Fonction de localisation
    private func localText(_ key: String) -> String {
        return ProfileAndSettingsView.localText(key, language: appLanguage)
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            if vehiclesViewModel.vehicles.isEmpty {
                accessibleEmptyStateView
            } else {
                accessibleVehicleRentalsList
            }
        }
        .sheet(isPresented: $showingAddVehicle) {
            AddVehicleView { vehicle in
                vehiclesViewModel.addVehicle(vehicle)
                
                // Feedback de succès
                let successFeedback = UINotificationFeedbackGenerator()
                successFeedback.notificationOccurred(.success)
            }
        }
        .alert(localText("Supprimer le véhicule"), isPresented: $showingDeleteAlert) {
            Button(localText("Supprimer"), role: .destructive) {
                if let vehicle = vehicleToDelete {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        deleteVehicle(vehicle)
                    }
                    
                    // Feedback haptique de suppression
                    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                    impactFeedback.impactOccurred()
                }
            }
            .accessibilityLabel(localText("Confirmer la suppression"))
            
            Button(localText("Annuler"), role: .cancel) {
                vehicleToDelete = nil
            }
            .accessibilityLabel(localText("Annuler la suppression"))
        } message: {
            Text(localText("Êtes-vous sûr de vouloir supprimer ce véhicule et tous ses contrats de location ? Cette action est irréversible."))
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("VehicleRentalView")
    }
    
    // MARK: - Accessible Empty State View
    private var accessibleEmptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "car.2")
                .font(.system(size: 64))
                .foregroundColor(.blue.opacity(0.6))
                .accessibilityHidden(true)
            
            VStack(spacing: 8) {
                Text(localText("Aucun véhicule disponible"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
                
                Text(localText("Ajoutez des véhicules pour gérer leurs contrats de location"))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button {
                showingAddVehicle = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .accessibilityHidden(true)
                    Text(localText("Ajouter un véhicule"))
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 0.1), value: showingAddVehicle)
            }
            .accessibilityLabel(localText("Ajouter votre premier véhicule"))
            .accessibilityHint(localText("Ouvre le formulaire pour ajouter un nouveau véhicule à votre flotte"))
            .accessibilityAddTraits(.isButton)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(localText("Aucun véhicule disponible. Ajoutez des véhicules pour gérer leurs contrats de location."))
    }
    
    // MARK: - Accessible Vehicles Rentals List  
    private var accessibleVehicleRentalsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // En-tête avec statistiques de location
                accessibleRentalStatsHeader
                
                // Liste des véhicules avec informations de location détaillées
                ForEach(vehiclesViewModel.vehicles) { vehicle in
                    AccessibleVehicleRentalCard(vehicle: vehicle) {
                        vehicleToDelete = vehicle
                        showingDeleteAlert = true
                    }
                }
                
                // Bouton pour ajouter un véhicule
                accessibleAddVehicleButton
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .refreshable {
            await refreshData()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Liste des véhicules en location")
    }
    
    // MARK: - Accessible Statistics Header
    private var accessibleRentalStatsHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Vue d'ensemble")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                AccessibleStatCard(
                    title: localText("Véhicules"),
                    value: "\(vehiclesViewModel.vehicles.count)",
                    icon: "car.fill",
                    color: .blue,
                    accessibilityLabel: "\(vehiclesViewModel.vehicles.count) \(localText("véhicules au total"))"
                )
                
                AccessibleStatCard(
                    title: localText("En location"),
                    value: "\(totalActiveContracts)",
                    icon: "key.fill",
                    color: .green,
                    accessibilityLabel: "\(totalActiveContracts) \(localText("véhicules actuellement en location"))"
                )
                
                AccessibleStatCard(
                    title: localText("Disponibles"),
                    value: "\(availableVehiclesCount)",
                    icon: "checkmark.circle.fill",
                    color: .gray,
                    accessibilityLabel: "\(availableVehiclesCount) \(localText("véhicules disponibles pour location"))"
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(localText("Statistiques de location"))
    }
    
    // MARK: - Accessible Add Vehicle Button
    private var accessibleAddVehicleButton: some View {
        Button {
            showingAddVehicle = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .accessibilityHidden(true)
                
                Text(localText("Ajouter un véhicule"))
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                    .background(Color.blue.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            )
            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.1), value: showingAddVehicle)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(localText("Ajouter un nouveau véhicule"))
        .accessibilityHint(localText("Ouvre le formulaire pour ajouter un véhicule à votre flotte"))
        .accessibilityAddTraits(.isButton)
    }
    
    // MARK: - Refresh Function
    @MainActor
    private func refreshData() async {
        isRefreshing = true
        
        // Feedback tactile pour indiquer le rafraîchissement
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Force la synchronisation des données
        Task {
            // ✅ Force une notification de changement pour déclencher la mise à jour UI
            rentalService.objectWillChange.send()
            vehiclesViewModel.objectWillChange.send()
        }
        
        // Petit délai pour une UX plus fluide (optionnel)
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 secondes
        
        isRefreshing = false
    }
    
    // MARK: - Computed Properties
    private var totalActiveContracts: Int {
        vehiclesViewModel.vehicles.reduce(0) { total, vehicle in
            total + rentalService.getRentalContracts(for: vehicle.id).filter { $0.isActive() }.count
        }
    }
    
    private var availableVehiclesCount: Int {
        vehiclesViewModel.vehicles.filter { vehicle in
            let contracts = rentalService.getRentalContracts(for: vehicle.id)
            return !contracts.contains { $0.isActive() }
        }.count
    }
    
    // MARK: - Private Methods
    private func deleteVehicle(_ vehicle: Vehicle) {
        // Supprimer d'abord tous les contrats de location associés
        let contracts = rentalService.getRentalContracts(for: vehicle.id)
        for contract in contracts {
            rentalService.deleteRentalContract(contract)
        }
        
        // Ensuite supprimer le véhicule
        vehiclesViewModel.deleteVehicle(vehicle)
        vehicleToDelete = nil
    }
}

// MARK: - Accessible Vehicle Rental Card
struct AccessibleVehicleRentalCard: View {
    let vehicle: Vehicle
    let onDelete: () -> Void
    private var rentalService: RentalService { RentalService.shared }
    @AppStorage("app_language") private var appLanguage: String = "fr"
    
    private var totalContracts: Int {
        rentalService.getRentalContracts(for: vehicle.id).count
    }
    
    private func localText(_ key: String) -> String {
        return ProfileAndSettingsView.localText(key, language: appLanguage)
    }
    
    var body: some View {
        NavigationLink(destination: RentalListView(vehicle: vehicle)) {
            VStack(spacing: 16) {
                // En-tête du véhicule avec badge de statut
                HStack {
                    Image(systemName: "key.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 24)
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(vehicle.brand) \(vehicle.model)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(vehicle.licensePlate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        AccessibleVehicleRentalStatusBadge(vehicle: vehicle)
                        
                        Text("\(totalContracts) \(totalContracts > 1 ? localText("contrats") : localText("contrat"))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Actions rapides
                HStack {
                    Text(localText("Voir les contrats"))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.1), value: vehicle.id)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(localText("Véhicule")) \(vehicle.brand) \(vehicle.model), \(localText("plaque")) \(vehicle.licensePlate), \(totalContracts) \(totalContracts > 1 ? localText("contrats") : localText("contrat"))")
        .accessibilityHint(localText("Touchez pour voir les contrats de location de ce véhicule"))
        .accessibilityAddTraits(.isButton)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label(localText("Supprimer"), systemImage: "trash")
            }
            .accessibilityLabel("\(localText("Supprimer le véhicule")) \(vehicle.brand) \(vehicle.model)")
        }
    }
}

// MARK: - Accessible Vehicle Rental Status Badge
struct AccessibleVehicleRentalStatusBadge: View {
    let vehicle: Vehicle
    private var rentalService: RentalService { RentalService.shared }
    @AppStorage("app_language") private var appLanguage: String = "fr"
    
    private func localText(_ key: String) -> String {
        return ProfileAndSettingsView.localText(key, language: appLanguage)
    }
    
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
        if !prefilledContracts.isEmpty {
            // ✅ Badge orange pour contrats pré-remplis (vérifié en premier)
            Text(localText("Prêt"))
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange)
                .clipShape(Capsule())
                .accessibilityLabel(localText("Statut: Contrat prêt à finaliser"))
                .accessibilityAddTraits(.isStaticText)
        } else if !activeContracts.isEmpty {
            Text(localText("En location"))
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green)
                .clipShape(Capsule())
                .accessibilityLabel(localText("Statut: En location"))
                .accessibilityAddTraits(.isStaticText)
        } else if !upcomingContracts.isEmpty {
            Text(localText("À venir"))
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue)
                .clipShape(Capsule())
                .accessibilityLabel(localText("Statut: Location à venir"))
                .accessibilityAddTraits(.isStaticText)
        } else {
            Text(localText("Disponible"))
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray5))
                .clipShape(Capsule())
                .accessibilityLabel(localText("Statut: Disponible pour location"))
                .accessibilityAddTraits(.isStaticText)
        }
    }
}

// MARK: - Accessible Stat Card
struct AccessibleStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let accessibilityLabel: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .accessibilityHidden(true)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: color.opacity(0.2), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isStaticText)
    }
}

#Preview {
    ContentView()
} 
