import SwiftUI

public struct ExpensesView: View {
    @ObservedObject var viewModel: ExpensesViewModel
    @ObservedObject var vehiclesViewModel: VehiclesViewModel
    @State private var showingAddExpense = false
    @State private var searchText = ""
    @State private var selectedFilter: ExpenseFilter = .all
    @State private var selectedTimeRange: TimeRange = .month
    @State private var editingExpense: Expense? = nil

    // ✅ Migration vers système centralisé
    @EnvironmentObject var localizationService: LocalizationService

    public init(viewModel: ExpensesViewModel, vehiclesViewModel: VehiclesViewModel) {
        self.viewModel = viewModel
        self.vehiclesViewModel = vehiclesViewModel
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // En-tête moderne avec icône
                    modernHeaderSection
                    
                    // Résumé des dépenses modernisé
                    modernSummarySection
                    
                    // Filtres modernes
                    modernFiltersSection
                    
                    // Liste des dépenses ou état vide
                    if viewModel.filteredExpenses.isEmpty {
                        modernEmptyStateView
                    } else {
                        modernExpensesListSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(vehicles: vehiclesViewModel.vehicles, onAdd: { expense in
                viewModel.addExpense(expense)
            })
        }
        .sheet(item: $editingExpense) { expense in
            EditExpenseView(
                expense: expense,
                vehicles: vehiclesViewModel.vehicles,
                onSave: { updatedExpense in
                    viewModel.editExpense(updatedExpense)
                }
            )
        }
        .overlay(alignment: .bottomTrailing) {
            // Bouton flottant unifié
            if !viewModel.filteredExpenses.isEmpty {
                Button(action: {
                    showingAddExpense = true
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
                .accessibilityLabel(L(CommonTranslations.addExpense))
                .accessibilityHint("Touchez pour ouvrir le formulaire d'ajout de dépense")
                .padding(.trailing, 20)
                .padding(.bottom, 30)
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
                            
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L(CommonTranslations.myExpenses))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(L(CommonTranslations.manageVehicleCosts))
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
                        Text(L(CommonTranslations.totalExpenses))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "%.2f €", totalAmount))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(viewModel.filteredExpenses.count)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            Text(viewModel.filteredExpenses.count > 1 ? L(CommonTranslations.expenses) : L(CommonTranslations.expense))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Statistiques par catégorie
                if !categoryStats.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L(CommonTranslations.categoryDistribution))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(categoryStats.prefix(3), id: \.0) { category, amount in
                                HStack {
                                    Circle()
                                        .fill(colorForCategory(category))
                                        .frame(width: 12, height: 12)
                                    
                                    Text(category.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text(String(format: "%.0f €", amount))
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
                
                TextField("Rechercher une dépense...", text: $viewModel.searchText)
                    .font(.system(size: 16))
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { 
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.searchText = ""
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
            
            // Filtres par catégorie
            VStack(alignment: .leading, spacing: 12) {
                Text(L(CommonTranslations.categories))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                                            ForEach(ExpenseFilter.allCases) { filter in
                        FilterChip(
                            title: filter.localizedName(language: localizationService.currentLanguage),
                            isSelected: viewModel.selectedFilter == filter,
                            color: .blue
                        ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.selectedFilter = filter
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            // Sélecteur de période
            VStack(alignment: .leading, spacing: 12) {
                Text(L(CommonTranslations.period))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(TimeRange.allCases) { range in
                            FilterChip(
                                title: range.localizedName(language: localizationService.currentLanguage),
                                isSelected: viewModel.selectedTimeRange == range,
                                color: .blue
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.selectedTimeRange = range
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
    
    private var modernExpensesListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L(CommonTranslations.allExpenses))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredExpenses) { expense in
                    ExpenseRowView(
                        expense: expense,
                        vehicles: vehiclesViewModel.vehicles,
                        onEdit: { editingExpense = $0 },
                        onDelete: { viewModel.deleteExpense($0) }
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
                                colors: [.blue.opacity(0.1), .blue.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "creditcard.trianglebadge.exclamationmark")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(.blue.opacity(0.6))
                }
                
                VStack(spacing: 12) {
                    Text(L(CommonTranslations.noExpensesFound))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(L(CommonTranslations.expensesWillAppearHere))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
            }
            
            Button(action: { showingAddExpense = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text(L(CommonTranslations.addExpense))
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
    
    private var totalAmount: Double {
        viewModel.filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
    private var categoryStats: [(ExpenseCategory, Double)] {
        Dictionary(grouping: viewModel.filteredExpenses, by: { $0.category })
            .map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.1 > $1.1 }
    }
    
    private func colorForCategory(_ category: ExpenseCategory) -> Color {
        switch category {
        case .fuel: return .blue
        case .maintenance: return .orange
        case .insurance: return .green
        case .tax: return .red
        case .parking: return .purple
        case .cleaning: return .cyan
        case .accessories: return .mint
        case .other: return .gray
        }
    }
}

// MARK: - Supporting Views

struct ExpenseRowView: View {
    let expense: Expense
    let vehicles: [Vehicle]
    let onEdit: (Expense) -> Void
    let onDelete: (Expense) -> Void
    @State private var showDeleteAlert = false
    @EnvironmentObject var localizationService: LocalizationService
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // Icône de catégorie moderne
                ZStack {
                    Circle()
                        .fill(colorForCategory.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: iconForCategory)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(colorForCategory)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(expense.category.rawValue)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            if !expense.description.isEmpty {
                                Text(expense.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(String(format: "%.2f €", expense.amount))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Menu {
                                Button(action: { onEdit(expense) }) {
                                    Label(L(CommonTranslations.edit), systemImage: "pencil")
                                }
                                Button(role: .destructive, action: { showDeleteAlert = true }) {
                                    Label(L(CommonTranslations.delete), systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.system(size: 18))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Informations détaillées
                    HStack(spacing: 8) {
                        Text(expense.category.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(categoryColor(for: expense.category))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(categoryColor(for: expense.category).opacity(0.1))
                            .clipShape(Capsule())
                        
                        Text(vehicleName)
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                title: Text(L(CommonTranslations.deleteExpenseTitle)),
                message: Text(L(CommonTranslations.deleteExpenseAlertMessage)),
                primaryButton: .destructive(Text(L(CommonTranslations.delete))) { onDelete(expense) },
                secondaryButton: .cancel()
            )
        }
    }
    
    private var vehicleName: String {
        vehicles.first { $0.id == expense.vehicleId }?.brand ?? L(CommonTranslations.unknownVehicle)
    }
    
    private var colorForCategory: Color {
        switch expense.category {
        case .fuel: return .blue
        case .maintenance: return .orange
        case .insurance: return .green
        case .tax: return .red
        case .parking: return .purple
        case .cleaning: return .cyan
        case .accessories: return .mint
        case .other: return .gray
        }
    }
    
    private func categoryColor(for category: ExpenseCategory) -> Color {
        switch category {
        case .fuel: return .blue
        case .maintenance: return .orange
        case .insurance: return .green
        case .tax: return .red
        case .parking: return .purple
        case .cleaning: return .cyan
        case .accessories: return .mint
        case .other: return .gray
        }
    }
    
    private var iconForCategory: String {
        switch expense.category {
        case .fuel: return "fuelpump.fill"
        case .maintenance: return "wrench.and.screwdriver.fill"
        case .insurance: return "shield.fill"
        case .tax: return "doc.text.fill"
        case .parking: return "parkingsign"
        case .cleaning: return "sparkles"
        case .accessories: return "plus.circle.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

#Preview {
    ExpensesView(
        viewModel: ExpensesViewModel(),
        vehiclesViewModel: VehiclesViewModel()
    )
} 
