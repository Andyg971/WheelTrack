import SwiftUI

public struct VehiclesView: View {
    @ObservedObject var viewModel: VehiclesViewModel
    @ObservedObject var expensesViewModel: ExpensesViewModel
    @ObservedObject var maintenanceViewModel: MaintenanceViewModel
    @State private var showingAddVehicle = false
    @State private var searchText = ""
    @State private var selectedFilter: VehicleFilter = .all
    @State private var editingVehicle: Vehicle? = nil
    
    // ✅ Migration vers système centralisé
    @EnvironmentObject var localizationService: LocalizationService
    
    // Service de location pour détecter les contrats
    @ObservedObject private var rentalService = RentalService.shared
    
    init(viewModel: VehiclesViewModel, expensesViewModel: ExpensesViewModel, maintenanceViewModel: MaintenanceViewModel) {
        self.viewModel = viewModel
        self.expensesViewModel = expensesViewModel
        self.maintenanceViewModel = maintenanceViewModel
    }
    
    // Propriétés calculées pour les statistiques de location
    private var vehiclesWithRentals: Int {
        viewModel.vehicles.filter { vehicle in
            hasActiveRental(for: vehicle.id) || hasPrefilledContract(for: vehicle.id)
        }.count
    }
    
    private func hasActiveRental(for vehicleId: UUID) -> Bool {
        return rentalService.rentalContracts.contains { contract in
            contract.vehicleId == vehicleId && 
            !contract.renterName.trimmingCharacters(in: .whitespaces).isEmpty &&
            (contract.isActive() || Date() < contract.startDate)
        }
    }
    
    private func hasPrefilledContract(for vehicleId: UUID) -> Bool {
        return rentalService.rentalContracts.contains { contract in
            contract.vehicleId == vehicleId && 
            contract.renterName.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.vehicles.isEmpty {
                    modernEmptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            // En-tête moderne avec icône
                            modernHeaderSection
                            
                            // Résumé moderne
                            modernSummarySection
                            
                            // Barre de recherche moderne
                            modernSearchSection
                            
                            // Sélecteur de filtre moderne
                            modernFiltersSection
                            
                            // Liste des véhicules ou message de filtre vide
                            if filteredVehicles.isEmpty && !searchText.isEmpty {
                                NoResultsView(searchText: searchText)
                            } else if filteredVehicles.isEmpty && selectedFilter != .all {
                                FilterEmptyStateView(filter: selectedFilter)
                            } else {
                                modernVehicleListSection
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddVehicle) {
                AddVehicleView { vehicle in
                    viewModel.addVehicle(vehicle)
                }
            }
            .sheet(item: $editingVehicle) { vehicle in
                EditVehicleView(vehicle: vehicle) { updatedVehicle in
                    viewModel.updateVehicle(updatedVehicle)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                // Bouton flottant unifié
                if !viewModel.vehicles.isEmpty {
                    Button(action: {
                        showingAddVehicle = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .accessibilityLabel(L(CommonTranslations.addVehicle))
                    .accessibilityHint("Touchez pour ouvrir le formulaire d'ajout de véhicule")
                    .padding(.trailing, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }
    
    // MARK: - Modern Sections
    
    private var modernHeaderSection: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        // Icône moderne
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.15), .blue.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: "car.2.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L(CommonTranslations.vehicles))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(L(CommonTranslations.manageFleet))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Spacer()
            }
        }
    }
    
    private var modernSummarySection: some View {
        VStack(spacing: 16) {
            // Carte principale moderne
            VStack(spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L(CommonTranslations.totalVehicles))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("\(viewModel.vehicles.count)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(vehiclesWithRentals)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                                                    Text(L(CommonTranslations.inRental))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Statistiques détaillées
                if !viewModel.vehicles.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L(CommonTranslations.brandDistribution))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(brandStats.prefix(3), id: \.0) { brand, count in
                                HStack {
                                    Circle()
                                        .fill(.blue.opacity(0.7))
                                        .frame(width: 12, height: 12)
                                    
                                    Text(brand)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text("\(count) \(L(CommonTranslations.vehicles).lowercased())")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
            )
        }
    }
    
    private var modernSearchSection: some View {
        // Barre de recherche moderne
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
                            TextField(L(CommonTranslations.searchVehicles) + "...", text: $searchText)
                .font(.system(size: 16))
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: { 
                    withAnimation(.easeInOut(duration: 0.2)) {
                        searchText = ""
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
    
    private var modernFiltersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L(CommonTranslations.filters))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(VehicleFilter.allCases) { filter in
                        ModernVehicleFilterChip(
                            title: filter.localizedName(language: localizationService.currentLanguage),
                            isSelected: selectedFilter == filter
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFilter = filter
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var modernVehicleListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L(CommonTranslations.all) + " " + L(CommonTranslations.vehicles).lowercased())
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 12) {
                ForEach(filteredVehicles) { vehicle in
                    ModernVehicleCard(
                        vehicle: vehicle,
                        expensesViewModel: expensesViewModel,
                        onEdit: { editingVehicle = $0 },
                        onDelete: { viewModel.deleteVehicle($0) }
                    )
                }
            }
        }
    }
    
    private var modernEmptyStateView: some View {
        VStack(spacing: 32) {
            // Illustration moderne
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.1), .blue.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "car.2")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 16) {
                Text(L(CommonTranslations.noVehicles))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(L(CommonTranslations.addFirstVehicle))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: { showingAddVehicle = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text(L(CommonTranslations.addVehicle))
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
            }
        }
        .padding(.vertical, 60)
    }
    
    // MARK: - Computed Properties
    
    private var brandStats: [(String, Int)] {
        Dictionary(grouping: viewModel.vehicles, by: { $0.brand })
            .map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
    }
    
    // Filtrage des véhicules
    private var filteredVehicles: [Vehicle] {
        var vehicles = viewModel.vehicles
        
        // Filtrage par texte de recherche
        if !searchText.isEmpty {
            vehicles = vehicles.filter { vehicle in
                vehicle.brand.localizedCaseInsensitiveContains(searchText) ||
                vehicle.model.localizedCaseInsensitiveContains(searchText) ||
                "\(vehicle.year)".contains(searchText)
            }
        }
        
        // Filtrage par statut
        switch selectedFilter {
        case .all:
            return vehicles
        case .active:
            return vehicles.filter { $0.isActive }
        case .inactive:
            return vehicles.filter { !$0.isActive }
        }
    }
}

// MARK: - Accessible Empty Vehicles View
struct EmptyVehiclesView: View {
    let onAddVehicle: () -> Void
    @EnvironmentObject var localizationService: LocalizationService
    
    var body: some View {
        VStack(spacing: 24) {
            // Illustration accessible
            Image(systemName: "car.2")
                .font(.system(size: 64))
                .foregroundColor(.blue.opacity(0.6))
                .frame(width: 120, height: 120)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
                .accessibilityHidden(true)
            
            VStack(spacing: 12) {
                Text("Aucun véhicule enregistré")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Ajoutez votre premier véhicule pour commencer à suivre vos dépenses automobiles")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: {
                onAddVehicle()
                
                // Feedback haptique pour l'action d'ajout
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.prepare()
                impactFeedback.impactOccurred()
            }) {
                HStack {
                    Image(systemName: "plus")
                        .accessibilityHidden(true)
                    Text(L(CommonTranslations.addVehicle))
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 0.1), value: false)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Ajouter votre premier véhicule")
            .accessibilityHint("Ouvre le formulaire pour enregistrer un nouveau véhicule dans votre flotte")
            .accessibilityAddTraits(.isButton)
        }
        .padding(40)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Aucun véhicule enregistré. Ajoutez votre premier véhicule pour commencer à suivre vos dépenses automobiles.")
    }
}

// MARK: - Vehicles Header View
struct VehiclesHeaderView: View {
    let vehicleCount: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Véhicules")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("\(vehicleCount) véhicule\(vehicleCount > 1 ? "s" : "") enregistré\(vehicleCount > 1 ? "s" : "")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            
            // Icône décorative
            Image(systemName: "car.2.fill")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
        }
        .padding(.horizontal, 4)
    }
}


// MARK: - Modern Filter Picker
struct ModernFilterPicker: View {
    @Binding var selectedFilter: VehicleFilter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filtrer")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(VehicleFilter.allCases) { filter in
                        FilterButton(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFilter = filter
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.vertical, 8)
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
            
            // Feedback haptique pour les filtres
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
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
                    color: isSelected ? .blue.opacity(0.3) : .black.opacity(0.05),
                    radius: isSelected ? 8 : 2,
                    x: 0,
                    y: isSelected ? 4 : 1
                )
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Filtre \(title)")
        .accessibilityHint("Filtrer les véhicules par \(title)")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityValue(isSelected ? "Sélectionné" : "Non sélectionné")
    }
}

// MARK: - No Results View
struct NoResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.6))
            
            Text("Aucun résultat")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Aucun véhicule ne correspond à '\(searchText)'")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Modern Vehicle Card
struct ModernVehicleCard: View {
    let vehicle: Vehicle
    let expensesViewModel: ExpensesViewModel
    var onEdit: (Vehicle) -> Void
    var onDelete: (Vehicle) -> Void
    @State private var showDeleteAlert = false
    
    // Service de location pour détecter les contrats
    @ObservedObject private var rentalService = RentalService.shared
    
    // Force la mise à jour quand les contrats changent
    private var contractsForVehicle: [RentalContract] {
        rentalService.rentalContracts.filter { $0.vehicleId == vehicle.id }
    }
    
    // Calcule le total des dépenses pour ce véhicule
    var totalExpenses: Double {
        expensesViewModel.expenses.filter { $0.vehicleId == vehicle.id }.reduce(0) { $0 + $1.amount }
    }
    
    // Détection des contrats de location
    private var hasActiveRental: Bool {
        contractsForVehicle.contains { contract in
            !contract.renterName.trimmingCharacters(in: .whitespaces).isEmpty &&
            contract.isActive()
        }
    }
    
    private var hasPrefilledContract: Bool {
        contractsForVehicle.contains { contract in
            contract.renterName.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }
    
    private var rentalStatus: String {
        if hasActiveRental {
            return "En location"
        } else if hasPrefilledContract {
            return "Disponible"
        } else {
            return ""
        }
    }
    
    // MARK: - Rental Badge
    @ViewBuilder
    private func rentalBadgeView() -> some View {
        if hasActiveRental {
            Text(L(CommonTranslations.rented))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.green)
                .clipShape(Capsule())
                .fixedSize(horizontal: true, vertical: false)
        } else if hasPrefilledContract {
            // ✅ Badge orange pour contrats pré-remplis
                                    Text(L(("Prêt", "Ready")))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.orange)
                .clipShape(Capsule())
                .fixedSize(horizontal: true, vertical: false)
        } else if vehicle.isAvailableForRent {
                                    Text(L(("Libre", "Free")))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.blue)
                .clipShape(Capsule())
                .fixedSize(horizontal: true, vertical: false)
        }
    }
    
        var body: some View {
        HStack(spacing: 16) {
            // Image du véhicule avec placeholder intelligent
            VehicleCardImageView(vehicle: vehicle)
            
            // Informations principales
            VStack(alignment: .leading, spacing: 4) {
                Text("\(vehicle.brand) \(vehicle.model)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(String(vehicle.year))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(vehicle.mileage).formatted()) km")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    rentalBadgeView()
                }
            }
            
            // Dépenses totales + Menu actions
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(totalExpenses, specifier: "%.0f") €")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    // Statut actif/inactif
                    Circle()
                        .fill(vehicle.isActive ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                    
                    // Menu d'actions
                    Menu {
                        Button(action: { onEdit(vehicle) }) {
                            Label("Modifier", systemImage: "pencil")
                        }
                        Button(role: .destructive, action: { showDeleteAlert = true }) {
                            Label("Supprimer", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Supprimer le véhicule ?"),
                message: Text("Cette action supprimera également toutes les dépenses associées. Cette action est irréversible."),
                primaryButton: .destructive(Text("Supprimer")) { onDelete(vehicle) },
                secondaryButton: .cancel()
            )
        }
    }
    
    private var vehicleColor: Color {
        switch vehicle.fuelType {
        case .gasoline: return .blue
        case .diesel: return .green
        case .electric: return .yellow
        case .hybrid: return .purple
        case .lpg: return .orange
        }
    }
    
    private var vehicleIcon: String {
        switch vehicle.fuelType {
        case .gasoline: return "car.fill"
        case .diesel: return "car.fill"
        case .electric: return "bolt.car.fill"
        case .hybrid: return "leaf.fill"
        case .lpg: return "car.fill"
        }
    }
}

// MARK: - Modern Stat Card
struct ModernStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

public enum VehicleFilter: String, CaseIterable, Identifiable {
    case all = "all"
    case active = "active"
    case inactive = "inactive"
    
    public var id: String { self.rawValue }
    
    /// Retourne le libellé localisé pour le filtre
    public func localizedName(language: String = "fr") -> String {
        switch self {
        case .all:
            return language == "en" ? "All" : "Tous"
        case .active:
            return language == "en" ? "Active" : "Actifs"
        case .inactive:
            return language == "en" ? "Inactive" : "Inactifs"
        }
    }
}

#Preview {
    VehiclesView(viewModel: VehiclesViewModel(), expensesViewModel: ExpensesViewModel(), maintenanceViewModel: MaintenanceViewModel())
}

// MARK: - Supporting Views

struct ModernVehicleFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
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
                                colors: [.blue, .blue.opacity(0.8)],
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
                    color: isSelected ? .blue.opacity(0.3) : .black.opacity(0.05),
                    radius: isSelected ? 8 : 2,
                    x: 0,
                    y: isSelected ? 4 : 1
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FilterEmptyStateView: View {
    let filter: VehicleFilter
    @EnvironmentObject var localizationService: LocalizationService
    
    var body: some View {
        VStack(spacing: 16) {
            Text(L(CommonTranslations.noVehicles))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("\(L(CommonTranslations.noFilterMatch)) '\(filter.localizedName(language: localizationService.currentLanguage))'")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Vehicle Card Image View
private struct VehicleCardImageView: View {
    let vehicle: Vehicle
    @State private var loadedImage: UIImage?
    @State private var imageManager = VehiclesViewImageManager()
    
    var body: some View {
        Group {
            if let loadedImage = loadedImage {
                // Affichage de l'image réelle
                Image(uiImage: loadedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 45)
                    .clipped()
                    .cornerRadius(8)
            } else {
                // Placeholder avec informations du véhicule
                VehicleSmallPlaceholder(vehicle: vehicle)
            }
        }
        .onAppear {
            loadVehicleImage()
        }
        .onChange(of: vehicle.mainImageURL) { _, _ in
            loadVehicleImage()
        }
    }
    
    private func loadVehicleImage() {
        guard let mainImageURL = vehicle.mainImageURL else {
            loadedImage = nil
            return
        }
        
        loadedImage = imageManager.loadImage(fileName: mainImageURL)
    }
}

// MARK: - Vehicle Small Placeholder
private struct VehicleSmallPlaceholder: View {
    let vehicle: Vehicle
    
    private var vehicleIcon: String {
        switch vehicle.fuelType {
        case .electric:
            return "bolt.car"
        case .hybrid:
            return "leaf.circle"
        default:
            return "car"
        }
    }
    
    private var gradientColors: [Color] {
        switch vehicle.color.lowercased() {
        case "rouge", "red":
            return [Color.red.opacity(0.3), Color.red.opacity(0.1)]
        case "bleu", "blue":
            return [Color.blue.opacity(0.3), Color.blue.opacity(0.1)]
        case "vert", "green":
            return [Color.green.opacity(0.3), Color.green.opacity(0.1)]
        case "noir", "black":
            return [Color.black.opacity(0.3), Color.gray.opacity(0.1)]
        case "blanc", "white":
            return [Color.gray.opacity(0.2), Color.gray.opacity(0.05)]
        case "gris", "gray", "grey":
            return [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]
        case "jaune", "yellow":
            return [Color.yellow.opacity(0.3), Color.yellow.opacity(0.1)]
        case "orange":
            return [Color.orange.opacity(0.3), Color.orange.opacity(0.1)]
        case "violet", "purple":
            return [Color.purple.opacity(0.3), Color.purple.opacity(0.1)]
        default:
            return [Color.blue.opacity(0.2), Color.blue.opacity(0.05)]
        }
    }
    
    var body: some View {
        ZStack {
            // Gradient de fond basé sur la couleur du véhicule
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Icône du véhicule
            Image(systemName: vehicleIcon)
                .font(.caption)
                .foregroundColor(.primary.opacity(0.6))
        }
        .frame(width: 60, height: 45)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }
}

// MARK: - Vehicles View Image Manager
private class VehiclesViewImageManager {
    
    // MARK: - Répertoires
    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var vehicleImagesURL: URL {
        documentsURL.appendingPathComponent("VehicleImages")
    }
    
    // MARK: - Récupération d'images
    func loadImage(fileName: String) -> UIImage? {
        let fileURL = vehicleImagesURL.appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        return UIImage(contentsOfFile: fileURL.path)
    }
}