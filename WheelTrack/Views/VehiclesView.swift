import SwiftUI

public struct VehiclesView: View {
    @ObservedObject var viewModel: VehiclesViewModel
    @ObservedObject var expensesViewModel: ExpensesViewModel
    @ObservedObject var maintenanceViewModel: MaintenanceViewModel
    @State private var showingAddVehicle = false
    @State private var searchText = ""
    @State private var selectedFilter: VehicleFilter = .all
    @State private var editingVehicle: Vehicle? = nil
    
    init(viewModel: VehiclesViewModel, expensesViewModel: ExpensesViewModel, maintenanceViewModel: MaintenanceViewModel) {
        self.viewModel = viewModel
        self.expensesViewModel = expensesViewModel
        self.maintenanceViewModel = maintenanceViewModel
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
                // Bouton flottant pour ajouter des véhicules
                if !viewModel.vehicles.isEmpty {
                    Button(action: { showingAddVehicle = true }) {
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
                            Text("Mes véhicules")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Gérez votre flotte automobile")
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
                        Text("Total véhicules")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("\(viewModel.vehicles.count)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(activeVehicleCount)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("actifs")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Statistiques détaillées
                if !viewModel.vehicles.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Répartition par marque")
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
                                    
                                    Text("\(count) véhicule\(count > 1 ? "s" : "")")
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
            
            TextField("Rechercher un véhicule...", text: $searchText)
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
            Text("Filtres")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(VehicleFilter.allCases) { filter in
                        ModernVehicleFilterChip(
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
    }
    
    private var modernVehicleListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tous les véhicules")
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
                    .onTapGesture {
                        // TODO: Navigation vers VehicleDetailView quand il sera ajouté à la cible
                        print("Tap sur véhicule: \(vehicle.brand) \(vehicle.model)")
                    }
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
                Text("Aucun véhicule")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Ajoutez votre premier véhicule pour commencer le suivi de vos dépenses automobiles")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: { showingAddVehicle = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text("Ajouter un véhicule")
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
    
    private var activeVehicleCount: Int {
        viewModel.vehicles.filter { $0.isActive }.count
    }
    
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

// MARK: - Empty Vehicles View
struct EmptyVehiclesView: View {
    let onAddVehicle: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Illustration
            Image(systemName: "car.2")
                .font(.system(size: 64))
                .foregroundColor(.blue.opacity(0.6))
                .frame(width: 120, height: 120)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 12) {
                Text("Aucun véhicule enregistré")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Ajoutez votre premier véhicule pour commencer à suivre vos dépenses automobiles")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: onAddVehicle) {
                HStack {
                    Image(systemName: "plus")
                    Text("Ajouter un véhicule")
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
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(40)
    }
}

// MARK: - Vehicles Header View
struct VehiclesHeaderView: View {
    let vehicleCount: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Mes véhicules")
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
        Button(action: action) {
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
        }
        .buttonStyle(PlainButtonStyle())
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
    
    // Calcule le total des dépenses pour ce véhicule
    var totalExpenses: Double {
        expensesViewModel.expenses.filter { $0.vehicleId == vehicle.id }.reduce(0) { $0 + $1.amount }
    }
    
    // Calcule les dépenses par catégorie
    var maintenanceExpenses: Double {
        expensesViewModel.expenses.filter { 
            $0.vehicleId == vehicle.id && $0.category == .maintenance 
        }.reduce(0) { $0 + $1.amount }
    }
    
    var fuelExpenses: Double {
        expensesViewModel.expenses.filter { 
            $0.vehicleId == vehicle.id && $0.category == .fuel 
        }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // En-tête de la carte
            HStack(spacing: 16) {
                // Icône du véhicule
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [vehicleColor, vehicleColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: vehicleIcon)
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .semibold))
                    )
                
                // Informations principales
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(vehicle.brand) \(vehicle.model)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Text("\(vehicle.year)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(vehicle.fuelType.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Statut actif/inactif
                Circle()
                    .fill(vehicle.isActive ? Color.green : Color.gray)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(Color(.systemBackground), lineWidth: 2)
                    )
            }
            .padding(20)
            
            // Divider
            Divider()
                .padding(.horizontal, 20)
            
            // Statistiques détaillées
            VStack(spacing: 16) {
                // Kilométrage
                HStack(spacing: 12) {
                    Image(systemName: "speedometer")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    
                    Text("Kilométrage")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(Int(vehicle.mileage).formatted()) km")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                // Dépenses totales
                HStack(spacing: 12) {
                    Image(systemName: "creditcard.fill")
                        .font(.subheadline)
                        .foregroundColor(.purple)
                        .frame(width: 20)
                    
                    Text("Dépenses totales")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(totalExpenses, specifier: "%.2f") €")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                // Grille des statistiques
                HStack(spacing: 16) {
                    ModernStatCard(
                        title: "Carburant",
                        value: String(format: "%.0f €", fuelExpenses),
                        icon: "fuelpump.fill",
                        color: .green
                    )
                    
                    ModernStatCard(
                        title: "Maintenance",
                        value: String(format: "%.0f €", maintenanceExpenses),
                        icon: "wrench.fill",
                        color: .orange
                    )
                }
            }
            .padding(20)
            
            // Actions
            HStack(spacing: 16) {
                Button(action: { onEdit(vehicle) }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Modifier")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { showDeleteAlert = true }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Supprimer")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
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
    case all = "Tous"
    case active = "Actifs"
    case inactive = "Inactifs"
    
    public var id: String { self.rawValue }
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
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Aucun véhicule")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Aucun véhicule ne correspond au filtre '\(filter.rawValue)'")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
} 