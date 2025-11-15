# Guide d'Intégration StoreKit - WheelTrack

## 📋 Fichiers Créés

### 1. Configuration.storekit
- **Localisation** : `/WheelTrack/Configuration.storekit`
- **Fonction** : Configuration locale pour les tests StoreKit en développement
- **Contient** : 3 produits configurés (mensuel, annuel, lifetime)

### 2. ReceiptValidationService.swift  
- **Localisation** : `/WheelTrack/Services/ReceiptValidationService.swift`
- **Fonction** : Validation des reçus côté serveur avec les serveurs Apple
- **Contient** : Logique de validation, parsing des reçus, gestion des erreurs

### 3. AppStoreConfigService.swift
- **Localisation** : `/WheelTrack/Services/AppStoreConfigService.swift`  
- **Fonction** : Gestion de la configuration App Store Connect
- **Contient** : Bundle IDs, validation de configuration, URLs utiles

### 4. StoreKitTestView.swift
- **Localisation** : `/WheelTrack/Views/StoreKitTestView.swift`
- **Fonction** : Interface de test pour StoreKit
- **Contient** : Tests d'achat, validation, debug

## 🚀 Comment Utiliser

### Étape 1: Tests en Développement
```swift
// Pour accéder à la vue de test, ajoutez temporairement dans votre navigation :
NavigationLink("Test StoreKit", destination: StoreKitTestView())
```

### Étape 2: Configuration Locale
1. Le fichier `Configuration.storekit` permet de tester sans App Store Connect
2. Xcode utilisera automatiquement ce fichier en développement
3. Les prix et produits sont simulés localement (4,99€ mensuel, 49,99€ annuel, 79,99€ lifetime)

### Étape 3: Validation de Configuration
```swift
// Vérifier que tout est correctement configuré
let errors = AppStoreConfigService.shared.validateConfiguration()
if errors.isEmpty {
    print("✅ Configuration OK")
} else {
    print("❌ Erreurs: \(errors)")
}
```

### Étape 4: Test des Achats
```swift
// Via le StoreKitService existant
let success = await StoreKitService.shared.purchase(product)
```

### Étape 5: Validation des Reçus (Production)
```swift
// Valider un reçu côté serveur
do {
    let result = try await ReceiptValidationService.shared.validateReceipt()
    print("Premium: \(result.isPremium)")
} catch {
    print("Erreur validation: \(error)")
}
```

## ⚙️ Configuration Requise pour App Store Connect

### À Modifier Avant Production :

1. **Dans AppStoreConfigService.swift** :
   ```swift
   public let bundleID = "com.votre-bundle-id.wheeltrack" // ← Remplacer
   public let teamID = "VOTRE_TEAM_ID" // ← Remplacer  
   public let appStoreAppID = "VOTRE_APP_ID" // ← Remplacer
   ```

2. **Dans ReceiptValidationService.swift** :
   ```swift
   private let sharedSecret = "VOTRE_SHARED_SECRET" // ← Remplacer
   ```

3. **Dans Configuration.storekit** :
   ```json
   "_developerTeamID" : "VOTRE_TEAM_ID", // ← Remplacer
   "_applicationInternalID" : "VOTRE_APP_ID", // ← Remplacer
   ```

### Étapes App Store Connect :

1. **Créer l'App** :
   - Bundle ID doit correspondre exactement
   - Configurer les métadonnées de base

2. **Créer les Produits IAP** :
   - `com.andygrava.wheeltrack.premium.monthly` (Auto-Renewable)
   - `com.andygrava.wheeltrack.premium.yearly` (Auto-Renewable)  
   - `com.andygrava.wheeltrack.premium.lifetime` (Non-Consumable)

3. **Groupe d'Abonnements** :
   - Créer un groupe pour les abonnements
   - Y ajouter monthly et yearly

4. **Prix et Disponibilité** :
   - Définir les prix pour chaque région
   - Activer dans les territoires souhaités

5. **Informations Juridiques** :
   - URL de confidentialité
   - Termes et conditions d'abonnement

## 🧪 Tests Recommandés

### Tests Locaux (Configuration.storekit) :
- ✅ Chargement des produits
- ✅ Simulation d'achats
- ✅ Gestion des erreurs
- ✅ Restauration d'achats

### Tests Sandbox (App Store Connect) :
- ⏳ Achats réels avec comptes testeurs
- ⏳ Validation des reçus serveur
- ⏳ Renouvellements d'abonnements
- ⏳ Gestion de la famille partagée

### Tests Production :
- ⏳ Validation finale avant release
- ⏳ Monitoring des métriques

## 🛠️ Dépannage

### Problèmes Courants :

1. **Aucun produit chargé** :
   - Vérifier les Product IDs dans Configuration.storekit
   - S'assurer que les produits existent dans App Store Connect
   - Vérifier les logs d'erreur dans la console

2. **Échec de validation de reçu** :
   - Vérifier le shared secret
   - S'assurer d'utiliser le bon environnement (sandbox/production)
   - Vérifier la connectivité réseau

3. **Erreurs de configuration** :
   - Utiliser `AppStoreConfigService.shared.validateConfiguration()`
   - Vérifier les Bundle IDs
   - S'assurer que Configuration.storekit est inclus dans le build

## 📊 Monitoring

### Métriques à Surveiller :
- Taux de conversion des achats
- Échecs de validation de reçus  
- Erreurs de chargement de produits
- Taux de renouvellement des abonnements

### Logs Importants :
```swift
// Dans StoreKitService
print("✅ Produits chargés: \(products.map { $0.id })")
print("❌ Erreur chargement produits: \(error)")
print("📱 Statut premium mis à jour: \(isPremium)")
```

## 🔗 Ressources Utiles

- [Documentation StoreKit 2](https://developer.apple.com/documentation/storekit)
- [App Store Connect Guide](https://developer.apple.com/app-store-connect/)
- [Testing In-App Purchases](https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases)
- [Receipt Validation](https://developer.apple.com/documentation/appstorereceipts)
