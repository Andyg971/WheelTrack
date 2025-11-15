# Configuration App Store Connect - Produits In-App

## 🚨 Problème identifié
Les produits StoreKit ne se chargent pas car ils ne sont **PAS configurés sur App Store Connect**.

## Erreurs actuelles
- `Produits récupérés depuis StoreKit: 0`
- `Produits manquants: ["com.andygrava.wheeltrack.premium.monthly", "com.andygrava.wheeltrack.premium.yearly", "com.andygrava.wheeltrack.premium.lifetime"]`
- `Error Domain=ASDErrorDomain Code=509 "No active account"`

## ✅ Étapes de configuration sur App Store Connect

### 1. Accéder à App Store Connect
1. Allez sur [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Connectez-vous avec votre compte développeur
3. Sélectionnez votre app **WheelTrack**

### 2. Aller dans la section In-App Purchases
1. Dans le menu de gauche, cliquez sur **"Features"**
2. Sélectionnez **"In-App Purchases"**
3. Cliquez sur **"+"** pour créer un nouveau produit

### 3. Créer les 3 produits In-App

#### Produit 1 : Premium Mensuel
- **Type**: Auto-Renewable Subscription
- **Reference Name**: Premium Monthly
- **Product ID**: `com.andygrava.wheeltrack.premium.monthly`
- **Subscription Group**: WheelTrack Premium (créer si nécessaire)
- **Subscription Duration**: 1 Month
- **Price**: 4,99€
- **Display Name (FR)**: WheelTrack Premium - Mensuel
- **Description (FR)**: Accès Premium mensuel à toutes les fonctionnalités de WheelTrack

#### Produit 2 : Premium Annuel
- **Type**: Auto-Renewable Subscription
- **Reference Name**: Premium Yearly
- **Product ID**: `com.andygrava.wheeltrack.premium.yearly`
- **Subscription Group**: WheelTrack Premium (même groupe)
- **Subscription Duration**: 1 Year
- **Price**: 49,99€
- **Display Name (FR)**: WheelTrack Premium - Annuel
- **Description (FR)**: Accès Premium annuel à toutes les fonctionnalités de WheelTrack - Économisez 18%

#### Produit 3 : Premium à Vie
- **Type**: Non-Consumable
- **Reference Name**: Premium Lifetime
- **Product ID**: `com.andygrava.wheeltrack.premium.lifetime`
- **Price**: 79,99€
- **Display Name (FR)**: WheelTrack Premium - À Vie
- **Description (FR)**: Accès Premium à vie à toutes les fonctionnalités de WheelTrack

### 4. Configuration des métadonnées
Pour chaque produit, ajoutez :
- **Localizations** en français et anglais
- **Review Information** si nécessaire
- **Prix** pour tous les territoires

### 5. Approuver les produits
1. Une fois créés, les produits seront en statut **"Waiting for Review"**
2. Ils doivent être approuvés par Apple avant d'être utilisables
3. En attendant, vous pouvez tester avec des **Sandbox Testers**

## 🔧 Configuration des tests

### Option 1: Utiliser StoreKit Testing (recommandé)
1. Dans Xcode, allez dans **Product > Scheme > Edit Scheme**
2. Onglet **Run**
3. Section **Options**
4. **StoreKit Configuration**: sélectionnez votre fichier `Configuration.storekit`

### Option 2: Sandbox Testing
1. Créez des **Sandbox Testers** dans App Store Connect
2. Utilisez ces comptes de test sur votre appareil
3. Les produits doivent être en statut "Ready to Submit"

## ⚠️ Points importants

1. **Les produits doivent avoir exactement les mêmes IDs** que dans votre code :
   - `com.andygrava.wheeltrack.premium.monthly`
   - `com.andygrava.wheeltrack.premium.yearly`
   - `com.andygrava.wheeltrack.premium.lifetime`

2. **Attendre l'approbation** : Les produits peuvent prendre 24-48h pour être approuvés

3. **Test en local** : En attendant, utilisez StoreKit Testing dans Xcode

## 🎯 Une fois configuré

Après configuration sur App Store Connect :
- Les produits se chargeront correctement
- Le badge "💎 PREMIUM" apparaîtra automatiquement
- Les achats fonctionneront normalement

---
*Configuration requise pour résoudre l'erreur "Produits récupérés depuis StoreKit: 0"*


