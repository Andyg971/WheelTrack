# 🚗 Structure Complète de WheelTrack - Guide pour Android/Kotlin

## 📋 Table des Matières
1. [Vue d'ensemble de l'application](#vue-densemble)
2. [Architecture iOS (Swift/SwiftUI)](#architecture-ios)
3. [Structure Android/Kotlin équivalente](#structure-android)
4. [Modèles de données](#modèles-de-données)
5. [Services et logique métier](#services)
6. [Vues et interfaces](#vues)
7. [Fonctionnalités principales](#fonctionnalités)
8. [Mapping iOS → Android](#mapping)

---

## 🎯 Vue d'ensemble de l'application

### Description
WheelTrack est une application complète de gestion automobile permettant de :
- Gérer une flotte de véhicules
- Suivre les dépenses et finances
- Planifier la maintenance
- Gérer les garages partenaires
- Créer et gérer des contrats de location
- Synchroniser les données via le cloud
- Offrir un système freemium/premium

### Technologies iOS utilisées
- **SwiftUI** : Interface utilisateur déclarative
- **CloudKit** : Synchronisation cloud (iCloud)
- **StoreKit 2** : Achats in-app
- **AuthenticationServices** : Apple Sign In
- **CoreLocation** : Géolocalisation
- **UserNotifications** : Notifications push
- **Combine** : Programmation réactive

---

## 🏗️ Architecture iOS (Swift/SwiftUI)

### Structure des dossiers iOS

```
WheelTrack/
├── WheelTrackApp.swift          # Point d'entrée de l'application
├── Models/                      # Modèles de données
│   ├── Vehicle.swift
│   ├── Expense.swift
│   ├── RentalContract.swift
│   ├── Garage.swift
│   ├── Maintenance.swift
│   ├── UserProfile.swift
│   ├── ExpenseFilter.swift
│   ├── VehicleSearchFilter.swift
│   └── TimeRange.swift
├── Views/                       # Interfaces utilisateur
│   ├── ContentView.swift        # Vue principale avec navigation
│   ├── DashboardView.swift      # Tableau de bord
│   ├── VehiclesView.swift        # Liste des véhicules
│   ├── ExpensesView.swift        # Liste des dépenses
│   ├── MaintenanceView.swift     # Liste des maintenances
│   ├── GaragesView.swift         # Liste des garages
│   ├── RentalListView.swift      # Liste des contrats de location
│   ├── UserProfileView.swift     # Profil utilisateur
│   ├── SettingsView.swift        # Réglages
│   ├── PremiumPurchaseView.swift # Achat Premium
│   ├── Forms/                    # Formulaires
│   │   ├── AddVehicleView.swift
│   │   ├── EditVehicleView.swift
│   │   ├── AddExpenseView.swift
│   │   ├── AddMaintenanceView.swift
│   │   ├── AddGarageView.swift
│   │   ├── AddRentalContractView.swift
│   │   └── EditUserProfileView.swift
│   ├── Components/               # Composants réutilisables
│   │   ├── ModernCard.swift
│   │   ├── FloatingActionButton.swift
│   │   ├── PremiumBadge.swift
│   │   ├── PremiumUpgradeAlert.swift
│   │   ├── RentalStatusBadge.swift
│   │   ├── SearchBar.swift
│   │   └── VehicleImageView.swift
│   └── LegalViews/
│       └── PrivacyPolicyView.swift
├── ViewModels/                  # Logique de présentation (MVVM)
│   ├── VehiclesViewModel.swift
│   ├── ExpensesViewModel.swift
│   ├── MaintenanceViewModel.swift
│   └── GaragesViewModel.swift
├── Services/                     # Services métier
│   ├── StoreKitService.swift     # Gestion des achats in-app
│   ├── FreemiumService.swift     # Gestion freemium/premium
│   ├── AppleSignInService.swift  # Authentification Apple
│   ├── LocalizationService.swift # Localisation FR/EN
│   ├── CloudKitExpenseService.swift
│   ├── CloudKitGarageService.swift
│   ├── CloudKitCacheService.swift
│   ├── CloudKitPreferencesService.swift
│   ├── RentalService.swift       # Gestion des contrats de location
│   ├── LocationService.swift     # Géolocalisation
│   ├── NotificationService.swift  # Notifications
│   ├── PersistenceService.swift  # Sauvegarde locale
│   ├── UserProfileService.swift
│   ├── ImageManager.swift        # Gestion des images
│   └── ReceiptValidationService.swift
├── Extensions/                   # Extensions Swift
│   ├── Color+WheelTrack.swift
│   ├── View+Placeholder.swift
│   └── View+Shadows.swift
└── CustomUI/                     # Composants UI personnalisés
    ├── AnimatedButton.swift
    └── ButtonStyles.swift
```

---

## 📱 Structure Android/Kotlin équivalente

### Architecture recommandée : MVVM + Clean Architecture

```
app/
├── src/
│   ├── main/
│   │   ├── java/com/wheeltrack/
│   │   │   ├── WheelTrackApplication.kt      # Application class
│   │   │   │
│   │   │   ├── data/                         # Couche données
│   │   │   │   ├── local/                    # Base de données locale
│   │   │   │   │   ├── database/
│   │   │   │   │   │   ├── WheelTrackDatabase.kt
│   │   │   │   │   │   ├── dao/
│   │   │   │   │   │   │   ├── VehicleDao.kt
│   │   │   │   │   │   │   ├── ExpenseDao.kt
│   │   │   │   │   │   │   ├── RentalContractDao.kt
│   │   │   │   │   │   │   ├── GarageDao.kt
│   │   │   │   │   │   │   ├── MaintenanceDao.kt
│   │   │   │   │   │   │   └── UserProfileDao.kt
│   │   │   │   │   │   └── entities/         # Entités Room
│   │   │   │   │   │       ├── VehicleEntity.kt
│   │   │   │   │   │       ├── ExpenseEntity.kt
│   │   │   │   │   │       ├── RentalContractEntity.kt
│   │   │   │   │   │       ├── GarageEntity.kt
│   │   │   │   │   │       ├── MaintenanceEntity.kt
│   │   │   │   │   │       └── UserProfileEntity.kt
│   │   │   │   │   ├── preferences/          # SharedPreferences
│   │   │   │   │   │   └── AppPreferences.kt
│   │   │   │   │   └── files/                # Stockage fichiers
│   │   │   │   │       └── ImageFileManager.kt
│   │   │   │   │
│   │   │   │   ├── remote/                   # API et services cloud
│   │   │   │   │   ├── api/                  # Si vous utilisez une API REST
│   │   │   │   │   │   └── WheelTrackApi.kt
│   │   │   │   │   ├── cloud/                # Firebase/Backend
│   │   │   │   │   │   ├── FirebaseSyncService.kt
│   │   │   │   │   │   └── CloudStorageService.kt
│   │   │   │   │   └── auth/                 # Authentification
│   │   │   │   │       ├── GoogleSignInService.kt
│   │   │   │   │       └── AuthRepository.kt
│   │   │   │   │
│   │   │   │   └── repository/               # Repositories
│   │   │   │       ├── VehicleRepository.kt
│   │   │   │       ├── ExpenseRepository.kt
│   │   │   │       ├── RentalContractRepository.kt
│   │   │   │       ├── GarageRepository.kt
│   │   │   │       ├── MaintenanceRepository.kt
│   │   │   │       └── UserProfileRepository.kt
│   │   │   │
│   │   │   ├── domain/                       # Couche domaine (logique métier)
│   │   │   │   ├── model/                    # Modèles de domaine
│   │   │   │   │   ├── Vehicle.kt
│   │   │   │   │   ├── Expense.kt
│   │   │   │   │   ├── RentalContract.kt
│   │   │   │   │   ├── Garage.kt
│   │   │   │   │   ├── Maintenance.kt
│   │   │   │   │   ├── UserProfile.kt
│   │   │   │   │   ├── ExpenseFilter.kt
│   │   │   │   │   ├── VehicleFilter.kt
│   │   │   │   │   └── TimeRange.kt
│   │   │   │   │
│   │   │   │   ├── usecase/                  # Cas d'utilisation
│   │   │   │   │   ├── vehicle/
│   │   │   │   │   │   ├── AddVehicleUseCase.kt
│   │   │   │   │   │   ├── UpdateVehicleUseCase.kt
│   │   │   │   │   │   └── DeleteVehicleUseCase.kt
│   │   │   │   │   ├── expense/
│   │   │   │   │   │   ├── AddExpenseUseCase.kt
│   │   │   │   │   │   └── FilterExpensesUseCase.kt
│   │   │   │   │   └── rental/
│   │   │   │   │       └── CreateRentalContractUseCase.kt
│   │   │   │   │
│   │   │   │   └── service/                   # Services métier
│   │   │   │       ├── FreemiumService.kt
│   │   │   │       ├── BillingService.kt      # Google Play Billing
│   │   │   │       ├── LocalizationService.kt
│   │   │   │       ├── NotificationService.kt
│   │   │   │       ├── LocationService.kt
│   │   │   │       └── RentalService.kt
│   │   │   │
│   │   │   ├── ui/                            # Couche présentation
│   │   │   │   ├── theme/                     # Material Design 3
│   │   │   │   │   ├── Color.kt
│   │   │   │   │   ├── Typography.kt
│   │   │   │   │   └── Theme.kt
│   │   │   │   │
│   │   │   │   ├── navigation/                # Navigation Compose
│   │   │   │   │   ├── NavGraph.kt
│   │   │   │   │   └── Screen.kt
│   │   │   │   │
│   │   │   │   ├── dashboard/                 # Écran Dashboard
│   │   │   │   │   ├── DashboardScreen.kt
│   │   │   │   │   ├── DashboardViewModel.kt
│   │   │   │   │   └── DashboardUiState.kt
│   │   │   │   │
│   │   │   │   ├── vehicles/                  # Écran Véhicules
│   │   │   │   │   ├── VehiclesScreen.kt
│   │   │   │   │   ├── VehiclesViewModel.kt
│   │   │   │   │   ├── VehiclesUiState.kt
│   │   │   │   │   ├── AddVehicleScreen.kt
│   │   │   │   │   ├── EditVehicleScreen.kt
│   │   │   │   │   └── VehicleDetailScreen.kt
│   │   │   │   │
│   │   │   │   ├── expenses/                  # Écran Dépenses
│   │   │   │   │   ├── ExpensesScreen.kt
│   │   │   │   │   ├── ExpensesViewModel.kt
│   │   │   │   │   ├── ExpensesUiState.kt
│   │   │   │   │   ├── AddExpenseScreen.kt
│   │   │   │   │   └── ExpenseDetailScreen.kt
│   │   │   │   │
│   │   │   │   ├── maintenance/               # Écran Maintenance
│   │   │   │   │   ├── MaintenanceScreen.kt
│   │   │   │   │   ├── MaintenanceViewModel.kt
│   │   │   │   │   └── AddMaintenanceScreen.kt
│   │   │   │   │
│   │   │   │   ├── garages/                   # Écran Garages
│   │   │   │   │   ├── GaragesScreen.kt
│   │   │   │   │   ├── GaragesViewModel.kt
│   │   │   │   │   └── GarageDetailScreen.kt
│   │   │   │   │
│   │   │   │   ├── rentals/                  # Écran Locations
│   │   │   │   │   ├── RentalsScreen.kt
│   │   │   │   │   ├── RentalsViewModel.kt
│   │   │   │   │   ├── AddRentalContractScreen.kt
│   │   │   │   │   └── RentalDetailScreen.kt
│   │   │   │   │
│   │   │   │   ├── profile/                  # Écran Profil
│   │   │   │   │   ├── ProfileScreen.kt
│   │   │   │   │   ├── ProfileViewModel.kt
│   │   │   │   │   └── EditProfileScreen.kt
│   │   │   │   │
│   │   │   │   ├── settings/                 # Écran Réglages
│   │   │   │   │   ├── SettingsScreen.kt
│   │   │   │   │   └── SettingsViewModel.kt
│   │   │   │   │
│   │   │   │   ├── premium/                  # Écran Premium
│   │   │   │   │   ├── PremiumScreen.kt
│   │   │   │   │   ├── PremiumViewModel.kt
│   │   │   │   │   └── PurchaseSuccessScreen.kt
│   │   │   │   │
│   │   │   │   ├── onboarding/                # Onboarding
│   │   │   │   │   └── OnboardingScreen.kt
│   │   │   │   │
│   │   │   │   └── components/               # Composants réutilisables
│   │   │   │       ├── ModernCard.kt
│   │   │   │       ├── FloatingActionButton.kt
│   │   │   │       ├── PremiumBadge.kt
│   │   │   │       ├── PremiumUpgradeDialog.kt
│   │   │   │       ├── RentalStatusBadge.kt
│   │   │   │       ├── SearchBar.kt
│   │   │   │       ├── VehicleImage.kt
│   │   │   │       ├── ExpenseCard.kt
│   │   │   │       ├── VehicleCard.kt
│   │   │   │       └── StatCard.kt
│   │   │   │
│   │   │   └── di/                            # Dependency Injection (Hilt/Koin)
│   │   │       ├── DatabaseModule.kt
│   │   │       ├── RepositoryModule.kt
│   │   │       ├── UseCaseModule.kt
│   │   │       ├── ViewModelModule.kt
│   │   │       └── ServiceModule.kt
│   │   │
│   │   └── res/                               # Ressources Android
│   │       ├── values/
│   │       │   ├── strings.xml                # Chaînes FR
│   │       │   ├── strings-en.xml            # Chaînes EN
│   │       │   ├── colors.xml
│   │       │   └── themes.xml
│   │       ├── drawable/
│   │       └── layout/                        # Si vous utilisez XML (optionnel)
│   │
│   └── test/                                   # Tests unitaires
│       └── java/com/wheeltrack/
│
└── build.gradle.kts                            # Configuration Gradle
```

---

## 📊 Modèles de données

### 1. Vehicle (Véhicule)

**iOS (Swift) :**
```swift
public struct Vehicle: Codable, Identifiable {
    public let id: UUID
    public var brand: String
    public var model: String
    public var year: Int
    public var licensePlate: String
    public var mileage: Double
    public var fuelType: FuelType
    public var transmission: TransmissionType
    public var color: String
    public var purchaseDate: Date
    public var purchasePrice: Double
    public var purchaseMileage: Double
    public var lastMaintenanceDate: Date?
    public var nextMaintenanceDate: Date?
    public var estimatedValue: Double?
    public var resaleDate: Date?
    public var resalePrice: Double?
    public var isAvailableForRent: Bool
    public var rentalPrice: Double?
    public var depositAmount: Double?
    public var minimumRentalDays: Int?
    public var maximumRentalDays: Int?
    public var vehicleDescription: String?
    public var privateNotes: String?
    public var mainImageURL: String?
    public var additionalImagesURLs: [String]
    public var documentsImageURLs: [String]
    public var isActive: Bool
}
```

**Android (Kotlin) :**
```kotlin
// domain/model/Vehicle.kt
data class Vehicle(
    val id: String = UUID.randomUUID().toString(),
    val brand: String,
    val model: String,
    val year: Int,
    val licensePlate: String,
    val mileage: Double,
    val fuelType: FuelType,
    val transmission: TransmissionType,
    val color: String,
    val purchaseDate: Long, // Timestamp
    val purchasePrice: Double,
    val purchaseMileage: Double,
    val lastMaintenanceDate: Long? = null,
    val nextMaintenanceDate: Long? = null,
    val estimatedValue: Double? = null,
    val resaleDate: Long? = null,
    val resalePrice: Double? = null,
    val isAvailableForRent: Boolean = false,
    val rentalPrice: Double? = null,
    val depositAmount: Double? = null,
    val minimumRentalDays: Int? = null,
    val maximumRentalDays: Int? = null,
    val vehicleDescription: String? = null,
    val privateNotes: String? = null,
    val mainImagePath: String? = null,
    val additionalImagesPaths: List<String> = emptyList(),
    val documentsImagesPaths: List<String> = emptyList(),
    val isActive: Boolean = true
)

enum class FuelType {
    GASOLINE, DIESEL, ELECTRIC, HYBRID, LPG
}

enum class TransmissionType {
    MANUAL, AUTOMATIC, SEMI_AUTOMATIC
}
```

### 2. Expense (Dépense)

**Android (Kotlin) :**
```kotlin
data class Expense(
    val id: String = UUID.randomUUID().toString(),
    val vehicleId: String,
    val date: Long, // Timestamp
    val amount: Double,
    val category: ExpenseCategory,
    val description: String,
    val mileage: Double? = null,
    val receiptImagePath: String? = null,
    val notes: String? = null
)

enum class ExpenseCategory {
    FUEL,           // Carburant
    MAINTENANCE,    // Maintenance
    INSURANCE,      // Assurance
    TAX,            // Taxes
    PARKING,        // Stationnement
    CLEANING,       // Nettoyage
    ACCESSORIES,    // Accessoires
    OTHER           // Autre
}
```

### 3. RentalContract (Contrat de location)

**Android (Kotlin) :**
```kotlin
data class RentalContract(
    val id: String = UUID.randomUUID().toString(),
    val vehicleId: String,
    val renterName: String,
    val startDate: Long,
    val endDate: Long,
    val pricePerDay: Double,
    val totalPrice: Double,
    val depositAmount: Double,
    val conditionReport: String
) {
    fun isActive(): Boolean {
        val now = System.currentTimeMillis()
        return now >= startDate && now <= endDate
    }
    
    fun isExpired(): Boolean {
        return System.currentTimeMillis() > endDate
    }
    
    fun getStatus(): String {
        val now = System.currentTimeMillis()
        return when {
            now < startDate -> "À venir"
            now >= startDate && now <= endDate -> "Actif"
            else -> "Expiré"
        }
    }
    
    val numberOfDays: Int
        get() = ((endDate - startDate) / (1000 * 60 * 60 * 24)).toInt()
}
```

### 4. Garage

**Android (Kotlin) :**
```kotlin
data class Garage(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val address: String,
    val city: String,
    val phone: String,
    val services: List<String>,
    val hours: String,
    val latitude: Double,
    val longitude: Double,
    val isFavorite: Boolean = false
)
```

### 5. Maintenance

**Android (Kotlin) :**
```kotlin
data class Maintenance(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val date: Long,
    val cost: Double,
    val mileage: Int,
    val description: String,
    val garage: String,
    val vehicleId: String
)
```

### 6. UserProfile

**Android (Kotlin) :**
```kotlin
data class UserProfile(
    val firstName: String = "",
    val lastName: String = "",
    val email: String = "",
    val phoneNumber: String = "",
    val dateOfBirth: Long? = null,
    val profileImagePath: String? = null,
    val streetAddress: String = "",
    val city: String = "",
    val postalCode: String = "",
    val country: String = "France",
    val drivingLicenseNumber: String = "",
    val licenseObtainedDate: Long? = null,
    val licenseExpirationDate: Long? = null,
    val licenseCategories: List<String> = listOf("B"),
    val insuranceCompany: String = "",
    val insurancePolicyNumber: String = "",
    val insuranceContactPhone: String = "",
    val insuranceExpirationDate: Long? = null,
    val profession: String = "",
    val company: String = "",
    val professionalVehicleUsagePercentage: Double = 0.0,
    val preferredCurrency: String = "EUR",
    val distanceUnit: DistanceUnit = DistanceUnit.KILOMETERS,
    val fuelConsumptionUnit: FuelConsumptionUnit = FuelConsumptionUnit.LITERS_PER_HUNDRED_KM,
    val language: String = "fr",
    val enableNotifications: Boolean = true,
    val enableMaintenanceReminders: Boolean = true,
    val enableInsuranceReminders: Boolean = true,
    val enableLicenseReminders: Boolean = true,
    val defaultVATRate: Double = 20.0,
    val professionalDeductionRate: Double = 0.0,
    val monthlyVehicleBudget: Double = 0.0,
    val createdAt: Long = System.currentTimeMillis(),
    val lastUpdated: Long = System.currentTimeMillis()
) {
    val fullName: String
        get() = "$firstName $lastName".trim()
    
    val isComplete: Boolean
        get() = firstName.isNotEmpty() && lastName.isNotEmpty() && email.isNotEmpty()
}

enum class DistanceUnit {
    KILOMETERS, MILES
}

enum class FuelConsumptionUnit {
    LITERS_PER_HUNDRED_KM, MILES_PER_GALLON, KILOMETERS_PER_LITER
}
```

---

## 🔧 Services et logique métier

### 1. FreemiumService (Gestion Premium)

**Android (Kotlin) :**
```kotlin
class FreemiumService @Inject constructor(
    private val preferences: AppPreferences,
    private val billingService: BillingService
) {
    val isPremium: Flow<Boolean> = flowOf(false) // À implémenter avec StateFlow
    
    val maxVehiclesFree = 2
    val maxRentalsFree = 2
    val maxReminders = 3
    
    fun canAddVehicle(currentCount: Int): Boolean {
        return isPremium.value || currentCount < maxVehiclesFree
    }
    
    fun canAddRental(currentCount: Int): Boolean {
        return isPremium.value || currentCount < maxRentalsFree
    }
    
    fun hasAccess(feature: PremiumFeature): Boolean {
        return isPremium.value
    }
    
    fun requestUpgrade(feature: PremiumFeature) {
        // Afficher dialog d'upgrade
    }
}

enum class PremiumFeature {
    UNLIMITED_VEHICLES,
    ADVANCED_ANALYTICS,
    RENTAL_MODULE,
    PDF_EXPORT,
    GARAGE_MODULE,
    MAINTENANCE_REMINDERS,
    CLOUD_SYNC
}
```

### 2. BillingService (Google Play Billing)

**Android (Kotlin) :**
```kotlin
class BillingService @Inject constructor(
    private val billingClient: BillingClient,
    private val context: Context
) {
    suspend fun loadProducts(): List<Product> {
        // Charger les produits depuis Google Play
    }
    
    suspend fun purchase(product: Product): PurchaseResult {
        // Effectuer l'achat
    }
    
    suspend fun restorePurchases() {
        // Restaurer les achats
    }
    
    fun isPurchased(productId: String): Boolean {
        // Vérifier si le produit est acheté
    }
}

// Product IDs (équivalents iOS)
object ProductIds {
    const val MONTHLY_SUBSCRIPTION = "com.wheeltrack.premium.monthly"
    const val YEARLY_SUBSCRIPTION = "com.wheeltrack.premium.yearly"
    const val LIFETIME_PURCHASE = "com.wheeltrack.premium.lifetime"
}
```

### 3. RentalService (Gestion des contrats)

**Android (Kotlin) :**
```kotlin
class RentalService @Inject constructor(
    private val repository: RentalContractRepository,
    private val notificationService: NotificationService
) {
    suspend fun addRentalContract(contract: RentalContract) {
        repository.insert(contract)
        notificationService.scheduleRentalNotifications(contract)
    }
    
    suspend fun updateRentalContract(contract: RentalContract) {
        repository.update(contract)
        notificationService.cancelRentalNotifications(contract.id)
        notificationService.scheduleRentalNotifications(contract)
    }
    
    suspend fun deleteRentalContract(contract: RentalContract) {
        repository.delete(contract)
        notificationService.cancelRentalNotifications(contract.id)
    }
    
    fun getRentalContracts(vehicleId: String): Flow<List<RentalContract>> {
        return repository.getContractsForVehicle(vehicleId)
    }
    
    fun getActiveContracts(): Flow<List<RentalContract>> {
        return repository.getAllContracts().map { contracts ->
            contracts.filter { it.isActive() }
        }
    }
    
    fun createPrefilledContract(vehicle: Vehicle): RentalContract? {
        if (!vehicle.isAvailableForRent || vehicle.rentalPrice == null) {
            return null
        }
        
        val startDate = System.currentTimeMillis()
        val endDate = startDate + (vehicle.minimumRentalDays ?: 7) * 24 * 60 * 60 * 1000L
        
        return RentalContract(
            vehicleId = vehicle.id,
            renterName = "",
            startDate = startDate,
            endDate = endDate,
            pricePerDay = vehicle.rentalPrice,
            totalPrice = calculateTotalPrice(startDate, endDate, vehicle.rentalPrice),
            depositAmount = vehicle.depositAmount ?: 0.0,
            conditionReport = "Véhicule en bon état général..."
        )
    }
}
```

### 4. LocalizationService

**Android (Kotlin) :**
```kotlin
class LocalizationService @Inject constructor(
    private val context: Context,
    private val preferences: AppPreferences
) {
    val currentLanguage: Flow<String> = preferences.language
    
    fun getString(key: String): String {
        val language = preferences.getLanguage()
        val resources = getLocalizedResources(language)
        return resources.getString(getStringResourceId(key))
    }
    
    fun getString(key: String, vararg args: Any): String {
        val language = preferences.getLanguage()
        val resources = getLocalizedResources(language)
        return resources.getString(getStringResourceId(key), *args)
    }
    
    private fun getLocalizedResources(language: String): Resources {
        val config = Configuration(context.resources.configuration)
        config.setLocale(Locale(language))
        return context.createConfigurationContext(config).resources
    }
}
```

### 5. NotificationService

**Android (Kotlin) :**
```kotlin
class NotificationService @Inject constructor(
    private val context: Context
) {
    private val notificationManager = 
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    
    fun scheduleRentalNotifications(contract: RentalContract) {
        // Notification 1 : Début demain
        scheduleNotification(
            id = "rental_start_tomorrow_${contract.id}",
            title = "Location démarre demain",
            message = "${contract.renterName} récupère le véhicule demain",
            triggerTime = contract.startDate - 24 * 60 * 60 * 1000 // 1 jour avant
        )
        
        // Notification 2 : Début dans 2h
        scheduleNotification(
            id = "rental_start_soon_${contract.id}",
            title = "Location dans 2h",
            message = "${contract.renterName} arrive bientôt",
            triggerTime = contract.startDate - 2 * 60 * 60 * 1000 // 2h avant
        )
        
        // Notification 3 : Fin aujourd'hui
        scheduleNotification(
            id = "rental_end_today_${contract.id}",
            title = "🚨 Fin de location AUJOURD'HUI",
            message = "${contract.renterName} doit rendre le véhicule aujourd'hui",
            triggerTime = getStartOfDay(contract.endDate)
        )
    }
    
    private fun scheduleNotification(
        id: String,
        title: String,
        message: String,
        triggerTime: Long
    ) {
        // Utiliser WorkManager ou AlarmManager
    }
}
```

---

## 🎨 Vues et interfaces (Jetpack Compose)

### 1. Navigation principale

**Android (Kotlin) :**
```kotlin
@Composable
fun WheelTrackApp() {
    val navController = rememberNavController()
    
    Scaffold(
        bottomBar = {
            BottomNavigationBar(navController = navController)
        }
    ) { padding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Dashboard.route,
            modifier = Modifier.padding(padding)
        ) {
            composable(Screen.Dashboard.route) {
                DashboardScreen()
            }
            composable(Screen.Vehicles.route) {
                VehiclesScreen()
            }
            composable(Screen.Expenses.route) {
                ExpensesScreen()
            }
            composable(Screen.Services.route) {
                ServicesScreen()
            }
            composable(Screen.Profile.route) {
                ProfileScreen()
            }
        }
    }
}

sealed class Screen(val route: String) {
    object Dashboard : Screen("dashboard")
    object Vehicles : Screen("vehicles")
    object Expenses : Screen("expenses")
    object Services : Screen("services")
    object Profile : Screen("profile")
}
```

### 2. DashboardScreen

**Android (Kotlin) :**
```kotlin
@Composable
fun DashboardScreen(
    viewModel: DashboardViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            DashboardHeader(
                userName = uiState.userName,
                isPremium = uiState.isPremium
            )
        }
        
        item {
            ExpenseSummaryCard(
                total = uiState.totalExpenses,
                timeRange = uiState.selectedTimeRange
            )
        }
        
        item {
            RentalSummaryCard(
                activeRentals = uiState.activeRentals,
                revenue = uiState.currentPeriodRevenue
            )
        }
        
        item {
            TimeRangePicker(
                selectedRange = uiState.selectedTimeRange,
                onRangeSelected = { viewModel.selectTimeRange(it) }
            )
        }
        
        if (uiState.isPremium) {
            item {
                ExpensesChart(expenses = uiState.expenses)
            }
        }
        
        item {
            RecentExpensesSection(expenses = uiState.recentExpenses)
        }
    }
}
```

### 3. VehiclesScreen

**Android (Kotlin) :**
```kotlin
@Composable
fun VehiclesScreen(
    viewModel: VehiclesViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    
    Scaffold(
        floatingActionButton = {
            FloatingActionButton(
                onClick = { /* Navigate to AddVehicle */ }
            ) {
                Icon(Icons.Default.Add, contentDescription = "Ajouter")
            }
        }
    ) { padding ->
        if (uiState.vehicles.isEmpty()) {
            EmptyVehiclesView(
                onAddVehicle = { /* Navigate */ },
                modifier = Modifier.padding(padding)
            )
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                item {
                    VehiclesHeader(
                        count = uiState.vehicles.size,
                        inRental = uiState.vehiclesWithRentals
                    )
                }
                
                item {
                    SearchBar(
                        query = uiState.searchText,
                        onQueryChange = { viewModel.updateSearchText(it) }
                    )
                }
                
                item {
                    FilterChips(
                        filters = VehicleFilter.values(),
                        selected = uiState.selectedFilter,
                        onFilterSelected = { viewModel.selectFilter(it) }
                    )
                }
                
                items(uiState.filteredVehicles) { vehicle ->
                    VehicleCard(
                        vehicle = vehicle,
                        onEdit = { /* Navigate */ },
                        onDelete = { viewModel.deleteVehicle(it) }
                    )
                }
            }
        }
    }
}
```

---

## 🚀 Fonctionnalités principales

### 1. Gestion des véhicules
- ✅ Ajouter/Modifier/Supprimer des véhicules
- ✅ Photos principales et supplémentaires
- ✅ Documents (carte grise, assurance)
- ✅ Suivi du kilométrage
- ✅ Historique d'achat/revente
- ✅ Statuts (actif, en maintenance, en location, vendu)

### 2. Suivi des dépenses
- ✅ Catégorisation automatique
- ✅ Filtrage par période (jour, semaine, mois, année)
- ✅ Filtrage par véhicule, catégorie, montant
- ✅ Graphiques (Premium)
- ✅ Export PDF (Premium)
- ✅ Reçus avec photos

### 3. Maintenance
- ✅ Planification des maintenances
- ✅ Rappels automatiques
- ✅ Historique complet
- ✅ Association avec garages

### 4. Garages
- ✅ Répertoire de garages
- ✅ Géolocalisation
- ✅ Favoris
- ✅ Navigation vers le garage
- ✅ Historique des services

### 5. Contrats de location
- ✅ Création de contrats
- ✅ Contrats pré-remplis
- ✅ Calcul automatique des prix
- ✅ Notifications (début/fin)
- ✅ Rapports d'état
- ✅ Suivi des revenus

### 6. Système Premium
- ✅ Abonnement mensuel
- ✅ Abonnement annuel
- ✅ Achat à vie
- ✅ Restauration des achats
- ✅ Limites version gratuite

### 7. Synchronisation cloud
- ✅ Firebase (Android) / CloudKit (iOS)
- ✅ Synchronisation automatique
- ✅ Mode hors ligne
- ✅ Résolution de conflits

---

## 🔄 Mapping iOS → Android

| iOS (Swift) | Android (Kotlin) |
|------------|------------------|
| SwiftUI | Jetpack Compose |
| @State, @Published | StateFlow, LiveData |
| ObservableObject | ViewModel |
| CloudKit | Firebase Firestore |
| StoreKit 2 | Google Play Billing |
| Apple Sign In | Google Sign In |
| UserDefaults | SharedPreferences |
| FileManager | Context.getFilesDir() |
| Combine | Kotlin Flow, Coroutines |
| NavigationStack | Navigation Compose |
| @EnvironmentObject | Hilt/Dependency Injection |
| Codable | Gson/Moshi |
| UUID | UUID.randomUUID() |
| Date | Long (timestamp) / Instant |
| NotificationCenter | EventBus / SharedFlow |

---

## 📦 Dépendances Android recommandées

```kotlin
// build.gradle.kts (app level)

dependencies {
    // Compose
    implementation("androidx.compose.ui:ui:$compose_version")
    implementation("androidx.compose.material3:material3:$material3_version")
    implementation("androidx.compose.ui:ui-tooling-preview:$compose_version")
    implementation("androidx.activity:activity-compose:$activity_compose_version")
    
    // Navigation
    implementation("androidx.navigation:navigation-compose:$nav_version")
    
    // ViewModel
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:$lifecycle_version")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:$lifecycle_version")
    
    // Room Database
    implementation("androidx.room:room-runtime:$room_version")
    implementation("androidx.room:room-ktx:$room_version")
    kapt("androidx.room:room-compiler:$room_version")
    
    // Hilt (Dependency Injection)
    implementation("com.google.dagger:hilt-android:$hilt_version")
    kapt("com.google.dagger:hilt-compiler:$hilt_version")
    implementation("androidx.hilt:hilt-navigation-compose:$hilt_navigation_version")
    
    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:$coroutines_version")
    
    // Flow
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:$coroutines_version")
    
    // Google Play Billing
    implementation("com.android.billingclient:billing-ktx:$billing_version")
    
    // Firebase
    implementation(platform("com.google.firebase:firebase-bom:$firebase_bom_version"))
    implementation("com.google.firebase:firebase-firestore-ktx")
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-storage-ktx")
    
    // Google Sign In
    implementation("com.google.android.gms:play-services-auth:$gms_auth_version")
    
    // Location
    implementation("com.google.android.gms:play-services-location:$gms_location_version")
    
    // WorkManager (Notifications)
    implementation("androidx.work:work-runtime-ktx:$work_version")
    
    // Image Loading
    implementation("io.coil-kt:coil-compose:$coil_version")
    
    // JSON
    implementation("com.squareup.moshi:moshi-kotlin:$moshi_version")
    kapt("com.squareup.moshi:moshi-kotlin-codegen:$moshi_version")
    
    // Testing
    testImplementation("junit:junit:$junit_version")
    androidTestImplementation("androidx.test.ext:junit:$androidx_junit_version")
    androidTestImplementation("androidx.compose.ui:ui-test-junit4:$compose_version")
}
```

---

## 🎯 Prochaines étapes pour le développement Android

1. **Configuration du projet**
   - Créer un nouveau projet Android avec Jetpack Compose
   - Configurer Hilt pour l'injection de dépendances
   - Configurer Firebase pour la synchronisation cloud

2. **Base de données**
   - Créer les entités Room
   - Créer les DAOs
   - Créer la base de données

3. **Repositories**
   - Implémenter les repositories pour chaque entité
   - Gérer la synchronisation locale/cloud

4. **ViewModels**
   - Créer les ViewModels pour chaque écran
   - Implémenter la logique de présentation

5. **UI (Compose)**
   - Créer les écrans principaux
   - Créer les composants réutilisables
   - Implémenter la navigation

6. **Services**
   - Implémenter BillingService (Google Play)
   - Implémenter NotificationService
   - Implémenter LocationService
   - Implémenter FreemiumService

7. **Tests**
   - Tests unitaires pour les ViewModels
   - Tests d'intégration pour les repositories
   - Tests UI pour les écrans principaux

---

## 📝 Notes importantes

- **Dates** : Utiliser des timestamps (Long) au lieu de Date pour la compatibilité
- **Images** : Stocker les chemins de fichiers au lieu des URLs
- **UUID** : Utiliser String au lieu de UUID pour la compatibilité JSON
- **Localisation** : Utiliser les ressources Android (strings.xml) au lieu d'un service
- **Navigation** : Navigation Compose au lieu de NavigationStack
- **État** : StateFlow au lieu de @Published
- **Async** : Coroutines/Flow au lieu de Combine

---

**Document créé le :** $(date)
**Version :** 1.0
**Auteur :** Assistant IA

