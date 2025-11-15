# 🔧 Fix : Provisioning Profile & In-App Purchase

## 🔴 ERREUR RENCONTRÉE

```
Provisioning profile "iOS Team Provisioning Profile: com.Wheel.WheelTrack" 
doesn't include the com.apple.developer.in-app-purchase entitlement.
```

## 💡 POURQUOI CETTE ERREUR ?

**Problème** : Désynchronisation entre votre fichier local et Apple Developer

1. ✅ Fichier `entitlements` : In-App Purchase ajouté
2. ❌ App ID sur developer.apple.com : In-App Purchase manquant
3. ❌ Provisioning Profile : Créé AVANT l'ajout de In-App Purchase

**Solution** : Forcer la synchronisation !

---

## ✅ SOLUTION 1 : Régénération automatique (ESSAYEZ D'ABORD)

### **Dans Xcode** :

1. Target WheelTrack → Signing & Capabilities
2. **DÉCOCHEZ** "Automatically manage signing"
3. Attendez 2-3 secondes
4. **RECOCHEZ** "Automatically manage signing"
5. Attendez 10-30 secondes
6. Compilez (Cmd + B)

**Si l'erreur persiste** → Passez à la Solution 2

---

## ✅ SOLUTION 2 : Vérification App ID sur developer.apple.com

### **Étape 1 : Vérifier l'App ID**

1. **URL** : https://developer.apple.com/account/resources/identifiers/list
2. **Chercher** : `com.Wheel.WheelTrack`
3. **Cliquer** dessus

### **Étape 2 : Vérifier les Capabilities**

**Checklist** (toutes doivent être cochées ✅) :

- [ ] **Sign in with Apple**
- [ ] **iCloud** (Include CloudKit support)
- [ ] **Push Notifications**
- [ ] **In-App Purchase** ← **LE PLUS IMPORTANT !**

### **Étape 3 : Si In-App Purchase manque**

1. **Cochez** "In-App Purchase"
2. **Save** (en haut à droite)
3. **Confirm**
4. **Attendez** 5-10 minutes ⏰

### **Étape 4 : Télécharger les nouveaux profils**

1. Xcode → Settings (Cmd + ,)
2. **Accounts**
3. Sélectionnez votre Apple ID
4. **"Download Manual Profiles"**
5. Attendez la fin
6. **Fermez** Settings

### **Étape 5 : Réinitialiser la signature**

1. Retour au projet → Signing & Capabilities
2. **Décochez** "Automatically manage signing"
3. **Recochez** "Automatically manage signing"
4. **Compilez** (Cmd + B)

---

## ✅ SOLUTION 3 : Nettoyage complet (DERNIER RECOURS)

### **Étape 1 : Nettoyer Xcode**

```bash
# Terminal
cd "/Volumes/Extreme SSD/Développement App/WheelTrack"
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

### **Étape 2 : Supprimer les anciens profils**

1. Xcode → Settings → Accounts
2. Sélectionnez votre Apple ID
3. Cliquez sur "Manage Certificates..."
4. Sélectionnez les anciens profils WheelTrack
5. Supprimez-les (bouton "-")
6. Fermez

### **Étape 3 : Forcer la recréation**

1. Dans le projet → Signing & Capabilities
2. **Décochez** "Automatically manage signing"
3. **Changez** temporairement le Bundle ID en `com.Wheel.WheelTrack.temp`
4. **Attendez** l'erreur (normal)
5. **Remettez** le Bundle ID original : `com.Wheel.WheelTrack`
6. **Recochez** "Automatically manage signing"
7. **Attendez** 30 secondes
8. **Compilez**

---

## ✅ SOLUTION 4 : Créer manuellement l'App ID avec In-App Purchase

Si **l'App ID n'existe PAS** sur developer.apple.com :

### **Créer l'App ID**

1. **URL** : https://developer.apple.com/account/resources/identifiers/list
2. **"+"** (Create a New Identifier)
3. **App IDs** → Continue
4. **App** → Continue

### **Configuration**

```
Description: WheelTrack
Bundle ID: Explicit → com.Wheel.WheelTrack
```

### **Capabilities à cocher** :

- ✅ Sign in with Apple
- ✅ iCloud (Include CloudKit support)
- ✅ Push Notifications
- ✅ In-App Purchase

### **Finaliser**

1. **Continue**
2. **Register**
3. **Attendez 5-10 minutes**

### **Retour dans Xcode**

1. Xcode → Settings → Accounts
2. Download Manual Profiles
3. Signing & Capabilities
4. Décochez/Recochez "Automatically manage signing"

---

## 🔍 VÉRIFICATION FINALE

### **Dans Xcode - Signing & Capabilities**

Vous devez voir :

```
✅ Automatically manage signing (coché)
Team: Andy Grava (5WUC3D8BMJ)
Provisioning Profile: iOS Team Provisioning Profile: com.Wheel.WheelTrack
Signing Certificate: Apple Development: votre@email.com

Capabilities:
  ✅ iCloud
  ✅ Sign in with Apple
  ✅ Push Notifications
  ✅ In-App Purchase
```

**Statut** : Pas d'erreur, pas de triangle jaune/rouge

### **Test de compilation**

```
Product → Clean Build Folder (Shift + Cmd + K)
Product → Build (Cmd + B)
```

**Résultat attendu** : ✅ Build Succeeded

---

## ⏰ COMBIEN DE TEMPS ?

### **Délais normaux** :

- **Régénération automatique** : 10-30 secondes
- **Modification App ID** : 5-30 minutes
- **Création nouvel App ID** : 5-60 minutes
- **Synchronisation complète** : Jusqu'à 2 heures (rare)

### **Si ça prend trop longtemps** :

1. Attendez 30 minutes minimum après modification
2. Redémarrez Xcode
3. Réessayez "Download Manual Profiles"
4. Si toujours rien après 2h → Contactez Apple Developer Support

---

## 🆘 ERREURS FRÉQUENTES

### **"Failed to create provisioning profile"**

→ L'App ID n'existe pas ou les capabilities ne sont pas synchronisées  
→ Solution : Vérifier sur developer.apple.com + Attendre 10 minutes

### **"No profiles for 'com.Wheel.WheelTrack' were found"**

→ L'App ID n'existe pas  
→ Solution : Créer l'App ID (Solution 4)

### **"Your account already has a valid certificate"**

→ Normal, ignorez ce message  
→ Continuez la configuration

### **"Automatic signing is unable to resolve an issue"**

→ Problème de synchronisation  
→ Solution : Attendre 10-30 minutes + Réessayer

---

## 📋 CHECKLIST COMPLÈTE

### **Avant de commencer** :

- [ ] Connexion internet stable
- [ ] Compte Apple Developer actif
- [ ] Accès à developer.apple.com

### **Vérifications** :

- [ ] App ID existe sur developer.apple.com
- [ ] App ID a la capability "In-App Purchase" cochée
- [ ] Profils téléchargés (Download Manual Profiles)
- [ ] Signature automatique activée
- [ ] Pas d'erreur dans Signing & Capabilities
- [ ] Compilation réussie (Build Succeeded)

### **Si tout est coché** :

✅ **In-App Purchase est configuré et fonctionnel !**

---

## 🎯 SOLUTION RAPIDE RÉSUMÉE

**90% des cas sont résolus avec** :

1. Décocher/Recocher "Automatically manage signing"
2. Attendre 30 secondes
3. Compiler

**Si ça ne marche pas** :

1. Vérifier l'App ID sur developer.apple.com
2. Ajouter la capability In-App Purchase
3. Attendre 10 minutes
4. Download Manual Profiles
5. Décocher/Recocher signature automatique
6. Compiler

**Temps total** : 5-15 minutes maximum

---

## ✅ RÉSULTAT ATTENDU

Après avoir suivi ce guide :

✅ Pas d'erreur de provisioning profile  
✅ In-App Purchase visible dans Signing & Capabilities  
✅ Compilation réussie  
✅ Prêt pour tester les achats  

**Vous êtes prêt pour App Store Connect ! 🚀**


