#!/bin/bash

# Script pour corriger la configuration de signature de code
# Résout le conflit entre Apple Development et Apple Distribution

echo "🔧 Correction de la configuration de signature de code..."

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "WheelTrack.xcodeproj/project.pbxproj" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis le répertoire racine du projet WheelTrack"
    exit 1
fi

# Sauvegarder le fichier de projet
cp WheelTrack.xcodeproj/project.pbxproj WheelTrack.xcodeproj/project.pbxproj.backup
echo "✅ Sauvegarde créée: project.pbxproj.backup"

# Afficher la configuration actuelle
echo ""
echo "📋 Configuration actuelle:"
grep -A 2 -B 2 "CODE_SIGN_IDENTITY" WheelTrack.xcodeproj/project.pbxproj

echo ""
echo "🔧 Application des corrections..."

# Option 1: Forcer la signature automatique pour les deux configurations
# Cette approche permet à Xcode de gérer automatiquement les certificats

# Pour Debug: Garder Apple Development
# Pour Release: Changer vers Apple Development temporairement, puis laisser Xcode gérer

# Créer une version temporaire avec Apple Development pour les deux
sed -i '' 's/CODE_SIGN_IDENTITY = "Apple Distribution";/CODE_SIGN_IDENTITY = "Apple Development";/g' WheelTrack.xcodeproj/project.pbxproj

echo "✅ Configuration mise à jour pour utiliser Apple Development partout"
echo "ℹ️  Xcode utilisera automatiquement le bon certificat selon le contexte"

echo ""
echo "📋 Nouvelle configuration:"
grep -A 2 -B 2 "CODE_SIGN_IDENTITY" WheelTrack.xcodeproj/project.pbxproj

echo ""
echo "🎯 Prochaines étapes:"
echo "1. Ouvrez le projet dans Xcode"
echo "2. Allez dans les paramètres du projet (WheelTrack target)"
echo "3. Dans l'onglet 'Signing & Capabilities'"
echo "4. Vérifiez que 'Automatically manage signing' est coché"
echo "5. Sélectionnez votre équipe de développement"
echo "6. Pour l'archive, Xcode utilisera automatiquement le certificat de distribution"

echo ""
echo "✅ Correction terminée!"
echo "💡 Si le problème persiste, utilisez l'option 2 (signature manuelle)"

