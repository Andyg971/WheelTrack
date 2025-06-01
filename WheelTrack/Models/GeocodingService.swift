import Foundation
import CoreLocation

/// Service pour convertir une adresse en coordonnées GPS (géocodage)
public class GeocodingService {
    public static let shared = GeocodingService()
    private let geocoder = CLGeocoder()
    
    private init() {}

    /// Convertit une adresse en coordonnées GPS (asynchrone)
    public func geocode(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let coordinate = placemarks?.first?.location?.coordinate {
                completion(coordinate)
            } else {
                completion(nil)
            }
        }
    }
} 