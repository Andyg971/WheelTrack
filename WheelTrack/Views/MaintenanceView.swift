import SwiftUI

public struct MaintenanceView: View {
    let vehicles: [Vehicle]
    @ObservedObject var viewModel: MaintenanceViewModel
    @State private var showingAddSheet = false
    @State private var editingMaintenance: Maintenance? = nil
    @State private var searchText = ""
    @State private var selectedVehicle: String = "Tous"
    
    init(vehicles: [Vehicle], viewModel: MaintenanceViewModel) {
        self.vehicles = vehicles
        self.viewModel = viewModel
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
                // Bouton flottant discret uniquement quand il y a des maintenances
                if !filteredMaintenances.isEmpty {
                    Button(action: { showingAddSheet = true }) {
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
                            Text("Maintenance")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Suivez l'entretien de vos véhicules")
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
                        Text("Coût total")
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
                        
                        Text(filteredMaintenances.count > 1 ? "maintenances" : "maintenance")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Statistiques par véhicule
                if !vehicleStats.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Répartition par véhicule")
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
                
                TextField("Rechercher une maintenance...", text: $searchText)
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
                    Text("Véhicules")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ModernMaintenanceFilterChip(
                                title: "Tous",
                                isSelected: selectedVehicle == "Tous"
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedVehicle = "Tous"
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
            Text("Toutes les maintenances")
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
                    Text("Aucune maintenance")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Commencez à enregistrer les maintenances de vos véhicules pour un suivi optimal.")
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
                    Text("Ajouter une maintenance")
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
        if selectedVehicle != "Tous" {
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
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // Icône de maintenance moderne
                ZStack {
                    Circle()
                        .fill(.orange.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.orange)
                }
                
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(maintenance.titre)
                        .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            if !maintenance.description.isEmpty {
                                Text(maintenance.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        
                Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(String(format: "%.2f €", maintenance.cout))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                Menu {
                    Button(action: { onEdit(maintenance) }) {
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
                    
                    // Informations détaillées
                    VStack(spacing: 8) {
                        HStack(spacing: 16) {
                            Label(maintenance.vehicule, systemImage: "car.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Label(maintenance.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 16) {
                            Label(String(format: "%d km", maintenance.kilometrage), systemImage: "speedometer")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 8) {
                                // Badge maintenance
                                Text("Maintenance")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.1))
                                    .clipShape(Capsule())
                                
                                Text(maintenance.vehicule)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Supprimer la maintenance ?"),
                message: Text("Cette action est irréversible."),
                primaryButton: .destructive(Text("Supprimer")) { onDelete(maintenance) },
                secondaryButton: .cancel()
            )
        }
    }
}

#Preview {
    MaintenanceView(vehicles: [], viewModel: MaintenanceViewModel())
} 