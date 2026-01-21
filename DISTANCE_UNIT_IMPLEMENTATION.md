# Implémentation du système d'unités de distance (miles/km)

## 📋 Objectif
Utiliser **miles** par défaut UNIQUEMENT pour les utilisateurs US et GB, **kilomètres** pour le reste du monde.

## ✅ Implémentation

### 1. Fichier utilitaire : `DistanceUnitHelper.swift`

**Emplacement** : `WheelTrack/Utilities/DistanceUnitHelper.swift`

**Fonctions principales** :
- `defaultDistanceUnit(for locale:)` : Retourne `.miles` pour US/GB, `.kilometers` pour les autres
- `convert(meters:to:)` : Convertit des mètres en km ou miles
- `format(meters:unit:decimals:)` : Formate une distance avec son unité

**Formules de conversion** :
```swift
kilometers = meters / 1000.0
miles = meters / 1609.344
```

**Détection de région** :
```swift
iOS 16+: locale.region?.identifier
iOS < 16: locale.regionCode (fallback)
```

### 2. Intégration dans `LocalizationService.swift`

**Modification** : Ligne 55-60

Ajout de l'initialisation automatique de l'unité de distance au premier lancement :

```swift
// ✅ NOUVEAU : Initialiser l'unité de distance selon la région
if UserDefaults.standard.object(forKey: "distance_unit") == nil {
    let defaultUnit = DistanceUnitHelper.defaultDistanceUnit()
    UserDefaults.standard.set(defaultUnit.rawValue, forKey: "distance_unit")
    debugLog("📏 Unité de distance initialisée: \(defaultUnit.rawValue)")
}
```

**Comportement** :
- ✅ N'écrase JAMAIS un choix utilisateur déjà enregistré
- ✅ S'exécute uniquement au premier lancement
- ✅ Stocke "km" ou "miles" dans `@AppStorage("distance_unit")`

### 3. Tests unitaires : `DistanceUnitHelperTests.swift`

**Emplacement** : `WheelTrackTests/DistanceUnitHelperTests.swift`

**Tests couverts** :
1. ✅ `testUS_ShouldReturnMiles()` : Région US → miles
2. ✅ `testGB_ShouldReturnMiles()` : Région GB → miles
3. ✅ `testFR_ShouldReturnKilometers()` : Région FR → km
4. ✅ `testDE_ShouldReturnKilometers()` : Région DE → km
5. ✅ `testCA_ShouldReturnKilometers()` : Région CA (Canada) → km
6. ✅ `testConvert_1000Meters_To_Kilometers()` : 1000m = 1km
7. ✅ `testConvert_1609_Meters_To_Miles()` : 1609.344m = 1 mile
8. ✅ `testFormat_Kilometers()` : Formatage "15.5 km"
9. ✅ `testFormat_Miles()` : Formatage "9.6 mi"

**Exécution manuelle** :
```swift
DistanceUnitHelperExample.runExamples()
```

## 🎯 Cas d'usage

### Nouveau utilisateur US
1. Installe l'app
2. Au premier lancement, `LocalizationService` détecte `Locale.current.regionCode == "US"`
3. Initialise `@AppStorage("distance_unit") = "miles"`
4. Toutes les distances s'affichent en miles

### Nouveau utilisateur français
1. Installe l'app
2. Au premier lancement, `LocalizationService` détecte `Locale.current.regionCode == "FR"`
3. Initialise `@AppStorage("distance_unit") = "km"`
4. Toutes les distances s'affichent en kilomètres

### Utilisateur existant
1. A déjà une préférence `distance_unit` sauvegardée
2. La logique d'initialisation est ignorée (`if == nil`)
3. Son choix est respecté ✅

## 📊 Pays supportés

| Région | Code | Unité par défaut |
|--------|------|------------------|
| 🇺🇸 États-Unis | US | **miles** |
| 🇬🇧 Royaume-Uni | GB | **miles** |
| 🇫🇷 France | FR | kilometers |
| 🇩🇪 Allemagne | DE | kilometers |
| 🇨🇦 Canada | CA | kilometers |
| 🇪🇸 Espagne | ES | kilometers |
| 🇮🇹 Italie | IT | kilometers |
| 🇯🇵 Japon | JP | kilometers |
| ... tous les autres | * | kilometers |

## 🔄 Intégration existante

L'app utilise déjà `@AppStorage("distance_unit")` dans :
- `GeneralSettingsView.swift` : Picker pour changer l'unité
- `SettingsView.swift` : Affichage de l'unité actuelle
- `UserProfile.swift` : Modèle de données
- `CloudKitPreferencesService.swift` : Synchronisation iCloud

**Cette implémentation est 100% compatible** avec le système existant.

## ✨ Avantages

✅ **Code minimal** : 1 fichier utilitaire + 3 lignes dans LocalizationService
✅ **Testable** : Injection de Locale en paramètre
✅ **Non-invasif** : Respecte les choix utilisateurs existants
✅ **Standards iOS** : Utilise `Locale.region` (iOS 16+) avec fallback
✅ **Précis** : Miles UNIQUEMENT pour US/GB, comme demandé

## 📝 Notes techniques

### Pourquoi ne pas utiliser `Locale.usesMetricSystem` ?
❌ `Locale.usesMetricSystem` retourne `false` pour plusieurs pays qui utilisent pourtant les kilomètres (ex: Liberia, Myanmar)

✅ Notre solution cible explicitement **US et GB** pour garantir miles, tout le reste en km

### iOS 16+ vs iOS < 16
```swift
if #available(iOS 16, *) {
    return locale.region?.identifier  // iOS 16+
} else {
    return locale.regionCode          // Fallback iOS 15
}
```

## 🚀 Compilation

```bash
cd "/Users/gravaandy/Desktop/AppMaker Studio/WheelTrack"
xcodebuild build -project WheelTrack.xcodeproj -scheme WheelTrack
```

**Résultat** : ✅ BUILD SUCCEEDED

---

**Date** : 2026-01-03
**Version** : 1.0