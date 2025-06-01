import Foundation
import WheelTrack

class AcquisitionCalculator {
    // Instance singleton
    static let shared = AcquisitionCalculator()
    
    // MARK: - Propriétés
    
    private let vehicleValuationService = VehicleValuationService.shared
    
    // MARK: - Méthodes publiques
    
    func calculateTotalCost(for vehicle: Vehicle, loanTerm: Int, interestRate: Double) -> AcquisitionCost {
        let purchasePrice = vehicle.purchasePrice
        let downPayment = calculateDownPayment(for: purchasePrice)
        let loanAmount = purchasePrice - downPayment
        let monthlyPayment = calculateMonthlyPayment(amount: loanAmount, term: loanTerm, rate: interestRate)
        let totalInterest = calculateTotalInterest(monthlyPayment: monthlyPayment, term: loanTerm, amount: loanAmount)
        
        return AcquisitionCost(
            purchasePrice: purchasePrice,
            downPayment: downPayment,
            loanAmount: loanAmount,
            monthlyPayment: monthlyPayment,
            totalInterest: totalInterest,
            totalCost: purchasePrice + totalInterest
        )
    }
    
    func calculateROI(for vehicle: Vehicle, rentalPrice: Double, rentalDuration: Int) -> ROICalculation {
        let totalCost = calculateTotalCost(for: vehicle, loanTerm: 60, interestRate: 0.05)
        let monthlyRentalIncome = rentalPrice
        let annualRentalIncome = monthlyRentalIncome * 12
        let estimatedExpenses = calculateEstimatedExpenses(for: vehicle)
        let netAnnualIncome = annualRentalIncome - estimatedExpenses
        let roi = (netAnnualIncome / totalCost.totalCost) * 100
        
        return ROICalculation(
            totalCost: totalCost.totalCost,
            monthlyRentalIncome: monthlyRentalIncome,
            annualRentalIncome: annualRentalIncome,
            estimatedExpenses: estimatedExpenses,
            netAnnualIncome: netAnnualIncome,
            roi: roi
        )
    }
    
    func calculateDepreciation(for vehicle: Vehicle, years: Int) -> [DepreciationYear] {
        var depreciationYears: [DepreciationYear] = []
        let initialValue = vehicle.purchasePrice
        var currentValue = initialValue
        
        for year in 0...years {
            let depreciationRate = vehicleValuationService.getDepreciationRate(for: vehicle)
            let depreciationAmount = currentValue * (1 - depreciationRate)
            currentValue -= depreciationAmount
            
            depreciationYears.append(DepreciationYear(
                year: year,
                value: currentValue,
                depreciationAmount: depreciationAmount
            ))
        }
        
        return depreciationYears
    }
    
    // MARK: - Méthodes privées
    
    private func calculateDownPayment(for purchasePrice: Double) -> Double {
        // 20% d'acompte recommandé
        return purchasePrice * 0.20
    }
    
    private func calculateMonthlyPayment(amount: Double, term: Int, rate: Double) -> Double {
        let monthlyRate = rate / 12 / 100
        let numberOfPayments = Double(term)
        
        let monthlyPayment = amount * (monthlyRate * pow(1 + monthlyRate, numberOfPayments)) /
            (pow(1 + monthlyRate, numberOfPayments) - 1)
        
        return monthlyPayment
    }
    
    private func calculateTotalInterest(monthlyPayment: Double, term: Int, amount: Double) -> Double {
        return (monthlyPayment * Double(term)) - amount
    }
    
    private func calculateEstimatedExpenses(for vehicle: Vehicle) -> Double {
        // Estimation des dépenses annuelles
        let insurance = 1000.0
        let maintenance = 800.0
        let fuel = 2000.0
        let taxes = 500.0
        
        return insurance + maintenance + fuel + taxes
    }
}

// MARK: - Structures de données

struct AcquisitionCost {
    let purchasePrice: Double
    let downPayment: Double
    let loanAmount: Double
    let monthlyPayment: Double
    let totalInterest: Double
    let totalCost: Double
}

struct ROICalculation {
    let totalCost: Double
    let monthlyRentalIncome: Double
    let annualRentalIncome: Double
    let estimatedExpenses: Double
    let netAnnualIncome: Double
    let roi: Double
}

struct DepreciationYear {
    let year: Int
    let value: Double
    let depreciationAmount: Double
} 