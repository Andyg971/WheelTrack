import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties
    
    var window: UIWindow?
    
    // MARK: - Application Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupAppearance()
        setupWindow()
        return true
    }
    
    // MARK: - UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    // MARK: - Setup
    
    private func setupAppearance() {
        // Configuration de la barre de navigation
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .systemBackground
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        // Configuration de la barre d'onglets
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .systemBackground
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let tabBarController = UITabBarController()
        
        // Configuration des onglets
        let dashboardVC = UINavigationController(rootViewController: DashboardViewController())
        dashboardVC.tabBarItem = UITabBarItem(
            title: "Tableau de bord",
            image: UIImage(systemName: "house.fill"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        let vehiclesVC = UINavigationController(rootViewController: VehicleListViewController())
        vehiclesVC.tabBarItem = UITabBarItem(
            title: "Véhicules",
            image: UIImage(systemName: "car.fill"),
            selectedImage: UIImage(systemName: "car.fill")
        )
        
        let expensesVC = UINavigationController(rootViewController: ExpensesViewController())
        expensesVC.tabBarItem = UITabBarItem(
            title: "Dépenses",
            image: UIImage(systemName: "dollarsign.circle.fill"),
            selectedImage: UIImage(systemName: "dollarsign.circle.fill")
        )
        
        let resaleVC = UINavigationController(rootViewController: ResaleViewController())
        resaleVC.tabBarItem = UITabBarItem(
            title: "Revente",
            image: UIImage(systemName: "arrow.triangle.2.circlepath"),
            selectedImage: UIImage(systemName: "arrow.triangle.2.circlepath")
        )
        
        let rentalVC = UINavigationController(rootViewController: RentalDashboardViewController())
        rentalVC.tabBarItem = UITabBarItem(
            title: "Location",
            image: UIImage(systemName: "key.fill"),
            selectedImage: UIImage(systemName: "key.fill")
        )
        
        tabBarController.viewControllers = [
            dashboardVC,
            vehiclesVC,
            expensesVC,
            resaleVC,
            rentalVC
        ]
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
} 