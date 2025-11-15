#!/bin/bash

# Script de vérification de la configuration de signature
echo "🔍 Vérification de la configuration de signature..."

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "WheelTrack.xcodeproj/project.pbxproj" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis le répertoire racine du projet WheelTrack"
    exit 1
fi

echo ""
echo "📋 Configuration actuelle de signature:"
echo "======================================"

# Afficher les paramètres de signature
grep -A 3 -B 1 "CODE_SIGN" WheelTrack.xcodeproj/project.pbxproj

echo ""
echo "🔍 Vérifications:"
echo "================="

# Vérifier la cohérence
debug_identity=$(grep -A 10 "Debug.*=" WheelTrack.xcodeproj/project.pbxproj | grep "CODE_SIGN_IDENTITY" | head -1 | sed 's/.*= "\(.*\)";/\1/')
release_identity=$(grep -A 10 "Release.*=" WheelTrack.xcodeproj/project.pbxproj | grep "CODE_SIGN_IDENTITY" | head -1 | sed 's/.*= "\(.*\)";/\1/')

echo "Debug identity:   $debug_identity"
echo "Release identity: $release_identity"

if [ "$debug_identity" = "$release_identity" ]; then
    echo "✅ Configuration uniforme: $debug_identity"
else
    echo "❌ Configuration incohérente!"
    echo "   Debug:   $debug_identity"
    echo "   Release: $release_identity"
fi

# Vérifier le style de signature
debug_style=$(grep -A 10 "Debug.*=" WheelTrack.xcodeproj/project.pbxproj | grep "CODE_SIGN_STYLE" | head -1 | sed 's/.*= \(.*\);/\1/')
release_style=$(grep -A 10 "Release.*=" WheelTrack.xcodeproj/project.pbxproj | grep "CODE_SIGN_STYLE" | head -1 | sed 's/.*= \(.*\);/\1/')

echo ""
echo "Debug style:   $debug_style"
echo "Release style: $release_style"

if [ "$debug_style" = "Automatic" ] && [ "$release_style" = "Automatic" ]; then
    echo "✅ Signature automatique activée"
else
    echo "⚠️  Configuration de signature manuelle détectée"
fi

# Vérifier l'équipe de développement
team=$(grep "DEVELOPMENT_TEAM" WheelTrack.xcodeproj/project.pbxproj | head -1 | sed 's/.*= \(.*\);/\1/')
echo ""
echo "Équipe de développement: $team"

if [ -n "$team" ] && [ "$team" != "" ]; then
    echo "✅ Équipe configurée"
else
    echo "⚠️  Aucune équipe configurée"
fi

echo ""
echo "🎯 Résumé:"
echo "=========="

if [ "$debug_identity" = "$release_identity" ] && [ "$debug_style" = "Automatic" ]; then
    echo "✅ Configuration correcte pour la signature automatique"
    echo "✅ Prêt pour l'archive"
else
    echo "⚠️  Configuration nécessite des ajustements"
    echo "💡 Consultez le guide SOLUTION_SIGNATURE_CODE.md"
fi

echo ""
echo "📖 Prochaines étapes:"
echo "1. Ouvrez le projet dans Xcode"
echo "2. Vérifiez les paramètres dans Signing & Capabilities"
echo "3. Testez l'archive: Product → Archive"

