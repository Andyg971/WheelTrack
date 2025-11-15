# 🔧 Guide de Débogage des Achats In-App

## ✅ Ce que j'ai créé pour vous

J'ai ajouté **une vue de débogage complète** pour tester et diagnostiquer les problèmes avec StoreKit.

### 📱 Comment accéder à l'outil de debug

1. **Lancez votre app** dans le simulateur
2. **Allez dans "Réglages"** (dernier onglet en bas)
3. **Cherchez la section "🔧 Outils de Développement"** (tout en bas)
4. **Cliquez sur "Debug StoreKit"**

> ⚠️ **Note** : Cette section n'apparaît qu'en mode DEBUG (simulateur/développement). Elle sera automatiquement cachée en production.

---

## 🔍 Que fait cet outil de debug ?

### 1. **Statut en temps réel**
- Affiche si StoreKit est en train de charger
- Montre le nombre de produits détectés
- Affiche les erreurs éventuelles

### 2. **Rechargement manuel**
- Bouton bleu "Recharger les produits" pour forcer un nouveau chargement
- Utile si les produits ne se chargent pas au premier essai

### 3. **Liste détaillée des produits**
- Voir exactement quels produits sont chargés
- Affiche : ID, nom, description et prix
- Bouton "Tester l'achat" pour chaque produit

### 4. **Log de débogage**
- Toutes les actions sont enregistrées avec horodatage
- Voir en temps réel ce qui se passe
- Identifier exactement où ça bloque

### 5. **Test API direct**
- Bouton violet "Tester l'API StoreKit"
- Appelle directement l'API StoreKit sans passer par votre service
- Permet de vérifier si le problème vient de la configuration ou du code

---

## 🎯 Comment diagnostiquer le problème

### Scénario 1 : Aucun produit chargé (0 produits)

**Symptôme** : Le compteur "Produits" affiche 0

**Causes possibles** :
1. ❌ Le fichier `Configuration.storekit` n'est pas bien configuré dans le scheme
2. ❌ Les IDs de produits ne correspondent pas
3. ❌ Le simulateur ne détecte pas le fichier .storekit

**Solutions** :
- Cliquez sur "Tester l'API StoreKit" (bouton violet)
- Regardez le log de débogage
- Si le message dit "Aucun produit retourné par l'API", le problème vient de la configuration Xcode

**Pour corriger** :
1. Dans Xcode, allez dans : Product > Scheme > Edit Scheme...
2. Sélectionnez "Run" > Onglet "Options"
3. Dans "StoreKit Configuration", vérifiez que `Configuration.storekit` est bien sélectionné
4. **Fermez complètement l'app** dans le simulateur (arrêtez-la depuis Xcode)
5. **Relancez l'app** (Build & Run)

### Scénario 2 : Produits chargés MAIS l'achat ne fonctionne pas

**Symptôme** : Vous voyez 3 produits affichés, mais cliquer sur "Acheter" ne fait rien

**Causes possibles** :
1. ❌ Le popup StoreKit n'apparaît pas
2. ❌ Une erreur dans le processus d'achat
3. ❌ Un problème de threading (SwiftUI + async)

**Solutions** :
- Cliquez sur "Tester l'achat" dans la vue de debug
- Regardez le log de débogage pour voir les messages
- Cherchez des messages comme :
  - `🛒 Tentative d'achat: wheeltrack_premium_...`
  - `🔄 Début du processus d'achat...`
  - `❌ Achat échoué` ou `✅ Achat réussi!`

### Scénario 3 : Le popup StoreKit apparaît mais l'achat échoue

**Symptôme** : Le popup Apple apparaît mais l'achat échoue après validation

**Causes possibles** :
1. ❌ Problème de vérification de la transaction
2. ❌ Erreur dans `StoreKitService.purchase()`

**Solutions** :
- Regardez la console Xcode (bas de l'écran)
- Cherchez des lignes commençant par `❌ Erreur`
- Copiez le message d'erreur complet et envoyez-le moi

---

## 📊 Interpréter les logs

### Messages normaux (tout va bien) ✅

```
[timestamp] ✅ Vue de debug chargée
[timestamp] 🔄 Tentative de chargement des produits...
[timestamp] ✅ Chargement terminé
[timestamp] 📦 Nombre de produits: 3
[timestamp] 🛒 Tentative d'achat: com.andygrava.wheeltrack.premium.lifetime
[timestamp] 🔄 Début du processus d'achat...
[timestamp] ✅ Achat réussi!
```

### Messages d'erreur (problème à résoudre) ❌

```
[timestamp] ⚠️ PROBLÈME: Aucun produit retourné par l'API
[timestamp] ❌ Erreur API StoreKit: [message d'erreur]
[timestamp] ❌ Achat échoué
```

---

## 🛠️ Actions de dépannage rapide

### Action 1 : Clean Build (Nettoyage complet)

1. Dans Xcode : **Product > Clean Build Folder** (ou Cmd + Shift + K)
2. **Fermez complètement Xcode**
3. **Rouvrez Xcode**
4. **Relancez l'app**

### Action 2 : Réinitialiser le simulateur

1. Dans le simulateur : **Device > Erase All Content and Settings...**
2. Confirmez
3. **Relancez l'app depuis Xcode**

### Action 3 : Vérifier la console Xcode

1. En bas de Xcode, cliquez sur l'icône avec les lignes de texte (Console)
2. Cherchez des messages commençant par :
   - `🔄` (chargement)
   - `✅` (succès)
   - `❌` (erreur)
   - `⚠️` (avertissement)

---

## 📝 Ce que je dois savoir pour vous aider

Si le problème persiste après avoir utilisé la vue de debug, envoyez-moi :

1. **Le nombre de produits chargés** (affiché en haut de la vue de debug)
2. **Les 10 dernières lignes du log de débogage** (dans la section "Log de débogage")
3. **Les messages de la console Xcode** (copiez tout ce qui contient "StoreKit" ou "❌")
4. **Ce qui se passe exactement** quand vous cliquez sur "Tester l'achat"
   - Rien du tout ?
   - Un popup apparaît ?
   - Un message d'erreur ?

---

## ⚡ Résumé rapide

1. **Lancez l'app**
2. **Allez dans Réglages > 🔧 Outils de Développement > Debug StoreKit**
3. **Cliquez sur "Tester l'API StoreKit"** (bouton violet)
4. **Regardez le log** et dites-moi ce que vous voyez
5. **Testez un achat** avec le bouton vert sous un produit
6. **Notez ce qui se passe** et envoyez-moi les informations

---

## 🎓 Information technique

Cette vue de debug est uniquement visible en mode DEBUG grâce à la directive `#if DEBUG`. 

Cela signifie qu'elle :
- ✅ Apparaît dans le simulateur
- ✅ Apparaît sur un appareil de test en mode debug
- ❌ N'apparaîtra PAS dans la version App Store
- ❌ N'apparaîtra PAS dans TestFlight (sauf si compilé en debug)

Vous pouvez la laisser dans le code en toute sécurité ! 🔒

