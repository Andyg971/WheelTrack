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
    
    private var vehicleImagesURL: URL {
        documentsURL.appendingPathComponent("VehicleImages")
    }
    
    private var expenseImagesURL: URL {
        documentsURL.appendingPathComponent("ExpenseImages")
    }
    
    private var maintenanceImagesURL: URL {
        documentsURL.appendingPathComponent("MaintenanceImages")
    }
    
    // MARK: - Initialisation
    func createDirectoriesIfNeeded() {
        let directories = [vehicleImagesURL, expenseImagesURL, maintenanceImagesURL]
        
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
        case .vehicle:
            directoryURL = vehicleImagesURL
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
        case .vehicle:
            directoryURL = vehicleImagesURL
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
        case .vehicle:
            directoryURL = vehicleImagesURL
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
    case vehicle
    case expense
    case maintenance
}

// MARK: - Photo Picker Coordinator
struct PhotoPickerCoordinator: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    let allowsMultipleSelection: Bool
    let maxSelectionCount: Int
    @Environment(\.dismiss) private var dismiss
    
    init(selectedImages: Binding<[UIImage]>, allowsMultipleSelection: Bool = false, maxSelectionCount: Int = 1) {
        self._selectedImages = selectedImages
        self.allowsMultipleSelection = allowsMultipleSelection
        self.maxSelectionCount = maxSelectionCount
    }
    
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
            
            var newImages: [UIImage] = []
            let group = DispatchGroup()
            
            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            newImages.append(image)
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.parent.selectedImages = newImages
            }
        }
    }
} 