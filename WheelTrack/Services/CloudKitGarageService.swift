import Foundation
import CloudKit

/// Service pour synchroniser les garages avec CloudKit
class CloudKitGarageService {
    static let shared = CloudKitGarageService()
    private let container = CKContainer.default()
    private let recordType = "Garage"
    
    // MARK: - Méthodes async/await (nouvelles)
    
    /// Charge tous les garages depuis CloudKit (version async)
    func fetchGarages() async throws -> [Garage] {
        return try await withCheckedThrowingContinuation { continuation in
            fetchGarages { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Enregistre un garage dans CloudKit (version async)
    func saveGarage(_ garage: Garage) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            saveGarage(garage) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Met à jour un garage existant dans CloudKit (version async)
    func updateGarage(_ garage: Garage) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            updateGarage(garage) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    /// Supprime un garage de CloudKit (version async)
    func deleteGarage(_ garage: Garage) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            deleteGarage(garage) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    // MARK: - Méthodes avec completion handlers (existantes)
    
    // Enregistre un garage dans CloudKit
    func saveGarage(_ garage: Garage, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let record = CKRecord(recordType: recordType, recordID: CKRecord.ID(recordName: garage.id.uuidString))
        record["nom"] = garage.nom as CKRecordValue
        record["adresse"] = garage.adresse as CKRecordValue
        record["ville"] = garage.ville as CKRecordValue
        record["telephone"] = garage.telephone as CKRecordValue
        record["services"] = garage.services as CKRecordValue
        record["horaires"] = garage.horaires as CKRecordValue
        record["latitude"] = garage.latitude as CKRecordValue
        record["longitude"] = garage.longitude as CKRecordValue
        record["isFavorite"] = garage.isFavorite as CKRecordValue
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
    
    // Met à jour un garage existant dans CloudKit
    func updateGarage(_ garage: Garage, completion: ((Result<Void, Error>) -> Void)? = nil) {
        // Pour CloudKit, la mise à jour est identique à la sauvegarde
        saveGarage(garage, completion: completion)
    }
    
    // Charge tous les garages depuis CloudKit
    func fetchGarages(completion: @escaping (Result<[Garage], Error>) -> Void) {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        container.privateCloudDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let (matchResults, _)):
                    let garages: [Garage] = matchResults.compactMap { (_, recordResult) in
                        switch recordResult {
                        case .success(let record):
                            guard let nom = record["nom"] as? String,
                                  let adresse = record["adresse"] as? String,
                                  let ville = record["ville"] as? String,
                                  let telephone = record["telephone"] as? String,
                                  let services = record["services"] as? [String],
                                  let horaires = record["horaires"] as? String,
                                  let latitude = record["latitude"] as? Double,
                                  let longitude = record["longitude"] as? Double,
                                  let isFavorite = record["isFavorite"] as? Bool else { return nil }
                            return Garage(
                                id: UUID(uuidString: record.recordID.recordName) ?? UUID(),
                                nom: nom,
                                adresse: adresse,
                                ville: ville,
                                telephone: telephone,
                                services: services,
                                horaires: horaires,
                                latitude: latitude,
                                longitude: longitude,
                                isFavorite: isFavorite
                            )
                        case .failure:
                            return nil
                        }
                    }
                    completion(.success(garages))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Supprime un garage de CloudKit
    func deleteGarage(_ garage: Garage, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let recordID = CKRecord.ID(recordName: garage.id.uuidString)
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
} 