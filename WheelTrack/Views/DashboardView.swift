import SwiftUI
import CoreLocation

public struct DashboardView: View {
    @ObservedObject var viewModel: ExpensesViewModel
    @ObservedObject var vehiclesViewModel: VehiclesViewModel
    @State private var selectedTimeRange: TimeRange = .month
    @State private var showingAddExpense = false
    @State private var showingAllExpenses = false
    
    // ✅ Migration vers système centralisé
    @EnvironmentObject var localizationService: LocalizationService
    
    // Service de location pour les statistiques - Force l'observation avec @ObservedObject
    @ObservedObject private var rentalService = RentalService.shared
    
    public init(viewModel: ExpensesViewModel, vehiclesViewModel: VehiclesViewModel) {
        self.viewModel = viewModel
        self.vehiclesViewModel = vehiclesViewModel
    }
    
    // Statistiques de location
    private var vehiclesWithActiveRentals: Int {
        let count = vehiclesViewModel.vehicles.filter { vehicle in
            rentalService.rentalContracts.contains { contract in
                contract.vehicleId == vehicle.id && 
                !contract.renterName.trimmingCharacters(in: .whitespaces).isEmpty &&
                (contract.isActive() || Date() < contract.startDate)
            }
        }.count
        
        // Debug : afficher la mise à jour dans la console
        print("🔄 Dashboard - Véhicules avec locations actives: \(count)")
        return count
    }
    
    private var vehiclesWithPrefilledContracts: Int {
        let count = vehiclesViewModel.vehicles.filter { vehicle in
            rentalService.rentalContracts.contains { contract in
                contract.vehicleId == vehicle.id && 
                contract.renterName.trimmingCharacters(in: .whitespaces).isEmpty
            }
        }.count
        
        // Debug : afficher la mise à jour dans la console
        print("🔄 Dashboard - Véhicules avec contrats préremplis: \(count)")
        return count
    }
    
    private var totalRentalRevenue: Double {
        let revenue = rentalService.rentalContracts
            .filter { !$0.renterName.trimmingCharacters(in: .whitespaces).isEmpty }
            .reduce(0) { $0 + $1.totalPrice }
        
        // Debug : afficher la mise à jour dans la console
        print("🔄 Dashboard - Revenus totaux: \(revenue)€")
        return revenue
    }
    
    // MARK: - Analytics de location (Phase 3) - Version simplifiée
    
    private var currentPeriodRevenue: Double {
        let calendar = Calendar.current
        let now = Date()
        
        return rentalService.rentalContracts
            .filter { !$0.renterName.trimmingCharacters(in: .whitespaces).isEmpty }
            .filter { contract in
                switch selectedTimeRange {
                case .month:
                    return calendar.isDate(contract.startDate, equalTo: now, toGranularity: .month) ||
                           calendar.isDate(contract.endDate, equalTo: now, toGranularity: .month) ||
                           (contract.startDate <= now && contract.endDate >= now)
                case .year:
                    return calendar.isDate(contract.startDate, equalTo: now, toGranularity: .year) ||
                           calendar.isDate(contract.endDate, equalTo: now, toGranularity: .year)
                case .week:
                    return calendar.isDate(contract.startDate, equalTo: now, toGranularity: .weekOfYear) ||
                           calendar.isDate(contract.endDate, equalTo: now, toGranularity: .weekOfYear) ||
                           (contract.startDate <= now && contract.endDate >= now)
                case .quarter:
                    if let quarter = calendar.dateInterval(of: .quarter, for: now) {
                        return quarter.contains(contract.startDate) || quarter.contains(contract.endDate) ||
                               (contract.startDate <= quarter.start && contract.endDate >= quarter.end)
                    }
                    return false
                case .all:
                    return true
                }
            }
            .reduce(0) { $0 + $1.totalPrice }
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // En-tête avec salutation
                    HeaderView()
                    
                    // Résumé des dépenses modernisé
                    ExpenseSummaryCard(
                        total: filteredExpenses.reduce(0) { $0 + $1.amount }, 
                        timeRange: selectedTimeRange,
                        onViewAll: { showingAllExpenses = true }
                    )
                    
                    // Résumé des locations - Toujours visible pour découvrabilité
                    RentalSummaryCard(
                        activeRentals: vehiclesWithActiveRentals,
                        availableVehicles: vehiclesWithPrefilledContracts,
                        currentPeriodRevenue: currentPeriodRevenue,
                        timeRange: selectedTimeRange
                    )
                    
                    // Sélecteur de période moderne
                    TimeRangePicker(selectedTimeRange: $selectedTimeRange)
                    
                    // Graphique des dépenses modernisé
                    if !filteredExpenses.isEmpty {
                        ModernBarChartView(expenses: filteredExpenses, timeRange: selectedTimeRange)
                    }
                    
                    // Section des dernières dépenses
                    RecentExpensesSection(
                        expenses: filteredExpenses,
                        vehicles: vehiclesViewModel.vehicles,
                        onViewAll: { showingAllExpenses = true },
                        onAddExpense: { showingAddExpense = true }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: rentalService.rentalContracts.count) {
                // ✅ Force la recalculation des propriétés calculées pour une réactivité optimale
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddExpense = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .accessibilityLabel(L(CommonTranslations.add) + " " + L(CommonTranslations.expenses))
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(vehicles: vehiclesViewModel.vehicles, onAdd: { expense in
                    viewModel.addExpense(expense)
                })
            }
            .sheet(isPresented: $showingAllExpenses) {
                ExpensesView(viewModel: viewModel, vehiclesViewModel: vehiclesViewModel)
            }
        }
    }
    
    // Filtrage dynamique selon la période sélectionnée
    private var filteredExpenses: [Expense] {
        let calendar = Calendar.current
        let now = Date()
        return viewModel.expenses.filter { expense in
            switch selectedTimeRange {
            case .month:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .year)
            case .week:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .weekOfYear)
            case .quarter:
                if let quarter = calendar.dateInterval(of: .quarter, for: now) {
                    return quarter.contains(expense.date)
                }
                return false
            case .all:
                return true
            }
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    @EnvironmentObject var localizationService: LocalizationService
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(L(CommonTranslations.hello))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(L(CommonTranslations.overview))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Time Range Picker
struct TimeRangePicker: View {
    @Binding var selectedTimeRange: TimeRange
    @EnvironmentObject var localizationService: LocalizationService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L(CommonTranslations.period))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TimeRange.allCases) { range in
                        TimeRangeButton(
                            title: range.localizedName(language: localizationService.currentLanguage),
                            isSelected: selectedTimeRange == range
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTimeRange = range
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

struct TimeRangeButton: View {
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

// MARK: - Modern Expense Summary Card
struct ExpenseSummaryCard: View {
    let total: Double
    let timeRange: TimeRange
    let onViewAll: () -> Void
    @EnvironmentObject var localizationService: LocalizationService
    
    var body: some View {
        VStack(spacing: 20) {
            // En-tête de la carte
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L(CommonTranslations.totalExpenses))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(timeRange.localizedName(language: localizationService.currentLanguage))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                // Icône décorative
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
            
            // Montant principal
            HStack {
                Text("\(total, specifier: "%.2f") €")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            // Bouton d'action
            Button(action: onViewAll) {
                HStack {
                    Image(systemName: "list.bullet")
                        .font(.subheadline)
                    Text(L(CommonTranslations.viewAllExpenses))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue.opacity(0.1))
                .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Rental Summary Card
struct RentalSummaryCard: View {
    let activeRentals: Int
    let availableVehicles: Int
    let currentPeriodRevenue: Double
    let timeRange: TimeRange
    @EnvironmentObject var localizationService: LocalizationService
    
    private var hasRentals: Bool {
        currentPeriodRevenue > 0 || activeRentals > 0
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                // Icône moderne
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green.opacity(0.15), .green.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "key.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(L(CommonTranslations.rentals))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Info simple et claire
                    if activeRentals > 0 {
                        Text(L(("\(activeRentals) véhicule\(activeRentals > 1 ? "s" : "") en location", "\(activeRentals) vehicle\(activeRentals > 1 ? "s" : "") rented")))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if availableVehicles > 0 {
                        Text(L(("\(availableVehicles) véhicule\(availableVehicles > 1 ? "s" : "") disponible\(availableVehicles > 1 ? "s" : "")", "\(availableVehicles) vehicle\(availableVehicles > 1 ? "s" : "") available")))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text(L(CommonTranslations.noActiveRental))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Focus sur les revenus de la période
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.0f €", currentPeriodRevenue))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(currentPeriodRevenue > 0 ? .green : .secondary)
                
                Text(timeRange.localizedName(language: localizationService.currentLanguage))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Recent Expenses Section
struct RecentExpensesSection: View {
    let expenses: [Expense]
    let vehicles: [Vehicle]
    let onViewAll: () -> Void
    let onAddExpense: () -> Void
    @EnvironmentObject var localizationService: LocalizationService
    
    private var recentExpenses: [Expense] {
        Array(expenses.sorted { $0.date > $1.date }.prefix(5))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // En-tête de section
            HStack {
                Text(L(CommonTranslations.recentExpenses))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
                
                if !expenses.isEmpty {
                    Button(L(CommonTranslations.viewAllExpenses)) {
                        onViewAll()
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                }
            }
            
            // Contenu
            if expenses.isEmpty {
                EmptyExpensesView(onAddExpense: onAddExpense)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(recentExpenses) { expense in
                        ModernExpenseRowView(
                            expense: expense,
                            vehicle: vehicles.first(where: { $0.id == expense.vehicleId })
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Empty Expenses View
struct EmptyExpensesView: View {
    let onAddExpense: () -> Void
    @EnvironmentObject var localizationService: LocalizationService
    
    var body: some View {
        VStack(spacing: 20) {
            // Illustration
            Image(systemName: "creditcard")
                .font(.system(size: 48))
                .foregroundColor(.blue.opacity(0.6))
                .frame(width: 80, height: 80)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 8) {
                Text(L(CommonTranslations.noExpenses))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(L(CommonTranslations.addFirstExpense))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onAddExpense) {
                HStack {
                    Image(systemName: "plus")
                    Text(L(CommonTranslations.addExpense))
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(32)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Modern Expense Row View
struct ModernExpenseRowView: View {
    let expense: Expense
    let vehicle: Vehicle?
    
    var body: some View {
        HStack(spacing: 16) {
            // Icône de catégorie
            Circle()
                .fill(
                    LinearGradient(
                        colors: [categoryColor, categoryColor.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: categoryIcon)
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                )
            
            // Informations de la dépense
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.description)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text(expense.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let vehicle = vehicle {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(vehicle.brand) \(vehicle.model)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Montant
            Text("\(expense.amount, specifier: "%.2f") €")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var categoryColor: Color {
        switch expense.category {
        case .fuel: return .blue
        case .maintenance: return .orange
        case .insurance: return .green
        case .tax: return .red
        case .parking: return .purple
        case .cleaning: return .cyan
        case .accessories: return .pink
        case .other: return .gray
        }
    }
    
    private var categoryIcon: String {
        switch expense.category {
        case .fuel: return "fuelpump.fill"
        case .maintenance: return "wrench.fill"
        case .insurance: return "shield.fill"
        case .tax: return "doc.text.fill"
        case .parking: return "parkingsign"
        case .cleaning: return "sparkles"
        case .accessories: return "plus.circle.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Modern Bar Chart View
struct ModernBarChartView: View {
    let expenses: [Expense]
    let timeRange: TimeRange
    @EnvironmentObject var localizationService: LocalizationService
    
    // Regroupe les dépenses par période
    private var groupedData: [(String, Double)] {
        let calendar = Calendar.current
        var groups: [String: Double] = [:]
        
        for expense in expenses {
            let key: String
            switch timeRange {
            case .month, .week:
                let date = calendar.startOfDay(for: expense.date)
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM"
                key = formatter.string(from: date)
            case .year:
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM yyyy"
                key = formatter.string(from: expense.date)
            case .quarter, .all:
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM yyyy"
                key = formatter.string(from: expense.date)
            }
            groups[key, default: 0] += expense.amount
        }
        
        return groups.sorted { $0.key < $1.key }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L(CommonTranslations.expensesEvolution))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if groupedData.isEmpty {
                Text(L(CommonTranslations.noDataToDisplay))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
            GeometryReader { geometry in
                let maxAmount = groupedData.map { $0.1 }.max() ?? 1
                    let barWidth = max(20, (geometry.size.width - 32) / CGFloat(groupedData.count) - 8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(groupedData, id: \.0) { (label, amount) in
                                VStack(spacing: 8) {
                            Spacer()
                                    
                                    // Barre
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.blue, Color.blue.opacity(0.7)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(
                                            width: barWidth,
                                            height: max(4, CGFloat(amount) / CGFloat(maxAmount) * 120)
                                        )
                                        .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                                    
                                    // Label
                            Text(label)
                                .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                        .frame(width: barWidth)
                                        .multilineTextAlignment(.center)
                        }
                            }
                        }
                        .frame(height: 160)
                        .padding(.horizontal, 16)
                    }
                }
                .frame(height: 180)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    DashboardView(viewModel: ExpensesViewModel(), vehiclesViewModel: VehiclesViewModel())
}