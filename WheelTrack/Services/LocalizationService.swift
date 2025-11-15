import Foundation
import SwiftUI

/// Service de localisation pour gérer le bilinguisme FR/EN dans WheelTrack
class LocalizationService: ObservableObject {
    
    static let shared = LocalizationService()
    
    @AppStorage("app_language") var currentLanguage: String = "fr" {
        didSet {
            objectWillChange.send()
        }
    }
    
    private init() {
        // Observer les changements de langue
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageDidChange),
            name: .languageChanged,
            object: nil
        )
    }
    
    @objc private func languageDidChange(_ notification: Notification) {
        if let newLanguage = notification.object as? String {
            currentLanguage = newLanguage
            
            // Note: La synchronisation CloudKit est maintenant gérée par GeneralSettingsView
            // seulement si l'utilisateur a activé l'option iCloud
        }
    }
    
    /// Retourne le texte localisé selon la langue actuelle
    func text(_ french: String, _ english: String) -> String {
        return currentLanguage == "en" ? english : french
    }
    
    /// Méthode de commodité pour les vues SwiftUI
    func localized(_ french: String, _ english: String) -> String {
        return text(french, english)
    }
}

/// Extension View pour faciliter la localisation dans SwiftUI
extension View {
    func localizedText(_ french: String, _ english: String) -> String {
        return LocalizationService.shared.text(french, english)
    }
}

/// Extension View pour utiliser LocalizationService avec @EnvironmentObject
extension View {
    func localizedText(using localizationService: LocalizationService, _ french: String, _ english: String) -> String {
        return localizationService.text(french, english)
    }
}

/// Dictionnaire de traductions communes
struct CommonTranslations {
    
    // Navigation
    static let back = ("Retour", "Back")
    static let cancel = ("Annuler", "Cancel")
    static let save = ("Enregistrer", "Save")
    static let delete = ("Supprimer", "Delete")
    static let edit = ("Modifier", "Edit")
    static let add = ("Ajouter", "Add")
    static let done = ("Terminé", "Done")
    static let ok = ("OK", "OK")
    static let close = ("Fermer", "Close")
    
    // Common UI
    static let loading = ("Chargement...", "Loading...")
    static let error = ("Erreur", "Error")
    static let success = ("Succès", "Success")
    static let warning = ("Attention", "Warning")
    static let info = ("Information", "Info")
    
    // WheelTrack specific
    static let appName = ("WheelTrack", "WheelTrack")
    static let vehicles = ("Véhicules", "Vehicles")
    static let dashboard = ("Tableau de bord", "Dashboard")
    static let expenses = ("Dépenses", "Expenses")
    static let maintenance = ("Maintenance", "Maintenance")
    static let garages = ("Garages", "Garages")
    static let rentals = ("Locations", "Rentals")
    static let settings = ("Réglages", "Settings")
    static let profile = ("Profil", "Profile")
    
    // Vehicle related
    static let make = ("Marque", "Make")
    static let model = ("Modèle", "Model")
    static let year = ("Année", "Year")
    static let mileage = ("Kilométrage", "Mileage")
    static let fuelType = ("Carburant", "Fuel Type")
    static let licensePlate = ("Plaque d'immatriculation", "License Plate")
    static let vin = ("Numéro de châssis", "VIN")
    static let price = ("Prix", "Price")
    static let status = ("Statut", "Status")
    
    // Expenses
    static let amount = ("Montant", "Amount")
    static let date = ("Date", "Date")
    static let category = ("Catégorie", "Category")
    static let description = ("Description", "Description")
    static let receipt = ("Reçu", "Receipt")
    
    // Maintenance
    static let nextMaintenance = ("Prochaine maintenance", "Next Maintenance")
    static let lastMaintenance = ("Dernière maintenance", "Last Maintenance")
    static let type = ("Type", "Type")
    static let garage = ("Garage", "Garage")
    static let notes = ("Notes", "Notes")
    
    // Units
    static let km = ("km", "km")
    static let miles = ("miles", "miles")
    static let liters = ("litres", "liters")
    static let gallons = ("gallons", "gallons")
    static let euro = ("€", "€")
    static let dollar = ("$", "$")
    
    // Time
    static let today = ("Aujourd'hui", "Today")
    static let yesterday = ("Hier", "Yesterday")
    static let thisWeek = ("Cette semaine", "This Week")
    static let thisMonth = ("Ce mois", "This Month")
    static let thisYear = ("Cette année", "This Year")
    
    // Status
    static let active = ("Actif", "Active")
    static let inactive = ("Inactif", "Inactive")
    static let sold = ("Vendu", "Sold")
    static let available = ("Disponible", "Available")
    static let rented = ("Loué", "Rented")
    static let maintenance_status = ("En maintenance", "Under Maintenance")
    
    // MARK: - Nouvelles traductions pour corriger les textes hardcodés
    
    // Location/Géolocalisation
    static let locatingInProgress = ("Localisation en cours...", "Locating...")
    static let locationError = ("Erreur de localisation", "Location Error")
    static let locationDisabled = ("Localisation désactivée", "Location Disabled")
    
    // Garage/Services
    static let carGarage = ("Garage automobile", "Car Garage")
    static let informations = ("Informations", "Information")
    static let phone = ("Téléphone :", "Phone:")
    static let services = ("Services :", "Services:")
    static let hours = ("Horaires :", "Hours:")
    static let call = ("Appeler", "Call")
    static let directions = ("Itinéraire dans Plans", "Directions in Maps")
    static let addToFavorites = ("Ajouter aux favoris", "Add to Favorites")
    static let removeFromFavorites = ("Retirer des favoris", "Remove from Favorites")
    
    // Rental/Location
    static let duration = ("Durée :", "Duration:")
    static let pricePerDay = ("Prix par jour", "Price per day")
    static let totalRental = ("Total de la location", "Total rental")
    static let modifyContract = ("Modifier le contrat", "Modify Contract")
    static let renterInformation = ("Informations du locataire", "Renter Information")
    static let rentalPeriod = ("Période de location", "Rental Period")
    static let pricing = ("Tarification", "Pricing")
    static let startDate = ("Date de début", "Start Date")
    static let endDate = ("Date de fin", "End Date")
    static let renterFullName = ("Nom complet du locataire", "Renter Full Name")
    static let days = ("jour", "day")
    static let daysPlural = ("jours", "days")
    
    // Apple Sign In
    static let connectedWithApple = ("Connecté avec Apple !", "Connected with Apple!")
    static let connectionError = ("Erreur de connexion", "Connection Error")
    static let signOut = ("Se déconnecter", "Sign Out")
    static let connectionSuccessful = ("Connexion réussie !", "Connection Successful!")
    
    // Profile/User
    static let profilePhoto = ("Photo de profil", "Profile Photo")
    static let personalInformation = ("Informations personnelles", "Personal Information")
    static let userProfile = ("Profil utilisateur", "User Profile")
    static let editProfile = ("Modifier le profil", "Edit Profile")
    
    // Form elements
    static let validation = ("Validation", "Validation")
    static let saveChanges = ("Sauvegarder", "Save")
    static let formError = ("Erreur de formulaire", "Form Error")
    static let requiredField = ("Champ obligatoire", "Required Field")
    
    // Navigation tabs
    static let finances = ("Finances", "Finances")
    static let vehicleManagement = ("Gestion des véhicules", "Vehicle Management")
    static let mainDashboard = ("Tableau de bord principal", "Main Dashboard")
    static let financialTracking = ("Suivi financier", "Financial Tracking")
    static let automotiveServices = ("Services automobiles", "Automotive Services")
    
    // Accessibility
    static let dashboardTab = ("Affiche un aperçu de vos véhicules et dépenses", "Shows an overview of your vehicles and expenses")
    static let vehiclesTab = ("Gérez vos véhicules et leur maintenance", "Manage your vehicles and their maintenance")
    static let financesTab = ("Consultez et gérez vos dépenses automobiles", "View and manage your automotive expenses")
    static let servicesTab = ("Accédez aux garages et à la location de véhicules", "Access garages and vehicle rental")
    
    // Dashboard specific
    static let hello = ("Bonjour ! 👋", "Hello! 👋")
    static let overview = ("Voici un aperçu de vos dépenses et locations", "Here's an overview of your expenses and rentals")
    static let period = ("Période", "Period")
    static let totalExpenses = ("Total des dépenses", "Total expenses")
    static let viewAllExpenses = ("Voir toutes les dépenses", "View all expenses")
    static let noActiveRental = ("Aucune location active", "No active rental")
    static let actives = ("actives", "active")
    static let recentExpenses = ("Dernières dépenses", "Recent expenses")
    static let noExpenses = ("Aucune dépense", "No expenses")
    static let addFirstExpense = ("Commencez par ajouter votre première dépense pour suivre vos finances", "Start by adding your first expense to track your finances")
    static let addExpense = ("Ajouter une dépense", "Add expense")
    static let expensesEvolution = ("Évolution des dépenses", "Expenses evolution")
    static let noDataToDisplay = ("Aucune donnée à afficher", "No data to display")
    static let revenue = ("revenus", "revenue")
    static let language = ("fr", "en")
    
    // ExpensesView specific
    static let myExpenses = ("Mes Dépenses", "My Expenses")
    static let manageVehicleCosts = ("Gérez tous vos frais de véhicules", "Manage all your vehicle costs")
    static let categoryDistribution = ("Répartition par catégorie", "Distribution by category")
    static let allExpenses = ("Toutes les dépenses", "All Expenses")
    static let noExpensesFound = ("Aucune dépense trouvée", "No expenses found")
    static let expensesWillAppearHere = ("Vos dépenses apparaîtront ici.\nAjoutez votre première dépense pour commencer.", "Your expenses will appear here.\nAdd your first expense to get started.")
    static let deleteExpenseTitle = ("Supprimer la dépense ?", "Delete expense?")
    static let deleteExpenseAlertMessage = ("Cette action est irréversible.", "This action is irreversible.")
    static let unknownVehicle = ("Véhicule inconnu", "Unknown vehicle")
    static let expense = ("dépense", "expense")
    static let categories = ("Catégories", "Categories")
    
    // VehiclesView specific
    static let manageFleet = ("Gérez votre flotte automobile", "Manage your vehicle fleet")
    static let totalVehicles = ("Total véhicules", "Total vehicles")
    static let inRental = ("en location", "in rental")
    static let brandDistribution = ("Répartition par marque", "Distribution by brand")
    static let searchVehicles = ("Rechercher des véhicules", "Search vehicles")
    static let noVehicles = ("Aucun véhicule", "No vehicles")
    static let addFirstVehicle = ("Commencez par ajouter votre premier véhicule pour suivre votre flotte", "Start by adding your first vehicle to track your fleet")
    static let addVehicle = ("Ajouter un véhicule", "Add vehicle")
    static let noFilterMatch = ("Aucun véhicule ne correspond à ce filtre", "No vehicles match this filter")
    static let filters = ("Filtres", "Filters")
    static let all = ("Tous", "All")
    
    // GaragesView specific
    static let myFavorites = ("Mes Favoris", "My Favorites")
    static let myGarages = ("Mes Garages", "My Garages")
    static let locationRequired = ("Géolocalisation requise", "Location Required")
    static let locationRequiredMessage = ("Pour trouver des garages près de vous, autorisez l'accès à votre localisation dans les réglages.", "To find garages near you, allow location access in settings.")
    static let later = ("Plus tard", "Later")
    static let nearbyGarages = ("Garages proches", "Nearby Garages")
    static let searchingNearby = ("Recherche de garages proches...", "Searching for nearby garages...")
    static let noGarages = ("Aucun garage", "No garages")
    static let noFavoriteGarages = ("Aucun garage favori", "No favorite garages")
    static let enableLocationMessage = ("Activez la géolocalisation pour trouver des garages près de vous", "Enable location to find garages near you")
    static let enableLocation = ("Activer la géolocalisation", "Enable Location")
    static let refresh = ("Rafraîchir", "Refresh")
    static let authorize = ("Autoriser", "Allow")
    static let garageFound = ("garage trouvé", "garage found")
    static let garagesFound = ("garages trouvés", "garages found")
    static let profileTab = ("Gérez vos paramètres et informations personnelles", "Manage your settings and personal information")
    static let mainNavigation = ("Navigation principale", "Main Navigation")
    static let useTabsToNavigate = ("Utilisez les onglets pour naviguer entre les différentes sections de l'application", "Use tabs to navigate between different sections of the app")
    static let loadingApplication = ("Chargement de l'application", "Loading application")
    static let pleaseWaitLoading = ("Veuillez patienter pendant le chargement", "Please wait while loading")
    static let loadingScreen = ("Écran de chargement WheelTrack", "WheelTrack Loading Screen")
    
    // Tabs
    static let vehiclesTabLabel = ("Onglet véhicules", "Vehicles tab")
    static let maintenanceTabLabel = ("Onglet maintenance", "Maintenance tab")
    static let showsVehicleList = ("Affiche la liste de vos véhicules", "Shows your vehicle list")
    static let manageVehicleMaintenance = ("Gérez l'entretien de vos véhicules", "Manage your vehicle maintenance")
    
    // Additional GaragesView translations
    static let notAvailable = ("Non disponible", "Not available")
    static let favorites = ("Favoris", "Favorites")
    static let otherServices = ("%d autres services", "%d other services")
    static let favoriteGarages = ("garages favoris", "favorite garages")
    static let favoriteGarage = ("garage favori", "favorite garage")
    static let garagesLoadedLocation = ("garages chargés depuis votre position", "garages loaded from your location")
    static let inFavorites = ("dans les favoris", "in favorites")
    static let openAppleMaps = ("Ouvrir dans Plans", "Open in Maps")
    static let deleteAllFavorites = ("Supprimer tous les favoris", "Delete all favorites")
    static let showAllGarages = ("Voir tous les garages", "Show all garages")
    static let showOnlyFavorites = ("Afficher seulement les favoris", "Show only favorites")
    static let toggleGaragesFavorites = ("Basculer entre tous les garages et les favoris", "Toggle between all garages and favorites")
    static let noFavoriteGarage = ("Aucun garage favori", "No favorite garage")
    static let addFavoritesMessage = ("Ajoutez vos garages préférés pour un accès rapide", "Add your favorite garages for quick access")
    static let viewAllGarages = ("Voir tous les garages", "View all garages")
    static let noGarageFound = ("Aucun garage trouvé", "No garage found")
    static let locationRequiredEmpty = ("Géolocalisation requise pour afficher les garages à proximité", "Location required to show nearby garages")
    static let tryRefresh = ("Essayez de rafraîchir ou", "Try refreshing or")
    static let authorizeLocation = ("autorisez la géolocalisation", "authorize location")
    static let authorizeGeolocation = ("Autoriser la géolocalisation", "Authorize geolocation")
    static let authorizeAccess = ("Autorisez l'accès à votre position pour voir les garages à proximité.", "Authorize access to your location to see nearby garages.")
    static let nearbyGaragesLoaded = ("Garages à proximité chargés", "Nearby garages loaded")
    static let basedCurrentLocation = ("Basé sur votre position actuelle", "Based on your current location")
    static let address = ("Adresse", "Address")
    
    // UserProfile specific translations
    static let myProfile = ("Mon Profil", "My Profile")
    static let nameNotProvided = ("Nom non renseigné", "Name not provided")
    static let drivingLicense = ("Permis de conduire", "Driving License")
    static let mainInsurance = ("Assurance principale", "Main Insurance")
    static let professionalInformation = ("Informations professionnelles", "Professional Information")
    static let financialSettings = ("Paramètres financiers", "Financial Settings")
    static let preferences = ("Préférences", "Preferences")
    
    // MARK: - Profile form fields
    
    // Personal Information
    static let firstName = ("Prénom", "First Name")
    static let lastName = ("Nom", "Last Name")
    static let email = ("Email", "Email")
    static let phoneNumber = ("Téléphone", "Phone Number")
    static let dateOfBirth = ("Date de naissance", "Date of Birth")
    static let personalInfoFooter = ("Ces informations sont utilisées pour vos documents officiels et vos assurances. L'email sert pour les notifications importantes.", "This information is used for your official documents and insurance. Email is used for important notifications.")
    
    // Address
    static let streetAndNumber = ("Numéro et rue", "Street and Number")
    static let city = ("Ville", "City")
    static let postalCode = ("Code postal", "Postal Code")
    static let country = ("Pays", "Country")
    static let addressFooter = ("Votre adresse est utilisée pour localiser les garages les plus proches et pour vos documents officiels.", "Your address is used to locate the nearest garages and for your official documents.")
    
    // Driving License
    static let drivingLicenseNumber = ("Numéro de permis", "License Number")
    static let licenseObtainedDate = ("Date d'obtention", "Obtained Date")
    static let licenseExpirationDate = ("Date d'expiration", "Expiration Date")
    static let licenseInformation = ("Informations du permis", "License Information")
    static let licenseInfoFooter = ("Ces informations sont essentielles pour la location de véhicules et les contrôles routiers.", "This information is essential for vehicle rental and road checks.")
    static let authorizedCategories = ("Catégories autorisées", "Authorized Categories")
    static let licenseCategoriesFooter = ("Sélectionnez les catégories de véhicules que vous êtes autorisé(e) à conduire.", "Select the vehicle categories you are authorized to drive.")
    
    // Insurance
    static let insuranceCompany = ("Compagnie d'assurance", "Insurance Company")
    static let policyNumber = ("Numéro de police", "Policy Number")
    static let insuranceContactPhone = ("Téléphone assurance", "Insurance Contact Phone")
    static let insuranceExpirationDate = ("Date d'expiration", "Expiration Date")
    static let insuranceFooter = ("Ces informations sont cruciales en cas d'accident ou de sinistre. Vous recevrez des rappels avant l'expiration.", "This information is crucial in case of accident or claim. You will receive reminders before expiration.")
    
    // Professional
    static let profession = ("Profession", "Profession")
    static let company = ("Entreprise", "Company")
    static let professionalUse = ("Usage professionnel", "Professional Use")
    static let professionalUseFooter = ("Le pourcentage d'usage professionnel est utilisé pour calculer les déductions fiscales et la répartition des frais.", "The professional use percentage is used to calculate tax deductions and cost allocation.")
    
    // Preferences
    static let currency = ("Devise", "Currency")
    static let distanceUnit = ("Unité de distance", "Distance Unit")
    static let fuelConsumption = ("Consommation carburant", "Fuel Consumption")
    static let languageSetting = ("Langue", "Language")
    static let unitsAndLanguage = ("Unités et langue", "Units and Language")
    static let notifications = ("Notifications", "Notifications")
    static let maintenanceReminders = ("Rappels maintenance", "Maintenance Reminders")
    static let insuranceReminders = ("Rappels assurance", "Insurance Reminders")
    static let licenseReminders = ("Rappels permis", "License Reminders")
    static let notificationsFooter = ("Activez les notifications pour ne manquer aucune échéance importante.", "Enable notifications to not miss any important deadline.")
    
    // Financial Settings
    static let vatRate = ("Taux de TVA", "VAT Rate")
    static let professionalDeduction = ("Déduction professionnelle", "Professional Deduction")
    static let monthlyVehicleBudget = ("Budget mensuel véhicule", "Monthly Vehicle Budget")
    static let financialFooter = ("Ces paramètres sont utilisés pour les calculs automatiques de coûts et les rapports financiers.", "These settings are used for automatic cost calculations and financial reports.")
    static let vat = ("TVA", "VAT")
    static let deduction = ("Déduction", "Deduction")
    static let budget = ("Budget", "Budget")
    
    // Currency names
    static let euroCurrency = ("Euro (€)", "Euro (€)")
    static let dollarCurrency = ("Dollar ($)", "Dollar ($)")
    static let poundCurrency = ("Livre (£)", "Pound (£)")
    static let swissFrancCurrency = ("Franc suisse (CHF)", "Swiss Franc (CHF)")
    
    // Languages
    static let french = ("Français", "French")
    static let english = ("English", "English")
    static let spanish = ("Español", "Spanish")
    static let german = ("Deutsch", "German")
    
    // License Categories
    static let licenseCategoryA = ("Motos", "Motorcycles")
    static let licenseCategoryB = ("Voitures particulières", "Passenger Cars")
    static let licenseCategoryC = ("Poids lourds", "Heavy Vehicles")
    static let licenseCategoryD = ("Transport en commun", "Public Transport")
    static let licenseCategoryBE = ("Voiture avec remorque", "Car with Trailer")
    static let licenseCategoryCE = ("Poids lourd avec remorque", "Heavy Vehicle with Trailer")
    
    // MARK: - Tutorial translations
    
    // Tutorial - Page titles
    static let tutorialWelcomeTitle = ("Bienvenue dans WheelTrack", "Welcome to WheelTrack")
    static let tutorialVehiclesTitle = ("Gérez vos véhicules", "Manage your vehicles")
    static let tutorialFinancesTitle = ("Suivez vos finances", "Track your finances")
    static let tutorialCloudTitle = ("Synchronisation CloudKit", "CloudKit Sync")
    
    // Tutorial - Page subtitles
    static let tutorialWelcomeSubtitle = ("Votre assistant personnel pour gérer vos véhicules et leurs coûts", "Your personal assistant for managing your vehicles and their costs")
    static let tutorialVehiclesSubtitle = ("Ajoutez vos véhicules, programmez leurs maintenances et suivez leur historique", "Add your vehicles, schedule their maintenance and track their history")
    static let tutorialFinancesSubtitle = ("Analysez vos dépenses avec des graphiques détaillés et des statistiques avancées", "Analyze your expenses with detailed charts and advanced statistics")
    static let tutorialCloudSubtitle = ("Vos données sont automatiquement synchronisées sur tous vos appareils Apple", "Your data is automatically synced across all your Apple devices")
    
    // Tutorial - Descriptions
    static let tutorialWelcomeDescription = ("Découvrez toutes les fonctionnalités qui vous permettront de maîtriser vos coûts automobiles", "Discover all the features that will help you master your automotive costs")
    static let tutorialVehiclesDescription = ("• Garage virtuel avec photos\n• Alertes de maintenance\n• Historique complet\n• Gestion des contrats", "• Virtual garage with photos\n• Maintenance alerts\n• Complete history\n• Contract management")
    static let tutorialFinancesDescription = ("• Catégorisation automatique\n• Graphiques interactifs\n• Analyses de tendances\n• Rapports détaillés", "• Automatic categorization\n• Interactive charts\n• Trend analysis\n• Detailed reports")
    static let tutorialCloudDescription = ("• Sauvegarde automatique\n• Synchronisation temps réel\n• Sécurité Apple\n• Accès multi-appareils", "• Automatic backup\n• Real-time sync\n• Apple security\n• Multi-device access")
    
    // Tutorial - Actions
    static let tutorialNext = ("Suivant", "Next")
    static let tutorialSkip = ("Passer", "Skip")
    static let tutorialStart = ("Commencer", "Get Started")
    static let tutorialPrevious = ("Précédent", "Previous")
    
    // Nouveau système de tutoriel simplifié (3 slides)
    static let tutorialPage1Title = ("Gestion de véhicules", "Vehicle Management")
    static let tutorialPage1Description = ("Ajoutez vos véhicules, suivez leur kilométrage et organisez votre garage personnel.", "Add your vehicles, track mileage and organize your personal garage.")
    
    static let tutorialPage2Title = ("Suivi financier", "Financial Tracking")
    static let tutorialPage2Description = ("Enregistrez vos dépenses automobile et visualisez vos données avec des graphiques détaillés.", "Record your automotive expenses and visualize your data with detailed charts.")
    
    static let tutorialPage3Title = ("Synchronisation iCloud", "iCloud Sync")
    static let tutorialPage3Description = ("Vos données sont automatiquement sauvegardées et synchronisées sur tous vos appareils Apple.", "Your data is automatically backed up and synced across all your Apple devices.")
    
    // MARK: - Notifications de location
    static let rentalStartsTomorrow = ("Location démarre demain", "Rental starts tomorrow")
    static let rentalStartsTomorrowBody = ("récupère le véhicule demain. Pensez à le préparer !", "picks up the vehicle tomorrow. Remember to prepare it!")
    static let rentalStartsIn2Hours = ("Location dans 2h", "Rental in 2 hours")
    static let rentalStartsIn2HoursBody = ("arrive bientôt pour récupérer le véhicule", "arrives soon to pick up the vehicle")
    static let rentalEndsTodayTitle = ("🚨 Fin de location AUJOURD'HUI", "🚨 Rental ends TODAY")
    static let rentalEndsTodayBody = ("doit rendre le véhicule aujourd'hui", "must return the vehicle today")
    static let rentalEndsTomorrowTitle = ("Fin de location demain", "Rental ends tomorrow")
    static let rentalEndsTomorrowBody = ("doit rendre le véhicule demain", "must return the vehicle tomorrow")
    
    // MARK: - Messages d'erreur et validation
    static let syncError = ("Erreur de synchronisation", "Sync Error")
    static let syncErrorMessage = ("Une erreur est survenue lors de la synchronisation des données.", "An error occurred while syncing data.")
    static let retry = ("Réessayer", "Retry")
    static let validationError = ("Erreur de validation", "Validation Error")
    static let requiredFields = ("Veuillez remplir tous les champs obligatoires", "Please fill in all required fields")
    static let invalidAmount = ("Le montant doit être supérieur à 0", "Amount must be greater than 0")
    static let invalidPrice = ("Le prix doit être supérieur à 0", "Price must be greater than 0")
    static let invalidYear = ("L'année doit être entre 1900 et 2030", "Year must be between 1900 and 2030")
    static let invalidMileage = ("Le kilométrage doit être positif", "Mileage must be positive")
    static let networkError = ("Erreur réseau", "Network Error")
    static let dataError = ("Erreur de données", "Data Error")
    static let loadingData = ("Chargement des données...", "Loading data...")
    static let syncingData = ("Synchronisation en cours...", "Syncing data...")
    
    // MARK: - Premium Features Translations
    static let premiumRequired = ("💎 Premium Requis", "💎 Premium Required")
    static let wheeltrackPremium = ("💎 WHEELTRACK PREMIUM", "💎 WHEELTRACK PREMIUM")
    static let unlockFullPotential = ("Débloquez tout le potentiel de WheelTrack", "Unlock the full potential of WheelTrack")
    static let professionalManagement = ("Gestion professionnelle avec analytics avancés", "Professional management with advanced analytics")
    static let unlimitedVehicles = ("Véhicules illimités", "Unlimited Vehicles")
    static let manageFleetText = ("Gérez toute votre flotte", "Manage your entire fleet")
    static let professionalAnalytics = ("Analytics professionnels", "Professional Analytics")
    static let analyticsPro = ("Analytics Pro", "Analytics Pro")
    static let detailedGraphs = ("Graphiques détaillés", "Detailed graphs")
    static let fullRentalModule = ("Module Location complet", "Full Rental Module")
    static let rentalModule = ("Module Location", "Rental Module")
    static let contractsRevenue = ("Contrats & revenus", "Contracts & revenue")
    static let iCloudSync = ("Synchronisation iCloud", "iCloud Sync")
    static let syncIcloud = ("Sync iCloud", "Sync iCloud")
    static let multiDevice = ("Multi-appareils", "Multi-device")
    static let exportPdf = ("Export PDF", "PDF Export")
    static let completeReports = ("Rapports complets", "Complete reports")
    static let garagesPro = ("Garages Pro", "Pro Garages")
    static let unlimitedFavorites = ("Favoris illimités", "Unlimited favorites")
    
    // Pricing Options
    static let monthlyPremium = ("Premium Mensuel", "Monthly Premium")
    static let billedMonthly = ("Facturé mensuellement", "Billed monthly")
    static let yearlyPremium = ("Premium Annuel", "Yearly Premium")
    static let billedYearly = ("Facturé annuellement", "Billed yearly")
    static let lifetimePremium = ("Premium à Vie", "Lifetime Premium")
    static let oneTimePurchase = ("Achat unique", "One-time purchase")
    static let oneTimePurchaseAccess = ("Achat unique - Accès illimité", "One-time purchase - Unlimited access")
    static let save18Percent = ("Économisez 18%", "Save 18%")
    static let save17Percent = ("Économisez 17% - Facturation annuelle", "Save 17% - Yearly billing")
    static let popularBadge = ("⭐ POPULAIRE", "⭐ POPULAR")
    static let premiumBadge = ("Premium", "Premium")
    
    // Actions
    static let seeAllOptions = ("Voir toutes les options", "See all options")
    static let unlock = ("Débloquer", "Unlock")
    static let availableWithPremium = ("Disponible avec Premium", "Available with Premium")
    static let restorePurchases = ("Restaurer les achats", "Restore purchases")
    
    // Footer notes
    static let autoRenewSubscription = ("• Abonnement renouvelé automatiquement", "• Subscription auto-renews")
    static let cancelAnytime = ("• Annulation possible à tout moment", "• Cancel anytime")
    static let freeTrial7Days = ("• Essai gratuit de 7 jours", "• 7-day free trial")
    
    // Loading states
    static let loadingProducts = ("Chargement des produits...", "Loading products...")
    static let noProducts = ("Aucun produit disponible", "No products available")
    
    // MARK: - Rental Contract Activation
    static let futureStartDate = ("Date de début dans le futur", "Future start date")
    static let startNow = ("Commencer maintenant", "Start now")
    static let keepPlannedDate = ("Conserver la date prévue", "Keep planned date")
    
    // MARK: - Premium Feature Titles
    static let featureUnlimitedVehiclesTitle = ("Véhicules illimités", "Unlimited Vehicles")
    static let featureAdvancedAnalyticsTitle = ("Analytics avancés", "Advanced Analytics")
    static let featureRentalModuleTitle = ("Module Location", "Rental Module")
    static let featurePdfExportTitle = ("Export PDF", "PDF Export")
    static let featureGarageModuleTitle = ("Garages favoris", "Favorite Garages")
    static let featureMaintenanceRemindersTitle = ("Rappels maintenance", "Maintenance Reminders")
    static let featureCloudSyncTitle = ("Synchronisation iCloud", "iCloud Sync")
    
    // MARK: - Premium Feature Descriptions
    static let featureUnlimitedVehiclesDesc = ("Ajoutez autant de véhicules que vous voulez", "Add as many vehicles as you want")
    static let featureAdvancedAnalyticsDesc = ("Graphiques détaillés et statistiques complètes", "Detailed charts and complete statistics")
    static let featureRentalModuleDesc = ("Gérez la location de vos véhicules", "Manage your vehicle rentals")
    static let featurePdfExportDesc = ("Exportez vos données en PDF", "Export your data to PDF")
    static let featureGarageModuleDesc = ("Sauvegardez vos garages favoris", "Save your favorite garages")
    static let featureMaintenanceRemindersDesc = ("Rappels illimités pour l'entretien", "Unlimited maintenance reminders")
    static let featureCloudSyncDesc = ("Synchronisez vos données sur tous vos appareils", "Sync your data across all your devices")
}

/// Helper pour accéder facilement aux traductions
func L(_ translation: (String, String)) -> String {
    return LocalizationService.shared.text(translation.0, translation.1)
} 