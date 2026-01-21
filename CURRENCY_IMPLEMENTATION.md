# Implémentation du système de devise par défaut (USD/EUR/GBP)

## 📋 Objectif
Définir la devise par défaut selon la région de l'utilisateur :
- **États-Unis (US)** → USD ($)
- **Royaume-Uni (GB)** → GBP (£)
- **Pays européens** → EUR (€)
- **Autres pays** → USD ($)

**IMPORTANT** : Ne jamais écraser un choix utilisateur déjà enregistré.

## ✅ Implémentation

### 1. Fichier utilitaire : `CurrencyHelper.swift`

**Emplacement** : `WheelTrack/Utilities/CurrencyHelper.swift`

**Fonctions principales** :
```swift
// Retourne le code devise par défaut selon la région
static func defaultCurrencyCode(for locale: Locale = .current) -> String

// Retourne le symbole de la devise ($, €, £)
static func currencySymbol(for currencyCode: String) -> String

// Formate un montant avec la devise appropriée
static func format(amount: Double, currencyCode: String, locale: Locale = .current) -> String
```

**Liste des pays européens** :
```swift
static let europeanRegionCodes: Set<String> = [
    "FR", "DE", "ES", "IT", "PT", "BE", "NL", "LU", "IE", "AT",
    "FI", "SE", "DK", "NO", "CH", "PL", "CZ", "SK", "HU", "RO",
    "BG", "GR", "HR", "SI", "EE", "LV", "LT", "CY", "MT", "IS", "LI"
]
```

**Logique de détection** :
```swift
let regionCode = getRegionCode(from: locale)

// États-Unis → USD
if regionCode == "US" {
    return "USD"
}

// Royaume-Uni → GBP
if regionCode == "GB" {
    return "GBP"
}

// Pays européens → EUR
if let region = regionCode, europeanRegionCodes.contains(region) {
    return "EUR"
}

// Tous les autres pays → USD par défaut
return "USD"
```

### 2. Intégration dans `LocalizationService.swift`

**Modification** : Lignes 47-53

Ajout de l'initialisation automatique de la devise au premier lancement :

```swift
// ✅ NOUVEAU : Initialiser la devise selon la région (UNIQUEMENT si pas déjà définie)
if UserDefaults.standard.object(forKey: "currency_symbol") == nil {
    let defaultCurrencyCode = CurrencyHelper.defaultCurrencyCode()
    let symbol = CurrencyHelper.currencySymbol(for: defaultCurrencyCode)
    UserDefaults.standard.set(symbol, forKey: "currency_symbol")
    debugLog("💰 Devise initialisée: \(defaultCurrencyCode) (\(symbol)) (région: \(Locale.current.regionCode ?? "unknown"))")
}
```

**Comportement** :
- ✅ S'exécute **uniquement** si `currency_symbol` n'existe pas dans UserDefaults
- ✅ Ne touche **jamais** à un choix utilisateur existant
- ✅ Stocke le symbole ($ ou €) dans `@AppStorage("currency_symbol")`

### 3. Détection de région iOS 16+ / iOS < 16

```swift
private static func getRegionCode(from locale: Locale) -> String? {
    if #available(iOS 16, *) {
        return locale.region?.identifier  // iOS 16+
    } else {
        return locale.regionCode          // iOS < 16
    }
}
```

## 🎯 Cas d'usage

### Nouveau utilisateur américain
1. Installe l'app sur un iPhone avec région US
2. Au premier lancement, `LocalizationService` détecte `Locale.current.regionCode == "US"`
3. Initialise `@AppStorage("currency_symbol") = "$"`
4. Code devise = "USD"
5. Tous les montants s'affichent en dollars ($)

### Nouveau utilisateur français
1. Installe l'app sur un iPhone avec région FR
2. Au premier lancement, `LocalizationService` détecte `Locale.current.regionCode == "FR"`
3. FR est dans `europeanRegionCodes` → EUR
4. Initialise `@AppStorage("currency_symbol") = "€"`
5. Code devise = "EUR"
6. Tous les montants s'affichent en euros (€)

### Nouveau utilisateur britannique
1. Installe l'app sur un iPhone avec région GB (Royaume-Uni)
2. Au premier lancement, `LocalizationService` détecte `Locale.current.regionCode == "GB"`
3. GB → GBP
4. Initialise `@AppStorage("currency_symbol") = "£"`
5. Code devise = "GBP"
6. Tous les montants s'affichent en livres (£)

### Nouveau utilisateur canadien
1. Installe l'app sur un iPhone avec région CA (Canada)
2. Au premier lancement, `LocalizationService` détecte `Locale.current.regionCode == "CA"`
3. CA n'est ni US, ni GB, ni dans `europeanRegionCodes` → USD
4. Initialise `@AppStorage("currency_symbol") = "$"`
5. Code devise = "USD"
6. Tous les montants s'affichent en dollars ($)

### Utilisateur existant
1. A déjà une préférence `currency_symbol` sauvegardée
2. La logique d'initialisation est ignorée (`if == nil`)
3. Son choix est **respecté** ✅

## 📊 Tableau des devises par région

| Région | Code | Devise | Symbole |
|--------|------|--------|---------|
| 🇺🇸 États-Unis | US | USD | $ |
| 🇬🇧 Royaume-Uni | GB | GBP | £ |
| 🇫🇷 France | FR | EUR | € |
| 🇩🇪 Allemagne | DE | EUR | € |
| 🇪🇸 Espagne | ES | EUR | € |
| 🇮🇹 Italie | IT | EUR | € |
| 🇵🇹 Portugal | PT | EUR | € |
| 🇧🇪 Belgique | BE | EUR | € |
| 🇳🇱 Pays-Bas | NL | EUR | € |
| 🇨🇦 Canada | CA | USD* | $ |
| 🇯🇵 Japon | JP | USD* | $ |
| ... tous les autres | * | USD | $ |

*Par défaut, mais l'utilisateur peut changer manuellement vers leur devise locale (CAD, JPY, etc.)

## 🔄 Intégration existante

L'app utilise déjà `@AppStorage("currency_symbol")` dans :
- `GeneralSettingsView.swift` : Sélection manuelle de la devise
- `SettingsView.swift` : Affichage de la devise actuelle
- Toutes les vues affichant des montants

**Cette implémentation est 100% compatible** avec le système existant.

## 💡 Utilisation de CurrencyHelper

### Formater un montant
```swift
let amount: Double = 150.50
let symbol = UserDefaults.standard.string(forKey: "currency_symbol") ?? "$"

// Méthode 1: Utiliser le symbole directement
let formatted = String(format: "%.2f %@", amount, symbol)
// Résultat: "150.50 $" ou "150.50 €"

// Méthode 2: Utiliser NumberFormatter (plus robuste)
let currencyCode = symbol == "€" ? "EUR" : "USD"
let formatted = CurrencyHelper.format(amount: amount, currencyCode: currencyCode)
// Résultat: "$150.50" ou "150,50 €" (selon locale)
```

### Obtenir le symbole depuis le code
```swift
let code = "EUR"
let symbol = CurrencyHelper.currencySymbol(for: code)
// Résultat: "€"
```

## ✨ Avantages

✅ **Détection intelligente** : US → USD, Europe → EUR, autres → USD
✅ **Respecte les choix** : Ne touche jamais aux préférences existantes
✅ **Testable** : Injection de Locale en paramètre
✅ **Extensible** : Facile d'ajouter d'autres devises (GBP, JPY, CAD, etc.)
✅ **Non-invasif** : S'intègre au système existant sans modification
✅ **iOS 16+ compatible** : Utilise `Locale.region` avec fallback iOS 15

## 🔍 Tests manuels possibles

Pour tester, vous pouvez modifier la région dans Simulateur iOS :
1. Settings → General → Language & Region
2. Changer "Region" vers US, FR, CA, etc.
3. Supprimer l'app et réinstaller
4. Vérifier que la devise par défaut correspond

### Exemples de tests
- **US** → Doit afficher $ par défaut
- **FR** → Doit afficher € par défaut
- **DE** → Doit afficher € par défaut
- **CA** → Doit afficher $ par défaut
- **Changer manuellement** → Doit respecter le choix

## 🚀 Compilation

```bash
cd "/Users/gravaandy/Desktop/AppMaker Studio/WheelTrack"
xcodebuild build -project WheelTrack.xcodeproj -scheme WheelTrack
```

**Résultat** : ✅ BUILD SUCCEEDED

---

**Date** : 2026-01-03
**Version** : 1.0