import UIKit
import WheelTrack

class DashboardViewController: UIViewController {
    // MARK: - Propriétés
    
    private let dataManager = DataManager.shared
    private let vehicleValuationService = VehicleValuationService.shared
    
    // MARK: - UI Components
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var vehicleSummaryView: VehicleSummaryView = {
        let view = VehicleSummaryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var expenseChartView: ExpenseChartView = {
        let view = ExpenseChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var maintenanceReminderView: MaintenanceReminderView = {
        let view = MaintenanceReminderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var valuationView: ValuationView = {
        let view = ValuationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Tableau de bord"
        
        // Ajout des vues
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(vehicleSummaryView)
        stackView.addArrangedSubview(expenseChartView)
        stackView.addArrangedSubview(maintenanceReminderView)
        stackView.addArrangedSubview(valuationView)
        
        // Configuration des contraintes
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        // Configuration des hauteurs des vues
        NSLayoutConstraint.activate([
            vehicleSummaryView.heightAnchor.constraint(equalToConstant: 200),
            expenseChartView.heightAnchor.constraint(equalToConstant: 300),
            maintenanceReminderView.heightAnchor.constraint(equalToConstant: 150),
            valuationView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    // MARK: - Data Management
    
    private func loadData() {
        let vehicles = dataManager.getAllVehicles()
        updateVehicleSummary(with: vehicles)
        updateExpenseChart(with: vehicles)
        updateMaintenanceReminders(with: vehicles)
        updateValuation(with: vehicles)
    }
    
    private func refreshData() {
        loadData()
    }
    
    // MARK: - UI Updates
    
    private func updateVehicleSummary(with vehicles: [Vehicle]) {
        vehicleSummaryView.update(with: vehicles)
    }
    
    private func updateExpenseChart(with vehicles: [Vehicle]) {
        var totalExpenses: [String: Double] = [:]
        
        for vehicle in vehicles {
            let expenses = dataManager.getExpenses(for: vehicle.id)
            for expense in expenses {
                totalExpenses[expense.category.rawValue, default: 0] += expense.amount
            }
        }
        
        expenseChartView.update(with: totalExpenses)
    }
    
    private func updateMaintenanceReminders(with vehicles: [Vehicle]) {
        var reminders: [MaintenanceReminder] = []
        
        for vehicle in vehicles {
            let maintenances = dataManager.getMaintenances(for: vehicle.id)
            for maintenance in maintenances {
                if let nextDate = maintenance.nextMaintenanceDate,
                   nextDate > Date() {
                    reminders.append(MaintenanceReminder(
                        vehicle: vehicle,
                        maintenance: maintenance,
                        dueDate: nextDate
                    ))
                }
            }
        }
        
        maintenanceReminderView.update(with: reminders)
    }
    
    private func updateValuation(with vehicles: [Vehicle]) {
        var valuations: [VehicleValuation] = []
        
        for vehicle in vehicles {
            let currentValue = vehicleValuationService.calculateVehicleValue(vehicle)
            valuations.append(VehicleValuation(
                vehicle: vehicle,
                currentValue: currentValue,
                depreciationRate: vehicleValuationService.getDepreciationRate(for: vehicle)
            ))
        }
        
        valuationView.update(with: valuations)
    }
}

// MARK: - Supporting Types

struct MaintenanceReminder {
    let vehicle: Vehicle
    let maintenance: Maintenance
    let dueDate: Date
}

struct VehicleValuation {
    let vehicle: Vehicle
    let currentValue: Double
    let depreciationRate: Double
} 