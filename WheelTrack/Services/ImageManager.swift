import Foundation
import UIKit
import PhotosUI
import SwiftUI

// MARK: - Image Manager Service
@MainActor
class ImageManager: ObservableObject {
    static let shared = ImageManager()
    
    private init() {}
    
    // MARK: - Répertoires
    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    // Dossier Photos pour les images de véhicules
    private var photosURL: URL {
        documentsURL.appendingPathComponent("Photos")
    }
    
    // Photos principales de véhicules
    private var vehicleMainPhotosURL: URL {
        photosURL
    }
    
    // Photos supplémentaires de véhicules
    private var vehicleAdditionalPhotosURL: URL {
        photosURL.appendingPathComponent("Supplementaires")
    }
    
    // Documents de véhicules (carte grise, assurance, etc.)
    private var vehicleDocumentsURL: URL {
        documentsURL.appendingPathComponent("VehicleDocuments")
    }
    
    // Reçus de dépenses
    private var expenseImagesURL: URL {
        documentsURL.appendingPathComponent("ExpenseImages")
    }
    
    // Photos de maintenance
    private var maintenanceImagesURL: URL {
        documentsURL.appendingPathComponent("MaintenanceImages")
    }
    
    // MARK: - Initialisation
    func createDirectoriesIfNeeded() {
        let directories = [
            vehicleMainPhotosURL,
            vehicleAdditionalPhotosURL,
            vehicleDocumentsURL,
            expenseImagesURL,
            maintenanceImagesURL
        ]
        
        for directory in directories {
            if !FileManager.default.fileExists(atPath: directory.path) {
                try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            }
        }
    }
    
    // MARK: - Sauvegarde d'images
    func saveImage(_ image: UIImage, to category: ImageCategory, withName name: String? = nil) -> String? {
        let fileName = name ?? UUID().uuidString + ".jpg"
        let directoryURL: URL
        
        switch category {
        case .vehicleMainPhoto:
            directoryURL = vehicleMainPhotosURL
        case .vehicleAdditionalPhoto:
            directoryURL = vehicleAdditionalPhotosURL
        case .vehicleDocument:
            directoryURL = vehicleDocumentsURL
        case .expense:
            directoryURL = expenseImagesURL
        case .maintenance:
            directoryURL = maintenanceImagesURL
        }
        
        let fileURL = directoryURL.appendingPathComponent(fileName)
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        do {
            try imageData.write(to: fileURL)
            return fileName
        } catch {
            print("Erreur lors de la sauvegarde de l'image: \(error)")
            return nil
        }
    }
    
    // MARK: - Récupération d'images
    func loadImage(fileName: String, from category: ImageCategory) -> UIImage? {
        let directoryURL: URL
        
        switch category {
        case .vehicleMainPhoto:
            directoryURL = vehicleMainPhotosURL
        case .vehicleAdditionalPhoto:
            directoryURL = vehicleAdditionalPhotosURL
        case .vehicleDocument:
            directoryURL = vehicleDocumentsURL
        case .expense:
            directoryURL = expenseImagesURL
        case .maintenance:
            directoryURL = maintenanceImagesURL
        }
        
        let fileURL = directoryURL.appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    // MARK: - Suppression d'images
    func deleteImage(fileName: String, from category: ImageCategory) -> Bool {
        let directoryURL: URL
        
        switch category {
        case .vehicleMainPhoto:
            directoryURL = vehicleMainPhotosURL
        case .vehicleAdditionalPhoto:
            directoryURL = vehicleAdditionalPhotosURL
        case .vehicleDocument:
            directoryURL = vehicleDocumentsURL
        case .expense:
            directoryURL = expenseImagesURL
        case .maintenance:
            directoryURL = maintenanceImagesURL
        }
        
        let fileURL = directoryURL.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            return true
        } catch {
            print("Erreur lors de la suppression de l'image: \(error)")
            return false
        }
    }
    
    // MARK: - Redimensionnement d'image
    func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    // MARK: - Compression intelligente
    func compressImage(_ image: UIImage, maxSizeKB: Int = 500) -> UIImage? {
        var compressionQuality: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compressionQuality)
        
        while let data = imageData, data.count > maxSizeKB * 1024 && compressionQuality > 0.1 {
            compressionQuality -= 0.1
            imageData = image.jpegData(compressionQuality: compressionQuality)
        }
        
        guard let finalData = imageData else { return nil }
        return UIImage(data: finalData)
    }
}

// MARK: - Enums et structures de support
enum ImageCategory {
    case vehicleMainPhoto       // Photo principale du véhicule → Documents/Photos/
    case vehicleAdditionalPhoto // Photos supplémentaires → Documents/Photos/Supplementaires/
    case vehicleDocument        // Documents (carte grise, etc.) → Documents/VehicleDocuments/
    case expense               // Reçus de dépenses → Documents/ExpenseImages/
    case maintenance           // Photos de maintenance → Documents/MaintenanceImages/
}

// MARK: - Photo Picker Coordinator
struct PhotoPickerCoordinator: UIViewControllerRepresentable {
    let allowsMultipleSelection: Bool
    let maxSelectionCount: Int
    let onPicked: ([UIImage]) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = allowsMultipleSelection ? maxSelectionCount : 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerCoordinator
        
        init(_ parent: PhotoPickerCoordinator) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard !results.isEmpty else { return }
            
            var images: [UIImage] = []
            let group = DispatchGroup()
            
            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                    if let uiImage = image as? UIImage {
                        DispatchQueue.main.async {
                            images.append(uiImage)
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.parent.onPicked(images)
            }
        }
    }
} 