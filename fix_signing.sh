#!/bin/bash

# 🔧 Script automatique pour résoudre les problèmes de signature
# Ce script nettoie les caches et profils Xcode

echo "🔧 Début de la réparation de la signature automatique..."
echo ""

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Étape 1 : Suppression des profils de provisioning
echo "${YELLOW}📦 Étape 1/4 : Suppression des profils de provisioning...${NC}"
if [ -d ~/Library/MobileDevice/Provisioning\ Profiles ]; then
    rm -rf ~/Library/MobileDevice/Provisioning\ Profiles
    echo "${GREEN}✅ Profils supprimés${NC}"
else
    echo "${YELLOW}ℹ️  Aucun profil à supprimer${NC}"
fi
echo ""

# Étape 2 : Suppression du cache DerivedData
echo "${YELLOW}📦 Étape 2/4 : Suppression du cache DerivedData...${NC}"
if [ -d ~/Library/Developer/Xcode/DerivedData ]; then
    rm -rf ~/Library/Developer/Xcode/DerivedData
    echo "${GREEN}✅ Cache supprimé${NC}"
else
    echo "${YELLOW}ℹ️  Aucun cache à supprimer${NC}"
fi
echo ""

# Étape 3 : Nettoyage du projet
echo "${YELLOW}📦 Étape 3/4 : Nettoyage du projet Xcode...${NC}"
PROJECT_PATH="/Volumes/Extreme SSD/Développement App/WheelTrack"
cd "$PROJECT_PATH"

if xcodebuild clean -project WheelTrack.xcodeproj -scheme WheelTrack > /dev/null 2>&1; then
    echo "${GREEN}✅ Projet nettoyé${NC}"
else
    echo "${RED}⚠️  Impossible de nettoyer le projet (normal si Xcode est fermé)${NC}"
fi
echo ""

# Étape 4 : Instructions finales
echo "${YELLOW}📦 Étape 4/4 : Prochaines étapes manuelles${NC}"
echo ""
echo "${GREEN}✅ Nettoyage terminé !${NC}"
echo ""
echo "📝 ${YELLOW}Maintenant, fais ceci dans Xcode :${NC}"
echo ""
echo "1. Ouvre Xcode → Settings → Accounts"
echo "2. Sélectionne ton compte Apple"
echo "3. Clique sur 'Download Manual Profiles'"
echo "4. Retourne dans ton projet"
echo "5. Va dans Signing & Capabilities"
echo "6. Désactive puis réactive 'Automatically manage signing'"
echo ""
echo "${YELLOW}📌 Si l'erreur persiste :${NC}"
echo "   → Vérifie que tu as créé l'App ID sur developer.apple.com"
echo "   → Attends 24h après la signature des accords"
echo "   → Consulte le fichier FIX_SIGNING_GUIDE.md pour plus de détails"
echo ""
echo "${GREEN}🎉 Script terminé !${NC}"

