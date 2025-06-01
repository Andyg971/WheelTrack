import Foundation
import CloudKit

/// Service pour synchroniser les dépenses avec CloudKit
class CloudKitExpenseService {
    static let shared = CloudKitExpenseService()
    private let container = CKContainer.default()
    private let recordType = "Expense"
    
    // Enregistre une dépense dans CloudKit
    func saveExpense(_ expense: Expense, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let record = CKRecord(recordType: recordType, recordID: CKRecord.ID(recordName: expense.id.uuidString))
        record["vehicleId"] = expense.vehicleId.uuidString as CKRecordValue
        record["date"] = expense.date as CKRecordValue
        record["amount"] = expense.amount as CKRecordValue
        record["category"] = expense.category.rawValue as CKRecordValue
        record["description"] = expense.description as CKRecordValue
        // Ajoute d'autres champs si besoin
        container.privateCloudDatabase.save(record) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion?(.failure(error))
                } else {
                    completion?(.success(()))
                }
            }
        }
    }
    
    // Charge toutes les dépenses depuis CloudKit
    func fetchExpenses(completion: @escaping (Result<[Expense], Error>) -> Void) {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        if #available(iOS 15.0, *) {
            container.privateCloudDatabase.fetch(
                withQuery: query,
                inZoneWith: nil,
                desiredKeys: nil,
                resultsLimit: CKQueryOperation.maximumResults
            ) { result in
                DispatchQueue.main.async {
                    self.handleCloudKitResult(result: result, completion: completion)
                }
            }
        } else {
            container.privateCloudDatabase.perform(query, inZoneWith: nil) { records, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        let expenses = records?.compactMap { record in
                            guard let vehicleIdStr = record["vehicleId"] as? String,
                                  let vehicleId = UUID(uuidString: vehicleIdStr),
                                  let date = record["date"] as? Date,
                                  let amount = record["amount"] as? Double,
                                  let categoryStr = record["category"] as? String,
                                  let category = ExpenseCategory(rawValue: categoryStr),
                                  let description = record["description"] as? String else { return nil }
                            return Expense(id: UUID(uuidString: record.recordID.recordName) ?? UUID(), vehicleId: vehicleId, date: date, amount: amount, category: category, description: description)
                        } ?? [Expense]()
                        completion(.success(expenses))
                    }
                }
            }
        }
    }
    
    // Supprime une dépense de CloudKit
    func deleteExpense(_ expense: Expense, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let recordID = CKRecord.ID(recordName: expense.id.uuidString)
        container.privateCloudDatabase.delete(withRecordID: recordID) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion?(.failure(error))
                } else {
                    completion?(.success(()))
                }
            }
        }
    }
    
    private func handleCloudKitResult(
        result: Result<(matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?), Error>,
        completion: @escaping (Result<[Expense], Error>) -> Void
    ) {
        switch result {
        case .success(let (matchResults, _)):
            var records = [CKRecord]()
            for (_, result) in matchResults {
                if let record = try? result.get() {
                    records.append(record)
                }
            }
            let expenses: [Expense] = records.compactMap { record in
                guard let vehicleIdStr = record["vehicleId"] as? String,
                      let vehicleId = UUID(uuidString: vehicleIdStr),
                      let date = record["date"] as? Date,
                      let amount = record["amount"] as? Double,
                      let categoryStr = record["category"] as? String,
                      let category = ExpenseCategory(rawValue: categoryStr),
                      let description = record["description"] as? String else { return nil }
                return Expense(id: UUID(uuidString: record.recordID.recordName) ?? UUID(), vehicleId: vehicleId, date: date, amount: amount, category: category, description: description)
            }
            completion(.success(expenses))
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

// Explications pédagogiques :
// - Ce service permet d'enregistrer, charger et supprimer des dépenses dans iCloud (CloudKit).
// - Utilise la base privée de l'utilisateur (sécurité et confidentialité).
// - À utiliser dans le ViewModel pour synchroniser les données locales et cloud. 