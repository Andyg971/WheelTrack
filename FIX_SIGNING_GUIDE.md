# 🔧 Guide pour résoudre l'échec de signature automatique

## Problème actuel
La signature automatique échoue même après avoir signé les accords App Store Connect.

---

## 📝 Étapes de résolution

### **Étape 1 : Vérifier et rafraîchir les profils Xcode**

1. **Ouvre Xcode**
2. Va dans le menu `Xcode` → `Settings` (ou `Preferences`)
3. Clique sur l'onglet **Accounts**
4. Sélectionne ton compte Apple
5. Clique sur ton équipe (Team: 5WUC3D8BMJ)
6. Clique sur le bouton **"Download Manual Profiles"** en bas
7. Clique ensuite sur **"Manage Certificates..."**
8. Si tu vois un certificat "Apple Development", c'est bon
9. Sinon, clique sur le **+** et choisis **"Apple Development"**

---

### **Étape 2 : Nettoyer les données Xcode (important !)**

Ouvre le Terminal et tape ces commandes une par une :

```bash
# 1. Supprime les données de provisioning
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles

# 2. Supprime le cache dérivé
rm -rf ~/Library/Developer/Xcode/DerivedData

# 3. Nettoie le projet
cd "/Volumes/Extreme SSD/Développement App/WheelTrack"
xcodebuild clean -project WheelTrack.xcodeproj -scheme WheelTrack
```

---

### **Étape 3 : Vérifier l'App ID sur le Developer Portal**

1. Va sur [Apple Developer - Identifiers](https://developer.apple.com/account/resources/identifiers/list)
2. Cherche l'App ID : **com.Wheel.WheelTrack**
   
   **CAS A - L'App ID existe :**
   - Clique dessus
   - Vérifie que ces capabilities sont **cochées** :
     - ✅ Sign in with Apple
     - ✅ iCloud (avec CloudKit)
     - ✅ In-App Purchase
   - Si une capability manque, coche-la et clique **Save**

   **CAS B - L'App ID n'existe PAS :**
   - Clique sur le bouton **+** (Create a New Identifier)
   - Sélectionne **App IDs** → Continue
   - Choisis **App** → Continue
   - Description : **WheelTrack**
   - Bundle ID : **com.Wheel.WheelTrack** (Explicit)
   - Coche les capabilities :
     - ✅ Sign in with Apple
     - ✅ iCloud (sélectionne "Include CloudKit support")
     - ✅ In-App Purchase
   - Clique **Continue** puis **Register**

---

### **Étape 4 : Configurer CloudKit Container**

1. Va sur [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard)
2. Si le container **iCloud.com.Wheel.WheelTrack** n'existe pas :
   - Créer un nouveau container avec ce nom exact
3. Vérifie que ce container est lié à ton App ID

---

### **Étape 5 : Reconfigurer la signature dans Xcode**

1. Ouvre ton projet **WheelTrack.xcodeproj** dans Xcode
2. Sélectionne le projet dans le navigateur (icône bleue en haut)
3. Sélectionne la target **WheelTrack**
4. Va dans l'onglet **Signing & Capabilities**
5. **Désactive** temporairement "Automatically manage signing"
6. Attends 2 secondes
7. **Réactive** "Automatically manage signing"
8. Sélectionne ton équipe : **Personal Team** ou ton équipe avec le Team ID `5WUC3D8BMJ`
9. Regarde les erreurs qui s'affichent

---

### **Étape 6 : Solutions selon l'erreur affichée**

#### ❌ **Erreur : "Failed to create provisioning profile"**
→ Les accords ne sont pas encore propagés. **Attendre 24h** puis réessayer.

#### ❌ **Erreur : "No certificate found"**
→ Aller dans Xcode Settings → Accounts → Manage Certificates → Ajouter "Apple Development"

#### ❌ **Erreur : "App ID does not match"**
→ Vérifier que le Bundle Identifier dans Xcode est exactement : `com.Wheel.WheelTrack`

#### ❌ **Erreur : "Capabilities not supported"**
→ Aller configurer l'App ID sur le Developer Portal (voir Étape 3)

---

### **Étape 7 : Tester avec une signature manuelle (temporaire)**

Si rien ne fonctionne, essaie la signature manuelle pour débloquer la situation :

1. Dans Xcode, onglet **Signing & Capabilities**
2. **Désactive** "Automatically manage signing"
3. Dans **Provisioning Profile**, sélectionne **"Download Manual Profiles"**
4. Attends que Xcode télécharge les profils
5. Sélectionne un profil de développement disponible

---

## ⏰ **Délais à respecter**

| Action | Délai de propagation |
|--------|---------------------|
| Signature des accords | 1-24 heures |
| Création App ID | Instantané |
| Création Capabilities | 5-30 minutes |
| Création Certificats | Instantané |
| Provisioning Profile | 1-5 minutes |

---

## 🎯 **Checklist finale**

Avant de réessayer, vérifie que :

- [ ] Les accords App Store Connect sont signés et actifs
- [ ] L'App ID `com.Wheel.WheelTrack` existe sur Developer Portal
- [ ] Les capabilities (CloudKit, Sign in with Apple, In-App Purchase) sont activées sur l'App ID
- [ ] Le CloudKit container `iCloud.com.Wheel.WheelTrack` existe
- [ ] Tu as attendu au moins 24h après la signature des accords
- [ ] Le cache Xcode a été nettoyé
- [ ] Les profils ont été téléchargés dans Xcode Settings → Accounts

---

## 📞 **Si rien ne fonctionne après 48h**

Contacte le support Apple Developer :
- [Apple Developer Support](https://developer.apple.com/contact/)
- Ou appelle-les directement (disponible en français)

Donne-leur ces informations :
- Team ID : **5WUC3D8BMJ**
- Bundle ID : **com.Wheel.WheelTrack**
- Problème : "Automatic signing fails despite signed agreements"

