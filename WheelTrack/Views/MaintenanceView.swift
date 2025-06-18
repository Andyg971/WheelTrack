import SwiftUI

public struct MaintenanceView: View {
    let vehicles: [Vehicle]
    @ObservedObject var viewModel: MaintenanceViewModel
    @State private var showingAddSheet = false
    @State private var editingMaintenance: Maintenance? = nil
    @State private var searchText = ""
    @State private var selectedVehicle: String = "all_vehicles"
    
    // Système de localisation local
    @AppStorage("app_language") private var appLanguage: String = "fr"
    
    init(vehicles: [Vehicle], viewModel: MaintenanceViewModel) {
        self.vehicles = vehicles
        self.viewModel = viewModel
    }
    
    // Fonction de localisation locale
    static func localText(_ key: String, language: String) -> String {
        switch language {
        case "en":
            switch key {
            case "maintenance": return "Maintenance"
            case "track_vehicle_maintenance": return "Track your vehicle maintenance"
            case "total_cost": return "Total cost"
            case "maintenance_singular": return "maintenance"
            case "maintenance_plural": return "maintenance"
            case "vehicle_distribution": return "Distribution by vehicle"
            case "search_maintenance": return "Search maintenance"
            case "all_vehicles": return "All vehicles"
            case "all": return "All"
            case "no_maintenance": return "No maintenance"
            case "add_first_maintenance": return "Start by adding your first maintenance to track your vehicle care"
            case "add_maintenance": return "Add maintenance"
            case "add_new_maintenance": return "Add new maintenance"
            case "view_details": return "View details"
            case "edit": return "Edit"
            case "delete": return "Delete"
            case "cancel": return "Cancel"
            case "delete_maintenance_title": return "Delete maintenance?"
            case "delete_maintenance_message": return "This action cannot be undone."
            case "maintenance_type": return "Type"
            case "date": return "Date"
            case "cost": return "Cost"
            case "vehicle": return "Vehicle"
            case "search_maintenance_placeholder": return "Search maintenance..."
            case "vehicles_filter": return "Vehicles"
            case "all_maintenances": return "All Maintenances"
            case "no_maintenance_title": return "No maintenance"
            case "no_maintenance_message": return "Start recording your vehicle maintenance for optimal tracking."
            default: return key
            }
        default: // français
            switch key {
            case "maintenance": return "Maintenance"
            case "track_vehicle_maintenance": return "Suivez l'entretien de vos véhicules"
            case "total_cost": return "Coût total"
            case "maintenance_singular": return "maintenance"
            case "maintenance_plural": return "maintenances"
            case "vehicle_distribution": return "Répartition par véhicule"
            case "search_maintenance": return "Rechercher une maintenance"
            case "all_vehicles": return "Tous les véhicules"
            case "all": return "Tous"
            case "no_maintenance": return "Aucune maintenance"
            case "add_first_maintenance": return "Commencez par ajouter votre première maintenance pour suivre l'entretien"
            case "add_maintenance": return "Ajouter une maintenance"
            case "add_new_maintenance": return "Ajouter une nouvelle maintenance"
            case "view_details": return "Voir détails"
            case "edit": return "Modifier"
            case "delete": return "Supprimer"
            case "cancel": return "Annuler"
            case "delete_maintenance_title": return "Supprimer la maintenance ?"
            case "delete_maintenance_message": return "Cette action ne peut pas être annulée."
            case "maintenance_type": return "Type"
            case "date": return "Date"
            case "cost": return "Coût"
            case "vehicle": return "Véhicule"
            case "search_maintenance_placeholder": return "Rechercher une maintenance..."
            case "vehicles_filter": return "Véhicules"
            case "all_maintenances": return "Toutes les maintenances"
            case "no_maintenance_title": return "Aucune maintenance"
            case "no_maintenance_message": return "Commencez à enregistrer les maintenances de vos véhicules pour un suivi optimal."
            default: return key
            }
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 24) {
                        // En-tête moderne avec icône
                        modernHeaderSection
                        
                        // Résumé des maintenances modernisé
                        modernSummarySection
                        
                        // Filtres modernes
                        modernFiltersSection
                        
                        // Liste des maintenances ou état vide
                        if filteredMaintenances.isEmpty {
                            modernEmptyStateView
                } else {
                            modernMaintenanceListSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddSheet) {
                AddMaintenanceView(vehicles: vehicles) { maintenance in
                    viewModel.addMaintenance(maintenance)
                }
            }
            .sheet(item: $editingMaintenance) { maintenance in
                EditMaintenanceView(maintenance: maintenance) { updated in
                    viewModel.updateMaintenance(updated)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                // Bouton flottant unifié
                if !filteredMaintenances.isEmpty {
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.orange, .orange.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .accessibilityLabel(MaintenanceView.localText("add_new_maintenance", language: appLanguage))
                    .accessibilityHint("Touchez pour ouvrir le formulaire d'ajout de maintenance")
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
                                        colors: [.orange.opacity(0.15), .orange.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: "wrench.and.screwdriver.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.orange)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(MaintenanceView.localText("maintenance", language: appLanguage))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(MaintenanceView.localText("track_vehicle_maintenance", language: appLanguage))
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
                        Text(MaintenanceView.localText("total_cost", language: appLanguage))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "%.2f €", totalCost))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(filteredMaintenances.count)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text(filteredMaintenances.count > 1 ? MaintenanceView.localText("maintenance_plural", language: appLanguage) : MaintenanceView.localText("maintenance_singular", language: appLanguage))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Statistiques par véhicule
                if !vehicleStats.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(MaintenanceView.localText("vehicle_distribution", language: appLanguage))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(vehicleStats.prefix(3), id: \.0) { vehicle, cost in
                                HStack {
                                    Circle()
                                        .fill(.orange.opacity(0.7))
                                        .frame(width: 12, height: 12)
                                    
                                    Text(vehicle)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text(String(format: "%.0f €", cost))
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
    
    private var modernFiltersSection: some View {
        VStack(spacing: 16) {
            // Barre de recherche moderne
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField(MaintenanceView.localText("search_maintenance_placeholder", language: appLanguage), text: $searchText)
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
            
            // Filtre par véhicule
            if !uniqueVehicles.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(MaintenanceView.localText("vehicles_filter", language: appLanguage))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ModernMaintenanceFilterChip(
                                title: MaintenanceView.localText("all", language: appLanguage),
                                isSelected: selectedVehicle == "all_vehicles"
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedVehicle = "all_vehicles"
                                }
                            }
                            
                            ForEach(uniqueVehicles, id: \.self) { vehicle in
                                ModernMaintenanceFilterChip(
                                    title: vehicle,
                                    isSelected: selectedVehicle == vehicle
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedVehicle = vehicle
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
        }
    }
    
    private var modernMaintenanceListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(MaintenanceView.localText("all_maintenances", language: appLanguage))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 12) {
                ForEach(filteredMaintenances) { maintenance in
                    ModernMaintenanceCard(
                        maintenance: maintenance,
                        onEdit: { editingMaintenance = $0 },
                        onDelete: { viewModel.deleteMaintenance($0) }
                    )
                    .transition(.asymmetric(
                        insertion: .slide.combined(with: .opacity),
                        removal: .opacity.combined(with: .scale(scale: 0.8))
                    ))
                }
            }
        }
    }
    
    private var modernEmptyStateView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 20) {
                // Illustration moderne
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.1), .orange.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(.orange.opacity(0.6))
                }
                
                VStack(spacing: 12) {
                    Text(MaintenanceView.localText("no_maintenance_title", language: appLanguage))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(MaintenanceView.localText("no_maintenance_message", language: appLanguage))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
            }
            
            Button(action: { showingAddSheet = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text(MaintenanceView.localText("add_maintenance", language: appLanguage))
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.orange, .orange.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .orange.opacity(0.3), radius: 12, x: 0, y: 6)
            }
        }
        .padding(.vertical, 60)
    }
    
    // MARK: - Computed Properties
    
    private var filteredMaintenances: [Maintenance] {
        var filtered = viewModel.filteredMaintenances
        
        // Filtre par recherche
        if !searchText.isEmpty {
            filtered = filtered.filter { maintenance in
                maintenance.titre.localizedCaseInsensitiveContains(searchText) ||
                maintenance.description.localizedCaseInsensitiveContains(searchText) ||
                maintenance.garage.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filtre par véhicule
        if selectedVehicle != "all_vehicles" {
            filtered = filtered.filter { $0.vehicule == selectedVehicle }
        }
        
        return filtered.sorted { $0.date > $1.date }
    }
    
    private var totalCost: Double {
        filteredMaintenances.reduce(0) { $0 + $1.cout }
    }
    
    private var uniqueVehicles: [String] {
        Array(Set(viewModel.filteredMaintenances.map { $0.vehicule })).sorted()
    }
    
    private var vehicleStats: [(String, Double)] {
        Dictionary(grouping: filteredMaintenances, by: { $0.vehicule })
            .map { ($0.key, $0.value.reduce(0) { $0 + $1.cout }) }
            .sorted { $0.1 > $1.1 }
    }
}

// MARK: - Supporting Views

struct ModernMaintenanceFilterChip: View {
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
                                colors: [.orange, .orange.opacity(0.8)],
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
                    color: isSelected ? .orange.opacity(0.3) : .black.opacity(0.05),
                    radius: isSelected ? 8 : 2,
                    x: 0,
                    y: isSelected ? 4 : 1
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ModernMaintenanceCard: View {
    let maintenance: Maintenance
    var onEdit: (Maintenance) -> Void
    var onDelete: (Maintenance) -> Void
    @State private var showDeleteAlert = false
    @AppStorage("app_language") private var appLanguage: String = "fr"
    
    var body: some View {
        HStack(spacing: 16) {
            // Icône compacte
            Circle()
                .fill(.orange.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.orange)
                )
            
            // Informations principales
            VStack(alignment: .leading, spacing: 2) {
                Text(maintenance.titre)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(maintenance.vehicule)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 1) {
                        Text(maintenance.date.formatted(.dateTime.day().month()))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(maintenance.date.formatted(.dateTime.year()))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("•")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(maintenance.kilometrage) km")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Prix et menu
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.0f €", maintenance.cout))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Menu {
                    Button(action: { onEdit(maintenance) }) {
                        Label(MaintenanceView.localText("edit", language: appLanguage), systemImage: "pencil")
                    }
                    Button(role: .destructive, action: { showDeleteAlert = true }) {
                        Label(MaintenanceView.localText("delete", language: appLanguage), systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text(MaintenanceView.localText("delete_maintenance_title", language: appLanguage)),
                message: Text(MaintenanceView.localText("delete_maintenance_message", language: appLanguage)),
                primaryButton: .destructive(Text(MaintenanceView.localText("delete", language: appLanguage))) { onDelete(maintenance) },
                secondaryButton: .cancel(Text(MaintenanceView.localText("cancel", language: appLanguage)))
            )
        }
    }
}

#Preview {
    MaintenanceView(vehicles: [], viewModel: MaintenanceViewModel())
} 