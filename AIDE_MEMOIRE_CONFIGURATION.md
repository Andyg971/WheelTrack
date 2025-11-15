# 📋 Aide-Mémoire : Configuration In-App Purchase

## ✅ CE QUI EST FAIT

### **1. In-App Purchase ACTIVÉ** ✨
```
Fichier : WheelTrack/WheelTrack.entitlements
Ajout : com.apple.developer.in-app-purchase = true
```

### **2. Configuration locale prête**
- ✅ 3 produits dans Configuration.storekit
- ✅ Bundle ID : `com.Wheel.WheelTrack`
- ✅ Team ID : `5WUC3D8BMJ`
- ✅ Code StoreKit fonctionnel

---

## 🎯 CE QU'IL RESTE À FAIRE

### **📱 Dans App Store Connect**

#### **Étape 1 : Créer l'app**
- URL : https://appstoreconnect.apple.com
- Bundle ID : `com.Wheel.WheelTrack` ← COPIER-COLLER exactement

#### **Étape 2 : 3 Produits In-App à créer**

**Product IDs à copier-coller** :
```
com.andygrava.wheeltrack.premium.monthly
com.andygrava.wheeltrack.premium.yearly
com.andygrava.wheeltrack.premium.lifetime
```

**Prix suggérés** :
- Mensuel : 4,99€
- Annuel : 49,99€
- Lifetime : 79,99€

#### **Étape 3 : Upload un build**
- Xcode → Product → Archive
- Upload vers App Store Connect
- Attendre 10-30 minutes

#### **Étape 4 : Créer Sandbox Tester**
- Email fictif : test.wheeltrack@icloud.com
- Pays : France

---

## 🔍 VÉRIFICATIONS RAPIDES

### **Dans Xcode (maintenant)**
1. Ouvrir le projet
2. Target WheelTrack → Signing & Capabilities
3. Vérifier : "In-App Purchase" est présent (pas "Waiting to attach")
4. Si oui → ✅ Tout est bon !

### **Dans App Store Connect (après création)**
1. App créée avec bon Bundle ID → ✅
2. 3 produits en "Ready to Submit" → ✅
3. Build présent dans TestFlight → ✅
4. Sandbox Tester créé → ✅

### **Sur iPhone (test final)**
1. App installée via TestFlight → ✅
2. Achat test réussi (gratuit) → ✅
3. Badge Premium affiché → ✅
4. Fonctionnalités débloquées → ✅

---

## 🚨 RAPPELS IMPORTANTS

### **Bundle ID**
- Toujours utiliser : `com.Wheel.WheelTrack`
- Vérifier dans : Xcode, App Store Connect, Developer Portal

### **Product IDs**
- Copier-coller exactement depuis cette liste
- Pas d'espace, pas de majuscule en trop

### **Sandbox Testing**
- NE JAMAIS utiliser votre vrai Apple ID
- Toujours créer un Sandbox Tester dédié
- Les achats sont GRATUITS en Sandbox

### **Timeline**
- Création app : Instantané
- Création produits : Instantané
- Upload build : 5-10 min
- Build visible : 10-30 min
- Tests possibles : Dès que build en "Ready to Test"

---

## 📂 DOCUMENTS UTILES

### **Guides créés pour vous**
1. `GUIDE_APP_STORE_CONNECT_COMPLET.md` ← **Guide détaillé étape par étape**
2. `AIDE_MEMOIRE_CONFIGURATION.md` ← **Ce document (rappels rapides)**
3. `RESUME_MODIFICATIONS.md` ← Résumé des modifications
4. `ETAT_CONFIGURATION_APP_STORE.md` ← État de la config

### **Configuration StoreKit**
- `WheelTrack/Configuration.storekit` ← Configuration locale
- `WheelTrack/Services/StoreKitService.swift` ← Service d'achat
- `WheelTrack/Services/FreemiumService.swift` ← Gestion Premium

---

## 🎯 ORDRE DES OPÉRATIONS

```
1. ✅ Activer In-App Purchase (FAIT !)
   ↓
2. 🌐 Créer app dans App Store Connect
   ↓
3. 💳 Créer les 3 produits In-App
   ↓
4. 📦 Upload un build via Xcode
   ↓
5. 👤 Créer Sandbox Tester
   ↓
6. 🧪 Tester les achats sur iPhone
   ↓
7. 🎉 TERMINÉ ! Système fonctionnel
```

---

## 💡 PROCHAINE ÉTAPE IMMÉDIATE

**Ouvrez Xcode et vérifiez que "In-App Purchase" est bien actif !**

Ensuite, suivez le guide complet : `GUIDE_APP_STORE_CONNECT_COMPLET.md`

---

## ✨ RÉCAPITULATIF EXPRESS

**Vous avez maintenant** :
- ✅ In-App Purchase activé
- ✅ Code fonctionnel
- ✅ Configuration locale prête
- ✅ Guides complets pour la suite

**Il vous reste** :
- 🌐 Créer l'app sur App Store Connect (5 min)
- 💳 Créer 3 produits (10 min)
- 📦 Uploader un build (15 min)
- 🧪 Tester avec Sandbox (10 min)

**Total estimé : 40 minutes pour tout finaliser ! 🚀**

