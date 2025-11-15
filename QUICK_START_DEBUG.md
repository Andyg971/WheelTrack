# ⚡ Démarrage Rapide - Test des Achats

## 🎯 En 3 étapes simples

### Étape 1 : Ouvrir l'outil de debug
```
Lancez l'app → Réglages → 🔧 Outils de Développement → Debug StoreKit
```

### Étape 2 : Tester l'API
```
Cliquez sur le bouton VIOLET "Tester l'API StoreKit"
```

### Étape 3 : Lire le résultat
```
Regardez en bas dans la section "Log de débogage"
```

---

## 📊 Que devez-vous voir ?

### ✅ Si tout fonctionne :

En haut de l'écran, vous devriez voir :
- **Produits : 3** (en bleu)
- **Prêt** (en vert)

Dans le log, vous devriez voir :
```
✅ API StoreKit répond: 3 produits trouvés
  • com.andygrava.wheeltrack.premium.monthly: ...
  • com.andygrava.wheeltrack.premium.yearly: ...
  • com.andygrava.wheeltrack.premium.lifetime: ...
```

➡️ **Si vous voyez ça** : Tout fonctionne ! Testez un achat avec le bouton vert.

---

### ❌ Si ça ne fonctionne PAS :

En haut de l'écran, vous verrez :
- **Produits : 0** (en bleu)

Dans le log, vous verrez :
```
⚠️ PROBLÈME: Aucun produit retourné par l'API
💡 Vérifiez que Configuration.storekit est bien configuré...
```

➡️ **Si vous voyez ça** : Suivez les instructions ci-dessous.

---

## 🛠️ Solution si 0 produits

### Solution 1 : Clean Build (90% de chances de résoudre)

1. Dans Xcode, menu du haut : **Product > Clean Build Folder**  
   (ou appuyez sur `Cmd + Shift + K`)

2. **Fermez complètement Xcode** (Cmd + Q)

3. **Rouvrez Xcode**

4. **Relancez l'app** (Cmd + R)

5. **Retestez** dans Debug StoreKit

---

### Solution 2 : Vérifier le Scheme

1. En haut à gauche de Xcode, cliquez sur **"WheelTrack"** (à côté du bouton Play)

2. Sélectionnez **"Edit Scheme..."**

3. Dans la fenêtre qui s'ouvre :
   - Sélectionnez **"Run"** à gauche
   - Cliquez sur l'onglet **"Options"**
   - Cherchez **"StoreKit Configuration"**
   - Vérifiez que **"Configuration.storekit"** est sélectionné

4. Cliquez **"Close"**

5. **Relancez l'app**

---

### Solution 3 : Réinitialiser le simulateur

1. Dans le simulateur : **Device > Erase All Content and Settings...**

2. Confirmez

3. **Relancez l'app depuis Xcode**

4. **Retestez**

---

## 🧪 Test d'achat

Une fois que vous voyez **3 produits** :

1. Dans la vue de debug, sous chaque produit, cliquez sur le **bouton vert "Tester l'achat"**

2. **Un popup Apple devrait apparaître** avec :
   - Le nom du produit
   - Le prix
   - Des boutons "Subscribe"/"Acheter" et "Cancel"

3. Cliquez sur **"Subscribe"** ou **"Acheter"**

4. L'achat devrait se faire et vous devriez voir dans le log :
   ```
   ✅ Achat réussi!
   ```

---

## 📱 Que faire ensuite ?

### ✅ Si l'achat fonctionne dans la vue de debug :

Le problème était dans `PremiumPurchaseView`. Dites-moi et je corrigerai cette vue.

### ❌ Si l'achat ne fonctionne toujours pas :

Envoyez-moi une **capture d'écran** de la vue de debug montrant :
- Le statut en haut (nombre de produits)
- Les dernières lignes du log

Je pourrai alors identifier le problème précis.

---

## 💡 Raccourcis rapides

| Action | Raccourci Mac |
|--------|---------------|
| Clean Build | `Cmd + Shift + K` |
| Build & Run | `Cmd + R` |
| Stop | `Cmd + .` |
| Quitter Xcode | `Cmd + Q` |
| Edit Scheme | `Cmd + <` |

---

## ❓ Questions fréquentes

**Q : Je ne vois pas la section "🔧 Outils de Développement"**  
R : Elle n'apparaît qu'en mode DEBUG. Si vous testez sur un appareil réel en mode Release, elle ne sera pas visible.

**Q : Dois-je supprimer cette vue avant de publier sur l'App Store ?**  
R : Non ! Elle est automatiquement cachée grâce à `#if DEBUG`. Vous pouvez la laisser en toute sécurité.

**Q : Les achats fonctionnent dans la vue de debug mais pas dans la vraie vue Premium**  
R : C'est un problème d'interface utilisateur dans `PremiumPurchaseView`. Dites-moi et je corrigerai.

**Q : J'ai 3 produits mais le bouton "Tester l'achat" ne fait rien**  
R : Regardez la console Xcode (en bas). Il y a probablement un message d'erreur. Copiez-le et envoyez-le moi.

---

**Bonne chance ! 🚀**

Si vous êtes bloqué, envoyez-moi simplement une capture d'écran de la vue de debug.

