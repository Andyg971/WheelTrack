#!/bin/bash

# ═══════════════════════════════════════════════════════
# Script de nettoyage des Provisioning Profiles
# WheelTrack - Fix In-App Purchase Provisioning
# ═══════════════════════════════════════════════════════

echo "🧹 Nettoyage des Provisioning Profiles..."
echo ""

# Nettoyer DerivedData
echo "📦 Suppression de DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo "✅ DerivedData nettoyé"
echo ""

# Nettoyer les anciens profils de provisioning
echo "🗑️ Suppression des anciens profils..."
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*
echo "✅ Profils supprimés"
echo ""

# Nettoyer le cache Xcode
echo "💾 Nettoyage du cache Xcode..."
rm -rf ~/Library/Caches/com.apple.dt.Xcode/*
echo "✅ Cache nettoyé"
echo ""

echo "═══════════════════════════════════════════════════════"
echo "✅ NETTOYAGE TERMINÉ !"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "📝 Prochaines étapes :"
echo "1. Ouvrez Xcode"
echo "2. Xcode → Settings → Accounts"
echo "3. Cliquez sur 'Download Manual Profiles'"
echo "4. Retournez dans votre projet"
echo "5. Signing & Capabilities → Décochez/Recochez 'Automatically manage signing'"
echo "6. Compilez (Cmd + B)"
echo ""
echo "🎯 L'erreur devrait être résolue !"


