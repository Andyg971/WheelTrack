import SwiftUI
import Foundation

struct VehicleDetailView: View {
    let vehicle: Vehicle
    @ObservedObject var expensesViewModel: ExpensesViewModel
    @ObservedObject var maintenanceViewModel: MaintenanceViewModel
    @State private var selectedTab: VehicleDetailTab = .info
    @State private var showingAddMaintenance = false
    @State private var showingAddExpense = false
    @AppStorage("app_language") private var appLanguage = "fr"
    
    // Fonction de localisation
    static func localText(_ key: String, language: String) -> String {
        switch key {
        case "add_maintenance":
            return language == "en" ? "Add Maintenance" : "Ajouter une maintenance"
        case "add_expense":
            return language == "en" ? "Add Expense" : "Ajouter une dépense"
        case "no_maintenance":
            return language == "en" ? "No maintenance" : "Aucune maintenance"
        case "no_expense":
            return language == "en" ? "No expense" : "Aucune dépense"
        case "active":
            return language == "en" ? "Active" : "Actif"
        case "inactive":
            return language == "en" ? "Inactive" : "Inactif"
        case "maintenance_summary":
            return language == "en" ? "Maintenance Summary" : "Résumé maintenance"
        case "expense_summary":
            return language == "en" ? "Expense Summary" : "Résumé dépenses"
        case "total_maintenances":
            return language == "en" ? "Total maintenances" : "Total maintenances"
        case "total_amount":
            return language == "en" ? "Total amount" : "Montant total"
        case "total_expenses":
            return language == "en" ? "Total expenses" : "Total dépenses"
        case "rental_summary":
            return language == "en" ? "Rental Summary" : "Résumé location"
        case "total_contracts":
            return language == "en" ? "Total contracts" : "Total contrats"
        case "active_contracts":
            return language == "en" ? "Active contracts" : "Contrats actifs"
        case "total_revenue":
            return language == "en" ? "Total revenue" : "Revenus totaux"
        case "no_rental_contract":
            return language == "en" ? "No rental contract" : "Aucun contrat de location"
        case "create_first_contract":
            return language == "en" ? "Start by creating your first contract" : "Commencez par créer votre premier contrat"
        case "create_contract":
            return language == "en" ? "Create Contract" : "Créer un contrat"
        default:
            return key
        }
    }
    
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
                    
                    VehicleRentalTabView(vehicle: vehicle)
                        .tag(VehicleDetailTab.rental)
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
                        
                        Text(vehicle.isActive ? VehicleDetailView.localText("active", language: appLanguage) : VehicleDetailView.localText("inactive", language: appLanguage))
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
                let isSelected = selectedTab == tab
                let color = tab == .maintenance ? Color.orange : Color.blue
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isSelected ? color : .secondary)
                        
                        Text(tab.title)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(isSelected ? color : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        Rectangle()
                            .fill(isSelected ? color.opacity(0.1) : Color.clear)
                    )
                    .overlay(
                        Rectangle()
                            .fill(isSelected ? color : Color.clear)
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
    case rental
    
    var title: String {
        switch self {
        case .info: return "Infos"
        case .maintenance: return "Maintenance"
        case .expenses: return "Dépenses"
        case .rental: return "Location"
        }
    }
    
    var icon: String {
        switch self {
        case .info: return "info.circle"
        case .maintenance: return "wrench"
        case .expenses: return "dollarsign.circle"
        case .rental: return "key.fill"
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
                VehicleInfoCard(title: "Informations générales") {
                    VStack(spacing: 12) {
                        VehicleInfoRow(label: "Plaque d'immatriculation", value: vehicle.licensePlate)
                        VehicleInfoRow(label: "Couleur", value: vehicle.color)
                        VehicleInfoRow(label: "Transmission", value: vehicle.transmission.rawValue)
                        VehicleInfoRow(label: "Kilométrage", value: "\(Int(vehicle.mileage).formatted()) km")
                    }
                }
                
                // Informations d'achat
                VehicleInfoCard(title: "Achat") {
                    VStack(spacing: 12) {
                        VehicleInfoRow(label: "Date d'achat", value: vehicle.purchaseDate.formatted(date: .abbreviated, time: .omitted))
                        VehicleInfoRow(label: "Prix d'achat", value: String(format: "%.2f €", vehicle.purchasePrice))
                        VehicleInfoRow(label: "Kilométrage à l'achat", value: "\(Int(vehicle.purchaseMileage).formatted()) km")
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
    @AppStorage("app_language") private var appLanguage = "fr"
    
    private var vehicleMaintenances: [Maintenance] {
        maintenanceViewModel.maintenances.filter { maintenance in
            maintenance.vehicule == vehicle.brand || maintenance.vehicule.contains(vehicle.model)
        }.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Résumé des maintenances
                VehicleInfoCard(title: VehicleDetailView.localText("maintenance_summary", language: appLanguage)) {
                    VStack(spacing: 12) {
                        HStack {
                            Text(VehicleDetailView.localText("total_maintenances", language: appLanguage))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(vehicleMaintenances.count)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text(VehicleDetailView.localText("total_amount", language: appLanguage))
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
                        
                        Text(VehicleDetailView.localText("no_maintenance", language: appLanguage))
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button(VehicleDetailView.localText("add_maintenance", language: appLanguage), action: onAddMaintenance)
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
    @AppStorage("app_language") private var appLanguage = "fr"
    
    private var vehicleExpenses: [Expense] {
        expensesViewModel.expenses.filter { $0.vehicleId == vehicle.id }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Résumé des dépenses
                VehicleInfoCard(title: VehicleDetailView.localText("expense_summary", language: appLanguage)) {
                    VStack(spacing: 12) {
                        HStack {
                            Text(VehicleDetailView.localText("total_expenses", language: appLanguage))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(vehicleExpenses.count)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text(VehicleDetailView.localText("total_amount", language: appLanguage))
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
                        
                        Text(VehicleDetailView.localText("no_expense", language: appLanguage))
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button(VehicleDetailView.localText("add_expense", language: appLanguage), action: onAddExpense)
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

// MARK: - Rental Tab View

struct VehicleRentalTabView: View {
    let vehicle: Vehicle
    private var rentalService: RentalService { RentalService.shared }
    @State private var showingAddRental = false
    @AppStorage("app_language") private var appLanguage = "fr"
    
    private var vehicleContracts: [RentalContract] {
        rentalService.getRentalContracts(for: vehicle.id).sorted { $0.startDate > $1.startDate }
    }
    
    private var activeContracts: [RentalContract] {
        vehicleContracts.filter { $0.isActive() }
    }
    
    private var upcomingContracts: [RentalContract] {
        let now = Date()
        return vehicleContracts.filter { $0.startDate > now }
    }
    
    private var totalRevenue: Double {
        vehicleContracts.reduce(0) { $0 + $1.totalPrice }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Résumé des locations
                VehicleInfoCard(title: VehicleDetailView.localText("rental_summary", language: appLanguage)) {
                    VStack(spacing: 12) {
                        HStack {
                            Text(VehicleDetailView.localText("total_contracts", language: appLanguage))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(vehicleContracts.count)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text(VehicleDetailView.localText("active_contracts", language: appLanguage))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(activeContracts.count)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text(VehicleDetailView.localText("total_revenue", language: appLanguage))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "%.2f €", totalRevenue))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // Liste des contrats
                if vehicleContracts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue.opacity(0.6))
                        
                        Text(VehicleDetailView.localText("no_rental_contract", language: appLanguage))
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(VehicleDetailView.localText("create_first_contract", language: appLanguage))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(VehicleDetailView.localText("create_contract", language: appLanguage), action: { showingAddRental = true })
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                    }
                    .padding(40)
                } else {
                    ForEach(vehicleContracts) { contract in
                        RentalContractCard(contract: contract, vehicle: vehicle, statusColor: getStatusColor(for: contract))
                    }
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingAddRental) {
            AddRentalContractView(vehicle: vehicle)
        }
    }
    
    private func getStatusColor(for contract: RentalContract) -> Color {
        if contract.renterName.trimmingCharacters(in: .whitespaces).isEmpty {
            return .orange
        }
        
        switch contract.getStatus() {
        case "Actif":
            return .green
        case "À venir":
            return .blue
        default:
            return .gray
        }
    }
}

// MARK: - Supporting Views

struct VehicleInfoCard<Content: View>: View {
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

struct VehicleInfoRow: View {
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

struct RentalContractCard: View {
    let contract: RentalContract
    let vehicle: Vehicle
    let statusColor: Color
    
    private var isPrefilledContract: Bool {
        contract.renterName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var statusText: String {
        if isPrefilledContract {
            return L(("À compléter", "To complete"))
        }
        return contract.getStatus()
    }
    
    private var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: contract.startDate)) - \(formatter.string(from: contract.endDate))"
    }
    
    var body: some View {
        NavigationLink(destination: RentalContractDetailView(contract: contract, vehicle: vehicle)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if isPrefilledContract {
                            Text(L(("Contrat à compléter", "Contract to complete")))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        } else {
                            Text(contract.renterName)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        
                        Text(statusText)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(statusColor)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "%.0f €", contract.totalPrice))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        if isPrefilledContract {
                            HStack(spacing: 8) {
                                Text(L(("Prêt", "Ready")))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.orange)
                                    .clipShape(Capsule())
                            }
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(statusColor)
                        }
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Text(formattedDateRange)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(contract.numberOfDays) jour\(contract.numberOfDays > 1 ? "s" : "")")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                    }
                    
                    HStack {
                        Image(systemName: "eurosign.circle")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Text("\(String(format: "%.0f", contract.pricePerDay))€/jour")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if isPrefilledContract {
                            Text(L(("À compléter", "To complete")))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isPrefilledContract ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
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