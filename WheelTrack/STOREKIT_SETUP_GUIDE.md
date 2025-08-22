# 🚀 Guide de Configuration StoreKit - WheelTrack

## ✅ **Ce qui est déjà configuré**

Votre application a maintenant tous les composants nécessaires pour les paiements :

- ✅ **StoreKitService** - Gestion complète des achats
- ✅ **FreemiumService** - Gestion du statut Premium
- ✅ **PremiumPurchaseView** - Interface d'achat moderne
- ✅ **Configuration.storekit** - Configuration locale pour les tests
- ✅ **Intégration dans SettingsView** - Accès facile aux achats

## 🔧 **Configuration App Store Connect (OBLIGATOIRE)**

### **Étape 1 : Créer votre app dans App Store Connect**

1. Allez sur [App Store Connect](https://appstoreconnect.apple.com)
2. Cliquez sur **"My Apps"** → **"+"** → **"New App"**
3. Remplissez les informations :
   - **Platforms** : iOS
   - **Bundle ID** : `com.wheeltrack.app`
   - **SKU** : `wheeltrack-ios`
   - **User Access** : Full Access

### **Étape 2 : Configurer les produits in-app**

1. Dans votre app, allez dans **"Features"** → **"In-App Purchases"**
2. Cliquez sur **"+"** pour ajouter chaque produit :

#### **Produit 1 : Abonnement Mensuel**
- **Product ID** : `wheeltrack_premium_monthly`
- **Type** : Auto-Renewable Subscription
- **Subscription Group** : Créer un nouveau groupe "Premium"
- **Duration** : 1 Month
- **Price** : 4.99€ (ou votre devise)

#### **Produit 2 : Abonnement Annuel**
- **Product ID** : `wheeltrack_premium_yearly`
- **Type** : Auto-Renewable Subscription
- **Subscription Group** : Même groupe "Premium"
- **Duration** : 1 Year
- **Price** : 49.99€ (ou votre devise)

#### **Produit 3 : Achat à Vie**
- **Product ID** : `wheeltrack_premium_lifetime`
- **Type** : Non-Consumable
- **Price** : 19.99€ (ou votre devise)

### **Étape 3 : Obtenir votre Team ID**

1. Dans App Store Connect, cliquez sur votre nom en haut à droite
2. Notez le **Team ID** (ex: `ABC123DEF4`)

### **Étape 4 : Obtenir votre App ID**

1. Dans votre app, notez l'**App ID** (ex: `6502148299`)

### **Étape 5 : Créer une clé secrète partagée**

1. **Users and Access** → **Keys** → **"+"**
2. **Key Name** : `WheelTrack StoreKit Key`
3. **Access** : Cochez "In-App Purchase" et "App Analytics"
4. **Download** la clé et notez le **Key ID**

## 📱 **Mise à jour du code (OBLIGATOIRE)**

### **1. Mettre à jour AppStoreConfigService.swift**

```swift
// Remplacez ces valeurs par vos vraies données
public let teamID = "VOTRE_VRAI_TEAM_ID" // Ex: "ABC123DEF4"
public let appStoreAppID = "VOTRE_VRAI_APP_ID" // Ex: "6502148299"
```

### **2. Mettre à jour ReceiptValidationService.swift**

```swift
// Remplacez par votre vraie clé secrète
private let sharedSecret = "VOTRE_VRAIE_CLE_SECRETE" // Ex: "abc123def456..."
```

## 🧪 **Test en développement**

### **Avec Configuration.storekit (Recommandé)**
1. Votre app utilise automatiquement le fichier local en développement
2. Les achats sont simulés localement
3. Parfait pour tester l'interface et la logique

### **Avec App Store Connect Sandbox**
1. Créez un compte de test dans **Users and Access** → **Sandbox Testers**
2. Testez avec un vrai appareil ou simulateur
3. Les achats sont réels mais gratuits

## 🚀 **Test en production**

1. **Soumettez votre app** à Apple Review
2. **Approuvez les achats in-app** dans App Store Connect
3. **Testez avec des comptes réels** (attention aux vrais achats !)

## 🔍 **Vérification de la configuration**

Utilisez la vue de test intégrée :

```swift
// Dans votre navigation de développement
NavigationLink("Test StoreKit", destination: StoreKitTestView())
```

Cette vue vous permettra de :
- ✅ Vérifier le chargement des produits
- ✅ Tester les achats
- ✅ Valider la configuration
- ✅ Déboguer les problèmes

## 📋 **Checklist finale**

- [ ] App créée dans App Store Connect
- [ ] 3 produits in-app configurés
- [ ] Team ID noté et mis à jour dans le code
- [ ] App ID noté et mis à jour dans le code
- [ ] Clé secrète créée et mise à jour dans le code
- [ ] Test local avec Configuration.storekit
- [ ] Test sandbox avec App Store Connect
- [ ] App soumise à Apple Review

## 🎯 **Résultat attendu**

Une fois configuré, vos utilisateurs pourront :
- ✅ Voir les produits Premium dans les paramètres
- ✅ Acheter des abonnements mensuels/annuels
- ✅ Acheter l'accès à vie
- ✅ Restaurer leurs achats
- ✅ Bénéficier automatiquement des fonctionnalités Premium

## 🆘 **En cas de problème**

1. **Vérifiez la console Xcode** pour les erreurs StoreKit
2. **Utilisez StoreKitTestView** pour diagnostiquer
3. **Vérifiez App Store Connect** pour la configuration des produits
4. **Testez avec Configuration.storekit** en premier

---

**🎉 Félicitations !** Votre app WheelTrack aura un système de paiement professionnel et fonctionnel !
