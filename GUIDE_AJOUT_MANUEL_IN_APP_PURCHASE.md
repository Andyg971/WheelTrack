# 📱 Guide : Ajouter In-App Purchase manuellement dans Xcode

## ✅ Ce qui a été fait

J'ai **supprimé** la capability "In-App Purchase" du fichier `WheelTrack.entitlements`.

Vous pouvez maintenant l'ajouter **manuellement** dans Xcode sans risque de bug.

---

## 🎯 Comment l'ajouter manuellement (Étape par étape)

### **Étape 1 : Ouvrir Xcode**
1. Ouvrez votre projet **WheelTrack** dans Xcode
2. Cliquez sur le projet (icône bleue) dans le navigateur de gauche

### **Étape 2 : Aller dans Signing & Capabilities**
1. Sélectionnez la **target "WheelTrack"** (pas WheelTrackTests)
2. Cliquez sur l'onglet **"Signing & Capabilities"** en haut

### **Étape 3 : Ajouter la Capability**
1. Cliquez sur le bouton **"+ Capability"** en haut à gauche
2. Dans la liste qui apparaît, cherchez **"In-App Purchase"**
3. Cliquez dessus pour l'ajouter

### **Étape 4 : Vérification**
Vous devriez maintenant voir dans "Signing & Capabilities" :
- ✅ Sign in with Apple
- ✅ iCloud (avec CloudKit)
- ✅ Push Notifications
- ✅ **In-App Purchase** (nouvelle)

---

## 🔍 Ce qui va se passer automatiquement

Quand vous ajoutez "In-App Purchase" manuellement :

1. **Xcode va automatiquement** ajouter cette ligne dans `WheelTrack.entitlements` :
```xml
<key>com.apple.developer.in-app-purchase</key>
<true/>
```

2. **Aucun bug** ne sera créé, car :
   - Xcode gère automatiquement les entitlements
   - Votre code StoreKit reste intact
   - Le fichier `Configuration.storekit` est toujours présent

---

## ⚠️ IMPORTANT : Problèmes détectés à corriger AVANT

### **1. Bundle ID incohérent** 🔴

Vous avez actuellement **deux Bundle IDs différents** :

**Dans Xcode** :
```
com.Wheel.WheelTrack
```

**Dans le code (AppStoreConfigService.swift)** :
```
com.wheeltrack.app
```

### **Action à faire :**

**Option A - Changer dans Xcode (RECOMMANDÉ)** :
1. Dans Xcode → Target WheelTrack → General
2. Bundle Identifier → Mettre `com.wheeltrack.app`
3. **Raison** : Plus propre, tout en minuscules

**Option B - Changer dans le code** :
1. Ouvrir `WheelTrack/Services/AppStoreConfigService.swift`
2. Ligne 11 : Mettre `com.Wheel.WheelTrack`

### **2. Team ID non configuré** 🟡

Dans `AppStoreConfigService.swift`, ligne 14 :
```swift
public let teamID = "VOTRE_TEAM_ID" // ❌ À changer
```

**Changer par :**
```swift
public let teamID = "5WUC3D8BMJ" // ✅ Votre vrai Team ID
```

---

## 📋 Checklist finale

### **Avant d'ajouter In-App Purchase manuellement :**
- [ ] Ouvrir Xcode
- [ ] Vérifier que le projet compile sans erreur
- [ ] Corriger le Bundle ID (choisir Option A ou B)
- [ ] Corriger le Team ID dans le code

### **Ajouter In-App Purchase :**
- [ ] Signing & Capabilities → + Capability
- [ ] Chercher "In-App Purchase"
- [ ] Cliquer pour ajouter
- [ ] Vérifier qu'elle apparaît bien dans la liste

### **Vérification post-ajout :**
- [ ] Compiler le projet (Cmd + B)
- [ ] Vérifier qu'il n'y a pas d'erreur de signature
- [ ] Le fichier `WheelTrack.entitlements` doit maintenant contenir la ligne In-App Purchase

---

## 🆘 Si vous voyez une erreur après l'ajout

### **Erreur : "Failed to register bundle identifier"**
→ Le Bundle ID n'existe pas sur developer.apple.com  
→ Créez-le sur https://developer.apple.com/account/resources/identifiers/list

### **Erreur : "Provisioning profile doesn't include the In-App Purchase entitlement"**
→ Désactivez puis réactivez "Automatically manage signing"  
→ Attendez 5-10 minutes pour la synchronisation

### **Erreur : "No profiles for ... were found"**
→ Xcode → Settings → Accounts → Download Manual Profiles  
→ Réessayez

---

## ✅ Résultat attendu

Après avoir ajouté manuellement :

1. **Dans Xcode** : Vous verrez "In-App Purchase" dans Signing & Capabilities
2. **Dans le fichier** : `WheelTrack.entitlements` contiendra la ligne automatiquement
3. **Aucun bug** : Tout continuera à fonctionner normalement
4. **Contrôle total** : Vous pourrez voir et gérer la capability visuellement

---

**C'est prêt ! Vous pouvez maintenant ajouter In-App Purchase manuellement dans Xcode.** 🚀

