# 🔍 Comment vérifier ton App ID - Guide visuel

## 🎯 Objectif

Vérifier que l'App ID **com.Wheel.WheelTrack** existe et est bien configuré sur le Developer Portal d'Apple.

---

## 📝 Étapes détaillées

### **Étape 1 : Ouvre le Developer Portal**

1. Va sur ce lien : [https://developer.apple.com/account/resources/identifiers/list](https://developer.apple.com/account/resources/identifiers/list)
2. Connecte-toi avec ton compte Apple Developer
3. Tu arrives sur la page **"Identifiers"**

---

### **Étape 2 : Cherche ton App ID**

Tu vas voir une liste d'identifiants. Cherche :
- **Type** : App IDs
- **Identifier** : `com.Wheel.WheelTrack`

#### 🟢 **CAS A : Tu le trouves**

Si tu vois `com.Wheel.WheelTrack` dans la liste :
- **Clique dessus** pour ouvrir les détails
- **Passe à l'Étape 3**

#### 🔴 **CAS B : Tu ne le trouves PAS**

Si tu ne vois PAS `com.Wheel.WheelTrack` :
- **C'est le problème !** L'App ID n'existe pas encore
- **Passe à l'Étape 4** pour le créer

---

### **Étape 3 : Vérifier les Capabilities (si l'App ID existe)**

Une fois sur la page de détails de ton App ID, vérifie que ces 3 capabilities sont **cochées** :

#### 📋 **Checklist des Capabilities nécessaires**

- [ ] **Sign in with Apple** (ou "Sign In with Apple")
  - Doit être coché ✅
  - Si ce n'est pas le cas, coche-le

- [ ] **iCloud**
  - Doit être coché ✅
  - Doit avoir **"Include CloudKit support (requires Xcode 5)"** coché
  - Si ce n'est pas le cas :
    1. Coche "iCloud"
    2. Coche aussi "Include CloudKit support"

- [ ] **In-App Purchase**
  - Doit être coché ✅
  - Si ce n'est pas le cas, coche-le

#### Si tu as changé quelque chose :
1. Clique sur le bouton **"Save"** en haut à droite
2. Confirme en cliquant **"Confirm"**
3. **Attends 5-10 minutes** que les changements se propagent
4. **Retourne dans Xcode** et réessaie la signature automatique

---

### **Étape 4 : Créer l'App ID (si il n'existe pas)**

Si l'App ID `com.Wheel.WheelTrack` n'existe PAS, tu dois le créer :

#### **4.1 - Commencer la création**

1. Sur la page des Identifiers, clique sur le bouton **"+"** (ou "Create a New Identifier")
2. Sélectionne **"App IDs"**
3. Clique **"Continue"**

#### **4.2 - Choisir le type**

1. Sélectionne **"App"** (pas "App Clip")
2. Clique **"Continue"**

#### **4.3 - Remplir les informations**

**Description :**
```
WheelTrack
```
(C'est juste un nom descriptif pour toi)

**Bundle ID :**
- Sélectionne **"Explicit"** (pas Wildcard)
- Entre exactement : `com.Wheel.WheelTrack`
  - ⚠️ **ATTENTION** : Respecte bien les majuscules et minuscules
  - C'est : `com.Wheel.WheelTrack` (W et T majuscules)
  - PAS : `com.wheel.wheeltrack`

#### **4.4 - Configurer les Capabilities**

Descends dans la page et **coche ces 3 options** :

1. **Sign in with Apple** ✅
   - Coche simplement la case

2. **iCloud** ✅
   - Coche la case "iCloud"
   - **IMPORTANT** : Coche aussi "Include CloudKit support (requires Xcode 5)"

3. **In-App Purchase** ✅
   - Coche la case

**Laisse toutes les autres options décochées** (sauf si tu sais pourquoi tu en aurais besoin)

#### **4.5 - Finaliser**

1. Clique **"Continue"**
2. Vérifie que tout est correct :
   - Bundle ID : `com.Wheel.WheelTrack`
   - Sign in with Apple : ✅
   - iCloud : ✅
   - In-App Purchase : ✅
3. Clique **"Register"**
4. **C'est fait ! 🎉**

---

## ⏰ Après avoir créé ou modifié l'App ID

### **Délai d'attente :**
- **Création d'App ID** : Instantané à 5 minutes
- **Modification de Capabilities** : 5-30 minutes
- **Synchronisation avec Xcode** : 10-60 minutes

### **Actions à faire dans Xcode :**

1. **Attends 10 minutes** minimum après la création/modification
2. **Ouvre Xcode**
3. Va dans `Xcode` → `Settings` → `Accounts`
4. Sélectionne ton compte Apple
5. Clique sur **"Download Manual Profiles"**
6. Attends la fin du téléchargement
7. **Retourne dans ton projet**
8. Va dans `Signing & Capabilities`
9. **Désactive** "Automatically manage signing"
10. **Réactive** "Automatically manage signing"
11. Regarde si l'erreur a disparu

---

## 🔍 Comment savoir si ça a marché ?

### **Dans Xcode, onglet Signing & Capabilities :**

#### ✅ **Ça marche si tu vois :**
- Un **statut vert** ou pas de message d'erreur
- **"Provisioning Profile"** : un nom de profil (pas vide)
- **"Signing Certificate"** : "Apple Development: ton@email.com"
- Pas de triangle jaune ⚠️ ou rouge 🔴

#### ❌ **Ça ne marche pas encore si tu vois :**
- **"Failed to create provisioning profile"**
  - → Attends encore (délai de propagation)
- **"No profiles for 'com.Wheel.WheelTrack' were found"**
  - → L'App ID n'est pas encore synchronisé, attends 10 min
- **"An App ID with Identifier 'com.Wheel.WheelTrack' is not available"**
  - → L'App ID n'existe pas ou il y a une faute de frappe

---

## 📊 Checklist complète

Avant de dire "ça ne marche pas", vérifie que :

- [ ] L'App ID `com.Wheel.WheelTrack` existe sur developer.apple.com
- [ ] Les 3 capabilities sont cochées (Sign in with Apple, iCloud, In-App Purchase)
- [ ] Tu as attendu au moins 10 minutes après la création/modification
- [ ] Tu as cliqué sur "Download Manual Profiles" dans Xcode Settings
- [ ] Tu as désactivé puis réactivé "Automatically manage signing"
- [ ] Ça fait au moins 24h que tu as signé les accords App Store Connect

---

## 🆘 Si ça ne marche toujours pas

### **Vérifie exactement le Bundle ID dans Xcode :**

1. Ouvre ton projet dans Xcode
2. Sélectionne le projet (icône bleue)
3. Sélectionne la target "WheelTrack"
4. Va dans l'onglet **"General"**
5. Cherche **"Bundle Identifier"**
6. Vérifie que c'est EXACTEMENT : `com.Wheel.WheelTrack`
   - Attention aux majuscules !
   - Attention aux espaces !

### **Si le Bundle Identifier est différent :**

**Par exemple, si c'est `com.wheel.wheeltrack` (tout en minuscules) :**

Tu as 2 options :

**Option A** : Changer le Bundle ID dans Xcode pour qu'il corresponde à l'App ID
**Option B** : Créer un nouvel App ID qui correspond au Bundle ID actuel

**Je recommande Option A** : Garde `com.Wheel.WheelTrack` comme c'est plus propre.

---

## 📞 Contact Support Apple

Si vraiment rien ne fonctionne après 48h et que tu as tout vérifié :

1. Va sur [Apple Developer Contact](https://developer.apple.com/contact/)
2. Sélectionne **"Developer Program Support"**
3. Choisis **"App IDs, Certificates & Provisioning"**
4. Explique ton problème :

```
Bonjour,

J'ai signé les accords App Store Connect il y a [X] heures.
Tous mes accords sont actifs mais la signature automatique échoue dans Xcode.

Team ID : 5WUC3D8BMJ
Bundle ID : com.Wheel.WheelTrack
App ID créé : [OUI/NON]
Erreur exacte : [copie l'erreur de Xcode]

Pouvez-vous vérifier si mes accords sont bien propagés dans le système ?

Merci !
```

---

## ✅ Résumé en images (décrit)

### **Page Identifiers (developer.apple.com)**
Tu dois voir une liste avec :
- Colonne "Name" : WheelTrack (si tu l'as créé)
- Colonne "Identifier" : com.Wheel.WheelTrack
- Colonne "Type" : App ID
- Colonne "Platform" : iOS, macOS (ou juste iOS)

### **Page de détails de l'App ID**
Tu dois voir :
- En haut : "com.Wheel.WheelTrack"
- Section "App Services" avec des cases cochées :
  - ✅ Sign in with Apple (Enabled)
  - ✅ iCloud (Enabled - includes CloudKit support)
  - ✅ In-App Purchase (Enabled)

### **Xcode - Signing & Capabilities**
Tu dois voir :
- [ ] Automatically manage signing (coché)
- Team : Ton nom ou ton organisation
- Bundle Identifier : com.Wheel.WheelTrack (grisé, non modifiable)
- Provisioning Profile : Un nom comme "iOS Team Provisioning Profile: com.Wheel.WheelTrack"
- Signing Certificate : "Apple Development: ton@email.com"
- **Capabilities** (en bas) :
  - Sign in with Apple
  - iCloud (avec le container iCloud.com.Wheel.WheelTrack)
  - In-App Purchase

---

**Bon courage ! 🚀**

