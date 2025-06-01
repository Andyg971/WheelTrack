import SwiftUI

struct VehicleDetailView: View {
    let vehicle: Vehicle
    @ObservedObject var expensesViewModel: ExpensesViewModel
    @ObservedObject var maintenanceViewModel: MaintenanceViewModel
    @State private var selectedTab: VehicleDetailTab = .info
    @State private var showingAddMaintenance = false
    @State private var showingAddExpense = false
    
    init(vehicle: Vehicle, expensesViewModel: ExpensesViewModel, maintenanceViewModel: MaintenanceViewModel) {
        self.vehicle = vehicle
        self.expensesViewModel = expensesViewModel
        self.maintenanceViewModel = maintenanceViewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // En-tête du véhicule
                vehicleHeaderView
                
                // Sélecteur d'onglets moderne
                tabPickerView
                
                // Contenu selon l'onglet sélectionné
                TabView(selection: $selectedTab) {
                    VehicleInfoTabView(vehicle: vehicle)
                        .tag(VehicleDetailTab.info)
                    
                    VehicleMaintenanceTabView(
                        vehicle: vehicle,
                        maintenanceViewModel: maintenanceViewModel,
                        onAddMaintenance: { showingAddMaintenance = true }
                    )
                    .tag(VehicleDetailTab.maintenance)
                    
                    VehicleExpensesTabView(
                        vehicle: vehicle,
                        expensesViewModel: expensesViewModel,
                        onAddExpense: { showingAddExpense = true }
                    )
                    .tag(VehicleDetailTab.expenses)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(vehicle.brand)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddMaintenance) {
                AddMaintenanceView(vehicles: [vehicle]) { maintenance in
                    maintenanceViewModel.addMaintenance(maintenance)
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(vehicles: [vehicle]) { expense in
                    expensesViewModel.addExpense(expense)
                }
            }
        }
    }
    
    // MARK: - Header View
    
    private var vehicleHeaderView: some View {
        VStack(spacing: 16) {
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
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: vehicleIcon)
                            .foregroundColor(.white)
                            .font(.system(size: 32, weight: .semibold))
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(vehicle.brand) \(vehicle.model)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        Label("\(vehicle.year)", systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Label(vehicle.fuelType.rawValue, systemImage: "fuelpump")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 12) {
                        Label("\(Int(vehicle.mileage).formatted()) km", systemImage: "speedometer")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Circle()
                            .fill(vehicle.isActive ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                        
                        Text(vehicle.isActive ? "Actif" : "Inactif")
                            .font(.caption)
                            .foregroundColor(vehicle.isActive ? .green : .gray)
                    }
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Tab Picker
    
    private var tabPickerView: some View {
        HStack(spacing: 0) {
            ForEach(VehicleDetailTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedTab == tab ? .blue : .secondary)
                        
                        Text(tab.title)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(selectedTab == tab ? .blue : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        Rectangle()
                            .fill(selectedTab == tab ? Color.blue.opacity(0.1) : Color.clear)
                    )
                    .overlay(
                        Rectangle()
                            .fill(selectedTab == tab ? Color.blue : Color.clear)
                            .frame(height: 2),
                        alignment: .bottom
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    // MARK: - Computed Properties
    
    private var vehicleColor: Color {
        switch vehicle.fuelType {
        case .gasoline: return .blue
        case .diesel: return .orange
        case .electric: return .green
        case .hybrid: return .purple
        case .lpg: return .yellow
        }
    }
    
    private var vehicleIcon: String {
        switch vehicle.fuelType {
        case .gasoline, .diesel: return "car.fill"
        case .electric: return "bolt.car.fill"
        case .hybrid: return "leaf.fill"
        case .lpg: return "fuelpump.fill"
        }
    }
}

// MARK: - Vehicle Detail Tabs

enum VehicleDetailTab: CaseIterable {
    case info
    case maintenance
    case expenses
    
    var title: String {
        switch self {
        case .info: return "Infos"
        case .maintenance: return "Maintenance"
        case .expenses: return "Dépenses"
        }
    }
    
    var icon: String {
        switch self {
        case .info: return "info.circle"
        case .maintenance: return "wrench"
        case .expenses: return "dollarsign.circle"
        }
    }
}

// MARK: - Info Tab View

struct VehicleInfoTabView: View {
    let vehicle: Vehicle
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Informations générales
                InfoCard(title: "Informations générales") {
                    VStack(spacing: 12) {
                        InfoRow(label: "Plaque d'immatriculation", value: vehicle.licensePlate)
                        InfoRow(label: "Couleur", value: vehicle.color)
                        InfoRow(label: "Transmission", value: vehicle.transmission.rawValue)
                        InfoRow(label: "Kilométrage", value: "\(Int(vehicle.mileage).formatted()) km")
                    }
                }
                
                // Informations d'achat
                InfoCard(title: "Achat") {
                    VStack(spacing: 12) {
                        InfoRow(label: "Date d'achat", value: vehicle.purchaseDate.formatted(date: .abbreviated, time: .omitted))
                        InfoRow(label: "Prix d'achat", value: String(format: "%.2f €", vehicle.purchasePrice))
                        InfoRow(label: "Kilométrage à l'achat", value: "\(Int(vehicle.purchaseMileage).formatted()) km")
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Maintenance Tab View

struct VehicleMaintenanceTabView: View {
    let vehicle: Vehicle
    @ObservedObject var maintenanceViewModel: MaintenanceViewModel
    let onAddMaintenance: () -> Void
    
    private var vehicleMaintenances: [Maintenance] {
        maintenanceViewModel.maintenances.filter { maintenance in
            maintenance.vehicule == vehicle.brand || maintenance.vehicule.contains(vehicle.model)
        }.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Résumé des maintenances
                InfoCard(title: "Résumé maintenance") {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Total maintenances")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(vehicleMaintenances.count)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("Coût total")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "%.2f €", vehicleMaintenances.reduce(0) { $0 + $1.cout }))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                // Liste des maintenances
                if vehicleMaintenances.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "wrench")
                            .font(.system(size: 48))
                            .foregroundColor(.orange.opacity(0.6))
                        
                        Text("Aucune maintenance")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button("Ajouter une maintenance", action: onAddMaintenance)
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                    }
                    .padding(40)
                } else {
                    ForEach(vehicleMaintenances) { maintenance in
                        MaintenanceRowView(maintenance: maintenance)
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Expenses Tab View

struct VehicleExpensesTabView: View {
    let vehicle: Vehicle
    @ObservedObject var expensesViewModel: ExpensesViewModel
    let onAddExpense: () -> Void
    
    private var vehicleExpenses: [Expense] {
        expensesViewModel.expenses.filter { $0.vehicleId == vehicle.id }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Résumé des dépenses
                InfoCard(title: "Résumé dépenses") {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Total dépenses")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(vehicleExpenses.count)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("Montant total")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "%.2f €", vehicleExpenses.reduce(0) { $0 + $1.amount }))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                // Liste des dépenses
                if vehicleExpenses.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.blue.opacity(0.6))
                        
                        Text("Aucune dépense")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button("Ajouter une dépense", action: onAddExpense)
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                    }
                    .padding(40)
                } else {
                    ForEach(vehicleExpenses) { expense in
                        ExpenseRowView(
                            expense: expense,
                            vehicles: [vehicle],
                            onEdit: { _ in },
                            onDelete: { _ in }
                        )
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Supporting Views

struct InfoCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            content
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

struct MaintenanceRowView: View {
    let maintenance: Maintenance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(maintenance.titre)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(String(format: "%.2f €", maintenance.cout))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            HStack(spacing: 16) {
                Label(maintenance.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("\(maintenance.kilometrage) km", systemImage: "speedometer")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label(maintenance.garage, systemImage: "building.2")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !maintenance.description.isEmpty {
                Text(maintenance.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VehicleDetailView(
        vehicle: Vehicle(
            brand: "Toyota",
            model: "Corolla",
            year: 2020,
            licensePlate: "AB-123-CD",
            mileage: 50000,
            fuelType: .gasoline,
            transmission: .manual,
            color: "Blanc",
            purchaseDate: Date(),
            purchasePrice: 20000,
            purchaseMileage: 0
        ),
        expensesViewModel: ExpensesViewModel(),
        maintenanceViewModel: MaintenanceViewModel()
    )
} 