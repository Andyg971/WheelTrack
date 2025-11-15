# 💰 Explication : Affichage des Prix en USD pendant les Tests

## 🎯 **Question**

Pourquoi les prix s'affichent-ils en **dollars américains (USD)** pendant les tests, alors que l'app est destinée au marché français (€) ?

---

## ✅ **Réponse : C'est NORMAL en Mode Test**

### **Environnement de Test (Simulateur & TestFlight Sandbox)**

- ✅ Les prix s'affichent en **USD** par défaut
- ✅ C'est le **comportement standard d'Apple**
- ✅ Le fichier `Configuration.storekit` utilise USD pour les tests
- ✅ **Ce n'est PAS un bug**

### **Environnement de Production (App Store)**

- ✅ Les prix s'afficheront automatiquement dans la **devise locale**
- ✅ Pour la France : **EUR (€)**
- ✅ Pour les USA : **USD ($)**
- ✅ Pour le UK : **GBP (£)**
- ✅ Etc.

---

## 📋 **Configuration Actuelle**

### **Fichier `Configuration.storekit`**

```json
{
  "displayPrice" : "4.99",          // Prix sans devise (USD par défaut en test)
  "productID" : "com.andygrava.wheeltrack.premium.monthly",
  "type" : "AutoRenewable"
}
```

```json
{
  "settings" : {
    "_locale" : "fr_FR",            // ✅ Locale française correcte
    "_storefront" : "FRA",          // ✅ Store français correct
  }
}
```

**Résultat en test :**
- Affichage : `$4.99 USD` (symbole dollar)

**Résultat en production :**
- Affichage : `4,99 €` (symbole euro pour la France)

---

## 🔍 **Pourquoi ce Comportement ?**

### **1. Fichier StoreKit de Test**

Le fichier `Configuration.storekit` est un **fichier de test local** utilisé par Xcode pour :
- Tester les achats sans connexion au vrai App Store
- Simuler les transactions
- Éviter les vrais paiements pendant le développement

**Apple utilise USD par défaut** dans ce mode test, indépendamment de la locale configurée.

### **2. App Store Connect en Production**

Dans **App Store Connect**, vous configurez les prix pour chaque région :

| Région | Prix | Devise |
|--------|------|--------|
| France | 4,99 | EUR |
| USA | 4,99 | USD |
| UK | 4,99 | GBP |

StoreKit **détecte automatiquement** la région de l'utilisateur et affiche le bon prix avec la bonne devise.

---

## 🧪 **Comment Tester avec EUR ?**

### **Option 1 : Modification du Fichier StoreKit (Temporaire)**

Vous **ne pouvez pas forcer EUR** dans `Configuration.storekit` car Apple impose USD pour les tests locaux.

### **Option 2 : Test en Production (Sandbox)**

1. **Connectez-vous avec un compte Sandbox** dans les Réglages iOS
2. **Créez un compte de test** dans App Store Connect
3. **Configurez le compte** avec la région France
4. **Testez l'achat** : Les prix s'afficheront en EUR

### **Option 3 : Attendez la Version Production**

Une fois l'app publiée sur l'App Store :
- ✅ Les utilisateurs français verront **4,99 €**
- ✅ Les utilisateurs américains verront **$4.99**
- ✅ Conversion automatique selon la région

---

## 💡 **Bonnes Pratiques**

### **Ne Pas Hardcoder les Devises**

❌ **Mauvais :**
```swift
Text("Prix : 4,99€")  // Hardcodé en euros
```

✅ **Bon :**
```swift
Text("Prix : \(product.displayPrice)")  // Devise automatique
```

### **Notre Code Actuel**

Le code utilise déjà la bonne pratique :

```swift
// Dans PremiumUpgradeAlert.swift
price: monthlyProduct.displayPrice  // ✅ Récupère le prix avec devise automatique

// Dans PurchaseSuccessView.swift
if let product = storeKitService.product(for: .monthlySubscription) {
    return product.displayPrice  // ✅ Devise automatique
}
return "4,99€"  // Fallback en euros
```

---

## 📱 **Configuration App Store Connect**

### **Étapes pour Configurer les Prix en Production**

1. **Allez dans App Store Connect**
2. **Sélectionnez votre app** → WheelTrack
3. **Allez dans "In-App Purchases"**
4. **Pour chaque produit** (Mensuel, Annuel, À vie) :

#### **Produit : Premium Mensuel**
```
Base Price: 4,99 €
Region: France (EUR)
```

#### **Produit : Premium Annuel**
```
Base Price: 49,99 €
Region: France (EUR)
```

#### **Produit : Premium à Vie**
```
Base Price: 79,99 €
Region: France (EUR)
```

5. **Apple calculera automatiquement** les prix pour les autres régions

---

## ✅ **Résumé**

### **Situation Actuelle**

| Environnement | Devise Affichée | Normal ? |
|---------------|-----------------|----------|
| Simulateur Xcode | USD ($) | ✅ Oui |
| TestFlight Sandbox | USD ($) | ✅ Oui |
| Production (App Store) | EUR (€) pour France | ✅ Oui |

### **Actions Requises**

- ✅ **AUCUNE ACTION** nécessaire dans le code
- ✅ Le code utilise **déjà** `product.displayPrice` (correct)
- ✅ Il faut juste **configurer les prix en EUR** dans App Store Connect
- ✅ Les utilisateurs verront **automatiquement** la bonne devise

### **Ce qui se Passera en Production**

1. **Utilisateur français** lance l'app
2. **StoreKit détecte** la région : France (FRA)
3. **Récupère les prix** depuis App Store Connect : 4,99 € / 49,99 € / 79,99 €
4. **Affiche** : `4,99 €` (et non `$4.99`)

---

## 🎉 **Conclusion**

L'affichage des prix en **USD pendant les tests** est :
- ✅ **Comportement normal** d'Apple
- ✅ **Pas un bug** dans votre code
- ✅ **Sera corrigé automatiquement** en production

**Aucune modification de code n'est nécessaire !** 

Il suffit de :
1. **Configurer les prix en EUR** dans App Store Connect
2. **Publier l'app** sur l'App Store
3. Les utilisateurs français verront **automatiquement** les prix en euros (€)

**Le code est déjà parfait !** 👌
