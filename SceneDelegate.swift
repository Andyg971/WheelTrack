import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // MARK: - Properties
    
    var window: UIWindow?
    
    // MARK: - UIWindowSceneDelegate
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Création de la fenêtre avec la scène
        window = UIWindow(windowScene: windowScene)
        
        // Configuration de la barre d'onglets
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
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Appelé lorsque la scène est libérée par le système
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Appelé lorsque la scène devient active
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Appelé juste avant que la scène devienne inactive
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Appelé lorsque la scène passe du background au foreground
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Appelé lorsque la scène passe en background
        // Sauvegarde des données si nécessaire
    }
} 