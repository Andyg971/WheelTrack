import UIKit
import WheelTrack

class ValuationView: UIView {
    // MARK: - UI Components
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Évaluation des véhicules"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: 150)
        layout.minimumLineSpacing = 16
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Properties
    
    private var valuations: [VehicleValuation] = []
    
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
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.register(ValuationCell.self, forCellWithReuseIdentifier: "ValuationCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: - Public Methods
    
    func update(with valuations: [VehicleValuation]) {
        self.valuations = valuations
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension ValuationView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return valuations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ValuationCell", for: indexPath) as! ValuationCell
        let valuation = valuations[indexPath.item]
        cell.configure(with: valuation)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ValuationView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let valuation = valuations[indexPath.item]
        if let viewController = findViewController() {
            let detailVC = VehicleDetailViewController(vehicle: valuation.vehicle)
            viewController.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

// MARK: - Helper Methods

extension ValuationView {
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}

// MARK: - ValuationCell

class ValuationCell: UICollectionViewCell {
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var vehicleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var depreciationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        contentView.addSubview(containerView)
        containerView.addSubview(vehicleLabel)
        containerView.addSubview(valueLabel)
        containerView.addSubview(depreciationLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            vehicleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            vehicleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            vehicleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            valueLabel.topAnchor.constraint(equalTo: vehicleLabel.bottomAnchor, constant: 8),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            depreciationLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            depreciationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            depreciationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            depreciationLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Public Methods
    
    func configure(with valuation: VehicleValuation) {
        vehicleLabel.text = "\(valuation.vehicle.brand) \(valuation.vehicle.model)"
        valueLabel.text = formatCurrency(valuation.currentValue)
        depreciationLabel.text = "Dépréciation: \(Int(valuation.depreciationRate * 100))%"
    }
    
    // MARK: - Private Methods
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter.string(from: NSNumber(value: value)) ?? "0€"
    }
} 