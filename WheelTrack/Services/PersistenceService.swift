import Foundation

/// Service générique pour la persistance locale en JSON
struct PersistenceService {
    /// Sauvegarde une liste d'objets Codable dans un fichier JSON local
    static func save<T: Codable>(_ objects: [T], to filename: String) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(objects)
            let url = getDocumentsDirectory().appendingPathComponent(filename)
            try data.write(to: url)
        } catch {
            print("Erreur lors de la sauvegarde de \(filename):", error)
        }
    }

    /// Sauvegarde un seul objet Codable dans un fichier JSON local
    static func save<T: Codable>(_ object: T, to filename: String) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(object)
            let url = getDocumentsDirectory().appendingPathComponent(filename)
            try data.write(to: url)
        } catch {
            print("Erreur lors de la sauvegarde de \(filename):", error)
        }
    }

    /// Charge une liste d'objets Codable depuis un fichier JSON local
    static func load<T: Codable>(_ type: T.Type, from filename: String) -> T? {
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Erreur lors du chargement de \(filename):", error)
            return nil
        }
    }

    /// Retourne le dossier Documents de l'utilisateur
    private static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

/*
// Exemple d'utilisation dans un ViewModel :
// Sauvegarder
PersistenceService.save(maintenances, to: "maintenances.json")
// Charger
let loadedMaintenances = PersistenceService.load([Maintenance].self, from: "maintenances.json") ?? []
*/

// Ce service fonctionne pour n'importe quelle liste d'objets Codable (Maintenance, Garage, Vehicle, etc.)
// Il suffit de donner un nom de fichier différent pour chaque type de données. 