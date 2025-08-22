# 🔑 Guide de Configuration des Clés - WheelTrack

## 📋 **Résumé : Que faut-il configurer ?**

Vous devez obtenir **3 éléments** depuis App Store Connect et les mettre dans votre code :

1. **Shared Secret** (Clé secrète partagée) ➜ Mettre dans `ReceiptValidationService.swift`
2. **Team ID** ➜ Mettre dans `Configuration.storekit`
3. **App ID** ➜ Mettre dans `Configuration.storekit`

---

## 🌐 **App Store Connect - Étapes détaillées**

### **Étape 1 : Créer votre App**

1. Aller sur [App Store Connect](https://appstoreconnect.apple.com)
2. Se connecter avec votre Apple ID développeur
3. Cliquer sur **"My Apps"** ➜ **"+"** ➜ **"New App"**
4. Remplir :
   - **Platform** : iOS
   - **Name** : WheelTrack
   - **Primary Language** : French
   - **Bundle ID** : `com.wheeltrack.app` ⚠️ **Important : doit correspondre à Xcode**
   - **SKU** : `wheeltrack-ios-2024`
5. **Noter l'App ID** qui s'affiche (ex: `6502148299`)

### **Étape 2 : Obtenir le Team ID**

1. Dans App Store Connect, cliquer sur votre **nom en haut à droite**
2. **Noter le Team ID** affiché (ex: `ABC123DEF4`)

### **Étape 3 : Créer la Shared Secret**

1. Dans App Store Connect : **"Users and Access"** ➜ **"Keys"** ➜ **"In-App Purchase"**
2. Cliquer sur **"Generate Shared Secret"**
3. **Copier la clé générée** (ex: `abc123def456789...`)

---

## 💻 **Xcode - Mise à jour du code**

### **1. Mettre à jour ReceiptValidationService.swift**

```swift
// Ligne 15 - Remplacer VOTRE_SHARED_SECRET_ICI par votre vraie clé
private let sharedSecret = "abc123def456789..." // ➜ Votre Shared Secret
```

### **2. Mettre à jour Configuration.storekit**

```json
// Ligne 70 - Remplacer VOTRE_TEAM_ID
"_developerTeamID" : "ABC123DEF4", // ➜ Votre Team ID

// Ligne 69 - Remplacer par votre App ID
"_applicationInternalID" : "6502148299", // ➜ Votre App ID
```

---

## 🧪 **Configuration des Produits In-App**

Dans App Store Connect, aller dans votre app ➜ **"Features"** ➜ **"In-App Purchases"** :

### **Produit 1 : Abonnement Mensuel**
- **Product ID** : `wheeltrack_premium_monthly`
- **Type** : Auto-Renewable Subscription
- **Duration** : 1 Month
- **Price** : 4,99 €

### **Produit 2 : Abonnement Annuel**
- **Product ID** : `wheeltrack_premium_yearly`
- **Type** : Auto-Renewable Subscription
- **Duration** : 1 Year
- **Price** : 49,99 €

### **Produit 3 : Achat à Vie**
- **Product ID** : `wheeltrack_premium_lifetime`
- **Type** : Non-Consumable
- **Price** : 19,99 €

---

## ✅ **Checklist de vérification**

- [ ] App créée dans App Store Connect
- [ ] Team ID copié et mis dans `Configuration.storekit`
- [ ] App ID copié et mis dans `Configuration.storekit`
- [ ] Shared Secret créée et mise dans `ReceiptValidationService.swift`
- [ ] 3 produits in-app créés avec les bons Product IDs
- [ ] Test local avec Configuration.storekit

---

## 🎯 **Exemple concret**

Si vos vraies valeurs sont :
- **Team ID** : `9XY8ABCD12`
- **App ID** : `1234567890`
- **Shared Secret** : `sk_live_abc123def456...`

Alors votre code devrait être :

**ReceiptValidationService.swift** :
```swift
private let sharedSecret = "sk_live_abc123def456..."
```

**Configuration.storekit** :
```json
"_developerTeamID" : "9XY8ABCD12",
"_applicationInternalID" : "1234567890",
```

---

## 🚨 **Points d'attention**

- ⚠️ **Ne commitez JAMAIS** la vraie Shared Secret dans Git
- ⚠️ Le Bundle ID dans Xcode doit **exactement correspondre** à celui d'App Store Connect
- ⚠️ Les Product IDs doivent être **exactement identiques** entre le code et App Store Connect
- ✅ Vous pouvez tester localement **avant** d'avoir configuré App Store Connect

---

## 📱 **Test immédiat**

Même sans configuration App Store Connect, vous pouvez tester :

1. Votre `Configuration.storekit` simule les achats localement
2. L'interface d'achat fonctionne parfaitement
3. Les limitations freemium sont actives

**Conclusion** : Votre code est prêt, il ne manque que la configuration App Store Connect !
