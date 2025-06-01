import Foundation

/// Service générique pour la synchronisation avec un backend REST (simulation)
struct APIService {
    /// Simule la récupération d'une liste d'objets depuis un backend
    static func fetch<T: Codable>(endpoint: String, completion: @escaping (Result<[T], Error>) -> Void) {
        // Simulation : retourne une liste vide après un délai
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.success([]))
        }
    }

    /// Simule l'envoi (sauvegarde) d'une liste d'objets vers un backend
    static func save<T: Codable>(_ objects: [T], endpoint: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Simulation : succès après un délai
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.success(()))
        }
    }

    /// Simule la suppression d'un objet sur le backend
    static func delete<T: Codable>(_ object: T, endpoint: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Simulation : succès après un délai
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.success(()))
        }
    }
}

/*
// Exemple d'utilisation :
APIService.fetch(endpoint: "/maintenances") { (result: Result<[Maintenance], Error>) in
    switch result {
    case .success(let maintenances):
        print("Données récupérées :", maintenances)
    case .failure(let error):
        print("Erreur :", error)
    }
}
*/ 