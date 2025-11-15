# 🔧 SOLUTION : Problème de Cache StoreKit

## ✅ Vos produits SONT bien configurés !

Votre application contient bien **3 produits** correctement configurés :
- ✅ `com.andygrava.wheeltrack.premium.monthly` (4.99€)
- ✅ `com.andygrava.wheeltrack.premium.yearly` (49.99€)
- ✅ `com.andygrava.wheeltrack.premium.lifetime` (79.99€)

Le problème est juste un **cache Xcode** qui empêche leur chargement.

---

## 🚀 SOLUTION EN 6 ÉTAPES (5 minutes)

### Étape 1 : Clean Build Folder
Dans Xcode, appuyez sur : **Cmd + Shift + K**
(ou menu : Product > Clean Build Folder)

### Étape 2 : Fermer Xcode complètement
Appuyez sur : **Cmd + Q**
⚠️ Vérifiez que Xcode est bien fermé (icône ne doit plus être dans le Dock)

### Étape 3 : Supprimer le cache DerivedData
Ouvrez le **Terminal** et collez cette commande :

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/WheelTrack-*
```

Appuyez sur **Entrée**. Ça va supprimer le cache corrompu.

### Étape 4 : Réinitialiser le simulateur (optionnel mais recommandé)
Dans le Terminal, collez :

```bash
xcrun simctl shutdown all
xcrun simctl erase all
```

Appuyez sur **Entrée**. Ça va réinitialiser tous vos simulateurs.

### Étape 5 : Rouvrir Xcode
1. Rouvrez Xcode
2. Ouvrez votre projet WheelTrack

### Étape 6 : Vérifier le scheme et lancer
1. Cliquez sur **"WheelTrack"** en haut à gauche (à côté du bouton Play)
2. Sélectionnez **"Edit Scheme..."** (ou Cmd + <)
3. Vérifiez que :
   - **Run** est sélectionné à gauche
   - Onglet **Options** en haut
   - **StoreKit Configuration** → `Configuration.storekit` est sélectionné
4. Cliquez **Close**
5. Appuyez sur **Cmd + R** pour lancer l'app

---

## 🧪 COMMENT TESTER

Une fois l'app lancée :

1. Allez dans : **Réglages → 🔧 Outils de Développement → Debug StoreKit**
2. Cliquez sur **"Tester l'API StoreKit"** (bouton violet)
3. Regardez le log en bas de l'écran

### ✅ Résultat attendu :
```
✅ API StoreKit répond: 3 produits trouvés
  • com.andygrava.wheeltrack.premium.monthly: WheelTrack Premium - Mensuel - 4,99€
  • com.andygrava.wheeltrack.premium.yearly: WheelTrack Premium - Annuel - 49,99€
  • com.andygrava.wheeltrack.premium.lifetime: WheelTrack Premium - À Vie - 79,99€
```

Vous devriez voir **"Produits : 3"** en bleu dans la section statut.

---

## ❌ Si ça ne fonctionne TOUJOURS PAS

### Option 1 : Supprimer TOUT le cache Xcode
Dans le Terminal :

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

Puis redémarrez votre Mac et relancez Xcode.

### Option 2 : Vérifier que le fichier .storekit est bien dans le projet
1. Dans Xcode, cherchez `Configuration.storekit` dans le navigateur de fichiers (à gauche)
2. Cliquez dessus
3. Dans l'inspecteur à droite (bouton en haut à droite), vérifiez que :
   - ✅ **Target Membership** → WheelTrack est **coché**

Si ce n'est pas coché, cochez-le !

---

## 💡 Pourquoi ça arrive ?

Xcode garde un cache des builds précédents. Quand vous modifiez :
- Le fichier `.storekit`
- Le scheme
- Les Product IDs

Le cache n'est pas toujours mis à jour automatiquement. C'est un bug connu de Xcode avec StoreKit.

**La solution est TOUJOURS de nettoyer le cache complètement.**

---

## ⚠️ Note importante

**Vous N'AVEZ PAS besoin d'App Store Connect** pour que ça fonctionne !

Le fichier `Configuration.storekit` est fait pour tester **SANS** App Store Connect.
C'est uniquement pour les tests en local dans le simulateur.

Une fois que ça fonctionne en local, vous pourrez créer les produits sur App Store Connect pour la version de production.

---

## 📱 Code des 3 produits (pour référence)

Vos Product IDs (à NE PAS modifier) :
```
com.andygrava.wheeltrack.premium.monthly
com.andygrava.wheeltrack.premium.yearly
com.andygrava.wheeltrack.premium.lifetime
```

Ces IDs sont bien configurés dans :
- ✅ `Configuration.storekit` (fichier de test)
- ✅ `StoreKitService.swift` (code de l'app)
- ✅ `StoreKitDebugView.swift` (vue de debug)

Tout est cohérent ! 🎯

---

**Suivez les 6 étapes ci-dessus et vous verrez vos 3 produits !** 🚀

