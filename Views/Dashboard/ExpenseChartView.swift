import UIKit

class ExpenseChartView: UIView {
    // MARK: - UI Components
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Dépenses par catégorie"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var chartView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var legendStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Properties
    
    private var expenses: [String: Double] = [:]
    private var barViews: [UIView] = []
    private var legendLabels: [UILabel] = []
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        addSubview(titleLabel)
        addSubview(chartView)
        addSubview(legendStackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            chartView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 200),
            
            legendStackView.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 16),
            legendStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            legendStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            legendStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Public Methods
    
    func update(with expenses: [String: Double]) {
        self.expenses = expenses
        clearChart()
        setupChart()
    }
    
    // MARK: - Private Methods
    
    private func clearChart() {
        barViews.forEach { $0.removeFromSuperview() }
        legendLabels.forEach { $0.removeFromSuperview() }
        barViews.removeAll()
        legendLabels.removeAll()
    }
    
    private func setupChart() {
        let total = expenses.values.reduce(0, +)
        guard total > 0 else { return }
        
        let barWidth: CGFloat = 40
        let spacing: CGFloat = 16
        let startX: CGFloat = 16
        var currentX = startX
        
        for (category, amount) in expenses {
            let percentage = amount / total
            let barHeight = chartView.bounds.height * CGFloat(percentage)
            
            // Création de la barre
            let barView = UIView()
            barView.backgroundColor = .systemBlue
            barView.layer.cornerRadius = 4
            barView.translatesAutoresizingMaskIntoConstraints = false
            chartView.addSubview(barView)
            
            // Création du label de la légende
            let legendLabel = UILabel()
            legendLabel.text = "\(category): \(Int(amount))€"
            legendLabel.font = .systemFont(ofSize: 12)
            legendLabel.translatesAutoresizingMaskIntoConstraints = false
            legendStackView.addArrangedSubview(legendLabel)
            
            // Configuration des contraintes
            NSLayoutConstraint.activate([
                barView.leadingAnchor.constraint(equalTo: chartView.leadingAnchor, constant: currentX),
                barView.bottomAnchor.constraint(equalTo: chartView.bottomAnchor, constant: -8),
                barView.widthAnchor.constraint(equalToConstant: barWidth),
                barView.heightAnchor.constraint(equalToConstant: barHeight)
            ])
            
            barViews.append(barView)
            legendLabels.append(legendLabel)
            
            currentX += barWidth + spacing
        }
    }
} 