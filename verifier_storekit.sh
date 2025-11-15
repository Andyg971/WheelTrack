#!/bin/bash

# Script de vérification StoreKit pour WheelTrack
# Ce script vérifie que tout est bien configuré

echo "═══════════════════════════════════════════════════════════════"
echo "  🔍 VÉRIFICATION CONFIGURATION STOREKIT - WheelTrack"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Compteur de problèmes
ERRORS=0

# 1. Vérifier que le fichier Configuration.storekit existe
echo "1️⃣  Vérification du fichier Configuration.storekit..."
if [ -f "WheelTrack/Configuration.storekit" ]; then
    echo -e "   ${GREEN}✅ Fichier trouvé${NC}"
    LINES=$(wc -l < "WheelTrack/Configuration.storekit")
    echo "   📄 Taille: $LINES lignes"
else
    echo -e "   ${RED}❌ ERREUR: Fichier non trouvé${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 2. Vérifier les 3 Product IDs dans le fichier
echo "2️⃣  Vérification des 3 Product IDs..."


PRODUCT_IDS=("com.andygrava.wheeltrack.premium.monthly" "com.andygrava.wheeltrack.premium.yearly" "com.andygrava.wheeltrack.premium.lifetime")
PRODUCT_NAMES=("Premium Mensuel" "Premium Annuel" "Premium à Vie")

for i in "${!PRODUCT_IDS[@]}"; do
    PRODUCT_ID="${PRODUCT_IDS[$i]}"
    PRODUCT_NAME="${PRODUCT_NAMES[$i]}"
    
    if grep -q "$PRODUCT_ID" "WheelTrack/Configuration.storekit"; then
        echo -e "   ${GREEN}✅ $PRODUCT_NAME ($PRODUCT_ID)${NC}"
    else
        echo -e "   ${RED}❌ ERREUR: $PRODUCT_NAME manquant${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done
echo ""

# 3. Vérifier le scheme
echo "3️⃣  Vérification du scheme Xcode..."
SCHEME_FILE="WheelTrack.xcodeproj/xcshareddata/xcschemes/WheelTrack.xcscheme"
if [ -f "$SCHEME_FILE" ]; then
    if grep -q "Configuration.storekit" "$SCHEME_FILE"; then
        echo -e "   ${GREEN}✅ Scheme configuré pour StoreKit${NC}"
        
        # Vérifier le chemin exact
        STOREKIT_PATH=$(grep -o 'identifier = "[^"]*Configuration.storekit"' "$SCHEME_FILE" | sed 's/identifier = "//;s/"//')
        echo "   📍 Chemin: $STOREKIT_PATH"
    else
        echo -e "   ${RED}❌ ERREUR: StoreKit non configuré dans le scheme${NC}"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "   ${RED}❌ ERREUR: Fichier scheme non trouvé${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 4. Vérifier StoreKitService.swift
echo "4️⃣  Vérification de StoreKitService.swift..."
if [ -f "WheelTrack/Services/StoreKitService.swift" ]; then
    echo -e "   ${GREEN}✅ Fichier trouvé${NC}"
    
    # Vérifier les Product IDs dans le code
    for PRODUCT_ID in "${PRODUCT_IDS[@]}"; do
        if grep -q "$PRODUCT_ID" "WheelTrack/Services/StoreKitService.swift"; then
            echo -e "   ${GREEN}✅ $PRODUCT_ID dans le code${NC}"
        else
            echo -e "   ${RED}❌ $PRODUCT_ID manquant du code${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    done
else
    echo -e "   ${RED}❌ ERREUR: StoreKitService.swift non trouvé${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# 5. Vérifier le cache DerivedData
echo "5️⃣  Vérification du cache DerivedData..."
DERIVED_DATA="$HOME/Library/Developer/Xcode/DerivedData"
WHEELTRACK_CACHE=$(find "$DERIVED_DATA" -maxdepth 1 -name "WheelTrack-*" 2>/dev/null)

if [ -z "$WHEELTRACK_CACHE" ]; then
    echo -e "   ${GREEN}✅ Pas de cache (parfait après nettoyage)${NC}"
else
    echo -e "   ${BLUE}⚠️  Cache DerivedData présent${NC}"
    echo "   💡 Conseil: Nettoyez-le avec 'rm -rf ~/Library/Developer/Xcode/DerivedData/WheelTrack-*'"
fi
echo ""

# Résumé final
echo "═══════════════════════════════════════════════════════════════"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ TOUT EST CONFIGURÉ CORRECTEMENT !${NC}"
    echo ""
    echo "📱 Prochaines étapes:"
    echo "   1. Ouvrez Xcode"
    echo "   2. Lancez l'app (Cmd + R)"
    echo "   3. Allez dans: Réglages → 🔧 Outils de Développement → Debug StoreKit"
    echo "   4. Cliquez sur 'Tester l'API StoreKit'"
    echo "   5. Vous devriez voir: '3 produits trouvés' ✅"
else
    echo -e "${RED}❌ $ERRORS PROBLÈME(S) DÉTECTÉ(S)${NC}"
    echo ""
    echo "📖 Lisez le fichier CORRECTIONS_APPLIQUEES.md pour plus d'aide"
fi
echo "═══════════════════════════════════════════════════════════════"
