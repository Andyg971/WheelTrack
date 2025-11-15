# 🚀 GUIDE COMPLET : Configuration App Store Connect pour WheelTrack

## ✅ CE QUI A ÉTÉ FAIT

Votre application est maintenant **prête pour la production** :
- ✅ Configuration de test supprimée
- ✅ Interface d'achat professionnelle
- ✅ Code optimisé pour App Store Connect
- ✅ Les 3 produits prêts à être créés

---

## 📦 VOS 3 PRODUITS À CRÉER

| # | Nom | Product ID | Prix | Type |
|---|-----|-----------|------|------|
| 1 | Premium Mensuel | `com.andygrava.wheeltrack.premium.monthly` | 4,99€ | Abonnement auto-renouvelable |
| 2 | Premium Annuel | `com.andygrava.wheeltrack.premium.yearly` | 49,99€ | Abonnement auto-renouvelable |
| 3 | Premium à Vie | `com.andygrava.wheeltrack.premium.lifetime` | 79,99€ | Achat unique (Non-Consommable) |

⚠️ **IMPORTANT** : Utilisez **EXACTEMENT** ces Product IDs, ils sont déjà codés dans l'app !

---

## 🔐 PRÉREQUIS

Avant de commencer, vous devez avoir :

- ✅ Un compte Apple Developer actif (99€/an)
- ✅ Votre app créée sur App Store Connect
- ✅ Accès à App Store Connect (https://appstoreconnect.apple.com)

---

## 📋 ÉTAPE 1 : Créer l'App sur App Store Connect

### 1.1 Connexion
1. Allez sur : https://appstoreconnect.apple.com
2. Connectez-vous avec votre Apple ID de développeur

### 1.2 Créer l'app (si pas déjà fait)
1. Cliquez sur **"Mes Apps"**
2. Cliquez sur le **+** en haut à gauche
3. Sélectionnez **"Nouvelle app"**
4. Remplissez :
   - **Plateformes** : iOS
   - **Nom** : WheelTrack
   - **Langue principale** : Français
   - **Bundle ID** : `com.Wheel.WheelTrack` (doit correspondre à votre Xcode)
   - **SKU** : WheelTrack-001 (ou ce que vous voulez)
   - **Accès utilisateur** : Accès complet
5. Cliquez **"Créer"**

---

## 💰 ÉTAPE 2 : Créer les 3 Produits In-App

### 2.1 Accéder à la section In-App Purchases

1. Dans App Store Connect, ouvrez votre app **WheelTrack**
2. Dans le menu de gauche, cliquez sur **"Fonctionnalités"**
3. Cliquez sur **"Achats intégrés"**
4. Cliquez sur le **+** pour ajouter un produit

---

### 2.2 PRODUIT 1 : Premium Mensuel (Abonnement)

#### Étape 1 : Type de produit
- Sélectionnez : **"Abonnement automatiquement renouvelable"**
- Cliquez **"Créer"**

#### Étape 2 : Groupe d'abonnements
- Si c'est votre premier abonnement, créez un groupe :
  - **Nom du groupe** : `Premium Subscriptions`
  - **Nom de référence** : `WheelTrack Premium`
- Cliquez **"Créer"**

#### Étape 3 : Informations du produit
- **Nom de référence** : `Premium Monthly`
- **ID du produit** : `com.andygrava.wheeltrack.premium.monthly`  
  ⚠️ **IMPORTANT** : Copiez-collez EXACTEMENT cet ID !
- **Groupe d'abonnements** : Sélectionnez le groupe créé

#### Étape 4 : Durée de l'abonnement
- Sélectionnez : **1 mois**

#### Étape 5 : Prix de l'abonnement
- Cliquez sur **"Ajouter un prix"**
- Sélectionnez : **4,99€** (ou 4,99$ selon votre région)
- Pays/régions : **Tous** (ou sélectionnez manuellement)
- Date de début : **Immédiatement**
- Cliquez **"Suivant"** puis **"Créer"**

#### Étape 6 : Localisation
- Cliquez sur **"+"** dans la section Localisation
- **Langue** : Français (France)
- **Nom affiché** : `WheelTrack Premium - Mensuel`
- **Description** : `Accès Premium mensuel à toutes les fonctionnalités de WheelTrack`
- Cliquez **"Enregistrer"**

- Ajoutez aussi l'anglais :
  - **Langue** : Anglais (États-Unis)
  - **Nom affiché** : `WheelTrack Premium - Monthly`
  - **Description** : `Monthly Premium access to all WheelTrack features`

#### Étape 7 : Capture d'écran (optionnel pour la révision)
- Vous pouvez ajouter une capture d'écran de la vue d'achat
- Ou passer cette étape pour l'instant

#### Étape 8 : Informations de révision
- **Notes de révision** : `Abonnement mensuel Premium pour WheelTrack`
- Cliquez **"Enregistrer"**

✅ **Premier produit créé !**

---

### 2.3 PRODUIT 2 : Premium Annuel (Abonnement)

Répétez les étapes ci-dessus avec ces informations :

- **Nom de référence** : `Premium Yearly`
- **ID du produit** : `com.andygrava.wheeltrack.premium.yearly`  
  ⚠️ **COPIEZ-COLLEZ EXACTEMENT**
- **Groupe d'abonnements** : Même groupe que le mensuel
- **Durée** : **1 an**
- **Prix** : **49,99€**
- **Nom affiché (FR)** : `WheelTrack Premium - Annuel`
- **Description (FR)** : `Accès Premium annuel à toutes les fonctionnalités de WheelTrack - Économisez 18%`
- **Nom affiché (EN)** : `WheelTrack Premium - Yearly`
- **Description (EN)** : `Yearly Premium access to all WheelTrack features - Save 18%`

✅ **Deuxième produit créé !**

---

### 2.4 PRODUIT 3 : Premium à Vie (Achat unique)

#### Étape 1 : Type de produit
- Retournez à **"Achats intégrés"**
- Cliquez sur **+**
- Sélectionnez : **"Non-consommable"**
- Cliquez **"Créer"**

#### Étape 2 : Informations du produit
- **Nom de référence** : `Premium Lifetime`
- **ID du produit** : `com.andygrava.wheeltrack.premium.lifetime`  
  ⚠️ **COPIEZ-COLLEZ EXACTEMENT**

#### Étape 3 : Prix
- Cliquez sur **"Ajouter un prix"**
- Sélectionnez : **79,99€**
- Pays/régions : **Tous**
- Cliquez **"Suivant"** puis **"Créer"**

#### Étape 4 : Localisation
- **Langue** : Français (France)
- **Nom affiché** : `WheelTrack Premium - À Vie`
- **Description** : `Accès Premium à vie à toutes les fonctionnalités de WheelTrack`

- **Langue** : Anglais (États-Unis)
- **Nom affiché** : `WheelTrack Premium - Lifetime`
- **Description** : `Lifetime Premium access to all WheelTrack features`

#### Étape 5 : Informations de révision
- **Notes de révision** : `Achat unique Premium à vie pour WheelTrack`
- Cliquez **"Enregistrer"**

✅ **Troisième produit créé !**

---

## 🎯 ÉTAPE 3 : Vérifier les Produits

### 3.1 Liste des produits
Retournez à **"Achats intégrés"**. Vous devriez voir :

| Nom de référence | ID du produit | Type | État |
|------------------|---------------|------|------|
| Premium Monthly | com.andygrava.wheeltrack.premium.monthly | Abonnement | Prêt à soumettre |
| Premium Yearly | com.andygrava.wheeltrack.premium.yearly | Abonnement | Prêt à soumettre |
| Premium Lifetime | com.andygrava.wheeltrack.premium.lifetime | Non-consommable | Prêt à soumettre |

### 3.2 Vérification des IDs
⚠️ **VÉRIFIEZ** que les IDs sont **EXACTEMENT** :
- `com.andygrava.wheeltrack.premium.monthly`
- `com.andygrava.wheeltrack.premium.yearly`
- `com.andygrava.wheeltrack.premium.lifetime`

Si un ID est différent, **supprimez le produit et recréez-le** avec le bon ID.

---

## 📱 ÉTAPE 4 : Configurer votre App pour la Production

### 4.1 Dans Xcode : Vérifier le Bundle ID
1. Ouvrez votre projet WheelTrack dans Xcode
2. Cliquez sur le projet (icône bleue en haut)
3. Sélectionnez la cible **"WheelTrack"**
4. Onglet **"Signing & Capabilities"**
5. Vérifiez que **Bundle Identifier** est : `com.Wheel.WheelTrack`
6. Vérifiez que **Team** est sélectionné (votre compte développeur)

### 4.2 Vérifier les Capabilities
Dans **"Signing & Capabilities"** :
- ✅ **In-App Purchase** doit être activé
- ✅ **iCloud** (si vous utilisez CloudKit)

Si **In-App Purchase** n'est pas présent :
1. Cliquez sur **"+ Capability"**
2. Cherchez **"In-App Purchase"**
3. Ajoutez-le

### 4.3 Build pour Production
1. En haut de Xcode, sélectionnez : **"Any iOS Device (arm64)"**
2. Menu : **Product → Archive**
3. Attendez que le build se termine (quelques minutes)
4. La fenêtre **"Archives"** s'ouvre automatiquement

### 4.4 Uploader sur App Store Connect
1. Sélectionnez l'archive créée
2. Cliquez sur **"Distribute App"**
3. Sélectionnez : **"App Store Connect"**
4. Cliquez **"Next"**
5. Sélectionnez : **"Upload"**
6. Cliquez **"Next"**
7. Laissez les options par défaut
8. Cliquez **"Upload"**
9. Attendez que l'upload se termine (peut prendre 10-30 minutes)

---

## 🧪 ÉTAPE 5 : Tester avec TestFlight

### 5.1 Attendre le traitement
1. Retournez sur App Store Connect
2. Ouvrez votre app **WheelTrack**
3. Cliquez sur **"TestFlight"** dans le menu de gauche
4. Attendez que votre build apparaisse (10-30 minutes)
5. État : **"En cours de traitement"** → **"Prêt à tester"**

### 5.2 Créer un groupe de testeurs
1. Cliquez sur **"Testeurs internes"**
2. Ajoutez-vous comme testeur
3. Sélectionnez le build à tester
4. Vous recevrez un email avec un lien TestFlight

### 5.3 Installer TestFlight
1. Sur votre iPhone, installez **"TestFlight"** depuis l'App Store
2. Cliquez sur le lien dans l'email
3. Installez WheelTrack via TestFlight

### 5.4 Tester les achats
1. Lancez WheelTrack depuis TestFlight
2. Allez dans **Réglages**
3. Trouvez la section Premium
4. Cliquez pour voir les options d'achat
5. Vous devriez voir les **3 produits** avec leurs prix ! 🎉

⚠��� **NOTE** : En TestFlight, les achats sont en **mode Sandbox** (gratuits, pour tests uniquement)

---

## 📝 ÉTAPE 6 : Soumettre pour Révision

### 6.1 Préparer la soumission
1. Retournez sur App Store Connect
2. Ouvrez votre app **WheelTrack**
3. Cliquez sur **"Distribution de l'app"**
4. Sélectionnez la version (ex: 1.0)

### 6.2 Informations de l'app
Remplissez toutes les sections requises :
- **Captures d'écran** (iPhone 6,7" obligatoire)
- **Description**
- **Mots-clés**
- **URL de support**
- **Coordonnées marketing** (optionnel)

### 6.3 Build
- Sélectionnez le build uploadé précédemment

### 6.4 Informations sur les achats intégrés
- Les 3 produits créés apparaîtront automatiquement
- Vérifiez qu'ils sont bien listés

### 6.5 Soumettre
1. Cliquez sur **"Soumettre pour révision"**
2. Répondez au questionnaire
3. Confirmez la soumission

**Délai de révision** : 24-48 heures en général

---

## ✅ CHECKLIST FINALE

Avant de soumettre, vérifiez que :

### App Store Connect
- [  ] Les 3 produits sont créés avec les bons IDs
- [  ] Les prix sont corrects (4,99€, 49,99€, 79,99€)
- [  ] Les localisations FR et EN sont remplies
- [  ] Le groupe d'abonnements est configuré
- [  ] L'app est créée sur App Store Connect

### Xcode
- [  ] Bundle ID correspond : `com.Wheel.WheelTrack`
- [  ] In-App Purchase capability activée
- [  ] Team sélectionné (compte développeur)
- [  ] Build archive créé et uploadé

### Tests
- [  ] App testée sur TestFlight
- [  ] Les 3 produits s'affichent
- [  ] L'achat test fonctionne (Sandbox)
- [  ] Restauration des achats fonctionne

---

## 🎉 APRÈS LA VALIDATION

Une fois validé par Apple (24-48h) :

1. ✅ Votre app sera disponible sur l'App Store
2. ✅ Les achats in-app seront fonctionnels
3. ✅ Les utilisateurs pourront acheter Premium
4. ✅ Vous recevrez les revenus (70% pour vous, 30% pour Apple)

---

## 🆘 EN CAS DE PROBLÈME

### Les produits ne s'affichent pas dans l'app

**Solutions** :
1. Vérifiez que les Product IDs sont EXACTEMENT les mêmes
2. Attendez 24h après création (propagation Apple)
3. Vérifiez que In-App Purchase capability est activée
4. Testez en Sandbox avec un compte de test

### Achat refusé en TestFlight

**Solutions** :
1. Créez un compte Sandbox dans App Store Connect :
   - Utilisateurs et accès → Sandbox → Testeurs
   - Ajoutez un email de test
2. Déconnectez-vous de l'App Store sur votre iPhone
3. Dans l'app, tentez un achat
4. Connectez-vous avec le compte Sandbox

### Produit en "Attente de révision"

**Normal** : Les produits in-app sont révisés avec l'app.
Attendez la validation de l'app (24-48h).

---

## 📊 SUIVI DES REVENUS

### App Store Connect → Ventes et tendances
- Consultez les ventes quotidiennes
- Analysez les abonnements actifs
- Suivez les désabonnements

### Paiements
- Apple paie mensuellement (30 jours après la fin du mois fiscal)
- Virement bancaire sur le compte configuré
- Rapports financiers disponibles

---

## 🎯 RÉCAPITULATIF DES PRODUCT IDs

À copier-coller lors de la création des produits :

```
com.andygrava.wheeltrack.premium.monthly
com.andygrava.wheeltrack.premium.yearly
com.andygrava.wheeltrack.premium.lifetime
```

⚠️ **NE MODIFIEZ JAMAIS ces IDs** - ils sont codés dans l'app !

---

## 💡 CONSEILS

1. **Testez TOUJOURS en TestFlight** avant de publier
2. **Gardez les mêmes Product IDs** entre développement et production
3. **Documentez vos prix** (si vous changez, créez de nouveaux produits)
4. **Répondez aux avis** App Store (améliore le classement)
5. **Analysez les statistiques** pour optimiser vos prix

---

**Votre app est maintenant prête pour l'App Store !** 🚀

Bonne chance avec WheelTrack Premium ! 🎉
