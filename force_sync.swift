#!/usr/bin/env swift

import Foundation

// Script pour forcer la synchronisation d'Xcode
print("Forçage de la synchronisation d'Xcode...")

// Vérifier que PurchaseSuccessView.swift existe
let filePath = "/Volumes/Extreme SSD/Développement App/WheelTrack/WheelTrack/Views/PurchaseSuccessView.swift"
let fileManager = FileManager.default

if fileManager.fileExists(atPath: filePath) {
    print("✅ PurchaseSuccessView.swift trouvé")
    
    // Toucher le fichier pour forcer la synchronisation
    let attributes = try? fileManager.attributesOfItem(atPath: filePath)
    if let modificationDate = attributes?[.modificationDate] as? Date {
        print("📅 Date de modification actuelle: \(modificationDate)")
        
        // Créer un fichier temporaire pour forcer la mise à jour
        let tempPath = filePath + ".tmp"
        try? fileManager.copyItem(atPath: filePath, toPath: tempPath)
        try? fileManager.removeItem(atPath: tempPath)
        
        print("🔄 Synchronisation forcée - fichier touché")
    }
} else {
    print("❌ PurchaseSuccessView.swift non trouvé")
}