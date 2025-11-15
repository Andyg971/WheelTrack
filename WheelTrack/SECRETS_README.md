# Configuration des secrets de l'application

## 📋 Prérequis

Pour compiler et exécuter l'application, vous devez créer un fichier `Secrets.plist` contenant vos clés API.

## 🔧 Configuration

### 1. Créer le fichier Secrets.plist

1. Dupliquez le fichier `Secrets.sample.plist`
2. Renommez-le en `Secrets.plist`
3. Remplacez les valeurs par vos vraies clés API

### 2. Structure du fichier

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>GOOGLE_PLACES_API_KEY</key>
	<string>VOTRE_VRAIE_CLE_API_ICI</string>
</dict>
</plist>
```

### 3. Obtenir une clé Google Places API

1. Allez sur [Google Cloud Console](https://console.cloud.google.com)
2. Créez un nouveau projet ou sélectionnez un projet existant
3. Activez l'API "Places API" (classique, pas "New")
4. Créez des identifiants → Clé API
5. Configurez les restrictions :
   - **Application restrictions** : "Aucune" (pour les appels REST depuis iOS)
   - **API restrictions** : Cochez uniquement "Places API"
6. Copiez la clé et collez-la dans `Secrets.plist`

## 🔒 Sécurité

- **Ne committez JAMAIS** le fichier `Secrets.plist` dans Git
- Le fichier est déjà ignoré dans `.gitignore`
- Utilisez toujours `Secrets.sample.plist` comme template pour les autres développeurs

## 💰 Coûts et quotas

- Google offre 200 USD de crédit gratuit par mois
- Environ 4 000 recherches d'horaires gratuites par mois
- L'application utilise un cache CloudKit partagé pour réduire les appels API
- Cache local de 24h par appareil
- Configurez des alertes budgétaires dans Google Cloud Console

## ❓ Problèmes courants

### "Clé API Google Places non configurée"

- Vérifiez que `Secrets.plist` existe dans le dossier WheelTrack/
- Vérifiez que la clé n'est pas vide
- Assurez-vous que le fichier est bien ajouté à la target iOS dans Xcode

### Erreur 403 "This API key is not authorized"

- Vérifiez que "Places API" est activée dans Google Cloud Console
- Attendez 1-5 minutes après la configuration de la clé
- Vérifiez les restrictions de la clé (aucune restriction d'app pour REST)

### "PlaceHoursCache" CloudKit error

- Normal si iCloud n'est pas configuré
- L'app fonctionne sans CloudKit, elle utilisera uniquement Google API
- Pour activer CloudKit : Signing & Capabilities → iCloud → CloudKit

