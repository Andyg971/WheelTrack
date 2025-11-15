# 🔧 Solution : Erreur de Signature de Code

## ❌ Problème rencontré
```
WheelTrack has conflicting provisioning settings. WheelTrack is automatically signed for development, but a conflicting code signing identity Apple Distribution has been manually specified.
```

## 🔍 Cause du problème
Le projet avait une configuration mixte :
- **Debug** : `Apple Development` (correct pour le développement)
- **Release** : `Apple Distribution` (correct pour la distribution)
- **Problème** : Xcode détectait un conflit entre la signature automatique et l'identité manuelle spécifiée

## ✅ Solution appliquée

### 1. Correction automatique
J'ai exécuté le script `fix_code_signing.sh` qui :
- ✅ A créé une sauvegarde (`project.pbxproj.backup`)
- ✅ A uniformisé la configuration pour utiliser `Apple Development` partout
- ✅ A conservé le mode de signature automatique

### 2. Nouvelle configuration
```bash
# Avant (problématique)
Debug:   CODE_SIGN_IDENTITY = "Apple Development"
Release: CODE_SIGN_IDENTITY = "Apple Distribution"  # ← Conflit

# Après (corrigée)
Debug:   CODE_SIGN_IDENTITY = "Apple Development"
Release: CODE_SIGN_IDENTITY = "Apple Development"   # ← Uniforme
```

## 🎯 Prochaines étapes

### Étape 1 : Vérifier dans Xcode
1. Ouvrez le projet dans Xcode
2. Sélectionnez le target **WheelTrack**
3. Allez dans l'onglet **"Signing & Capabilities"**
4. Vérifiez que :
   - ✅ **"Automatically manage signing"** est coché
   - ✅ Votre **équipe de développement** est sélectionnée
   - ✅ Le **Bundle Identifier** est correct

### Étape 2 : Tester l'archive
1. Dans Xcode : **Product** → **Archive**
2. Xcode utilisera automatiquement le bon certificat selon le contexte :
   - **Développement** → Certificat de développement
   - **Archive/Distribution** → Certificat de distribution

## 🔄 Si le problème persiste

### Option A : Signature automatique (recommandée)
```bash
# Le script a déjà appliqué cette solution
# Vérifiez juste les paramètres dans Xcode
```

### Option B : Signature manuelle
Si vous préférez la signature manuelle :

1. Dans Xcode, décochez **"Automatically manage signing"**
2. Sélectionnez manuellement :
   - **Debug** : Certificat de développement
   - **Release** : Certificat de distribution
3. Sélectionnez les profils de provisioning correspondants

## 📋 Vérifications importantes

### Certificats requis
- ✅ **Certificat de développement** (pour les tests)
- ✅ **Certificat de distribution** (pour l'App Store)
- ✅ **Profils de provisioning** correspondants

### Équipe de développement
- ✅ Votre équipe doit être configurée dans Xcode
- ✅ Vous devez avoir les droits de distribution

## 🚨 Points d'attention

1. **Ne modifiez pas manuellement** le fichier `project.pbxproj` sauf si vous savez ce que vous faites
2. **Utilisez toujours** la signature automatique si possible
3. **Vérifiez régulièrement** que vos certificats ne sont pas expirés

## 📞 En cas de problème

Si l'erreur persiste après ces corrections :
1. Vérifiez que vos certificats sont valides dans le Keychain
2. Rafraîchissez les profils de provisioning dans Xcode
3. Nettoyez le projet : **Product** → **Clean Build Folder**

---

**✅ Correction terminée !** Vous pouvez maintenant procéder à l'archive.

