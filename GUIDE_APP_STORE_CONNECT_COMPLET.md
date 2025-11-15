# 🚀 Guide Complet : App Store Connect & In-App Purchase

## ✅ PHASE 1 : In-App Purchase Activé !

**C'EST FAIT !** ✨

L'entitlement In-App Purchase a été ajouté à votre projet :
```xml
<key>com.apple.developer.in-app-purchase</key>
<true/>
```

**Vérification dans Xcode** :
1. Ouvrez Xcode
2. Sélectionnez la target WheelTrack
3. Onglet "Signing & Capabilities"
4. Vous devriez voir **In-App Purchase** actif (plus de "Waiting to attach")

---

## 🌐 PHASE 2 : Configuration App Store Connect

### **📱 Étape 1 : Créer l'App (5 minutes)**

1. **Allez sur** : https://appstoreconnect.apple.com
2. **My Apps** → **"+"** → **"New App"**
3. **Remplissez** :

```
Platform: iOS
Name: WheelTrack
Primary Language: French (ou English)
Bundle ID: com.Wheel.WheelTrack  ← IMPORTANT !
SKU: wheeltrack-ios
User Access: Full Access
```

4. **Create**

---

### **💳 Étape 2 : Créer les 3 Produits In-App**

#### **🔹 Configuration du Subscription Group**

1. Dans votre app → **Features** → **In-App Purchases**
2. **"+"** → **Auto-Renewable Subscription**
3. **Create New Subscription Group** :
   - Reference Name: `Premium Subscriptions`
   - Create

---

#### **🔹 Produit 1 : Abonnement Mensuel**

**Product ID** : `com.andygrava.wheeltrack.premium.monthly`

**Configuration** :
```
Subscription Duration: 1 Month
Subscription Prices: 
  - France: 4,99 €
  - USA: 4,99 $
  
Localization (Français):
  Display Name: WheelTrack Premium - Mensuel
  Description: Accès Premium mensuel à toutes les fonctionnalités de WheelTrack
  
Localization (English):
  Display Name: WheelTrack Premium - Monthly
  Description: Monthly Premium access to all WheelTrack features

Review Information:
  Screenshot: No (cocher)
```

**Cliquez "Save"**

---

#### **🔹 Produit 2 : Abonnement Annuel**

**Dans le même Subscription Group** → **"+"**

**Product ID** : `com.andygrava.wheeltrack.premium.yearly`

**Configuration** :
```
Subscription Duration: 1 Year
Subscription Prices: 
  - France: 49,99 €
  - USA: 49,99 $
  
Localization (Français):
  Display Name: WheelTrack Premium - Annuel
  Description: Accès Premium annuel à toutes les fonctionnalités - Économisez 18%
  
Localization (English):
  Display Name: WheelTrack Premium - Yearly
  Description: Yearly Premium access to all features - Save 18%

Review Information:
  Screenshot: No (cocher)
```

**Cliquez "Save"**

---

#### **🔹 Produit 3 : Achat à Vie (Lifetime)**

**Retour à In-App Purchases** → **"+"** → **Non-Consumable**

**Product ID** : `com.andygrava.wheeltrack.premium.lifetime`

**Configuration** :
```
Pricing: 
  - France: 79,99 €
  - USA: 79,99 $
  
Localization (Français):
  Display Name: WheelTrack Premium - À Vie
  Description: Accès Premium à vie à toutes les fonctionnalités de WheelTrack
  
Localization (English):
  Display Name: WheelTrack Premium - Lifetime
  Description: Lifetime Premium access to all WheelTrack features

Review Information:
  Screenshot: No (cocher)
```

**Cliquez "Save"**

---

### **✅ Vérification des Produits**

Vos 3 produits doivent avoir le statut :
- **"Ready to Submit"** ✅ → Parfait !
- **"Missing Metadata"** ⚠️ → Complétez les infos manquantes

**Note** : Pas besoin qu'ils soient "Approved" pour tester avec Sandbox !

---

## 📦 PHASE 3 : Créer et Upload un Build

### **Étape 3 : Archive dans Xcode**

1. **Dans Xcode** :
   - Vérifiez que "Any iOS Device" est sélectionné (ou un appareil physique)
   - **Product** → **Archive**
   - Attendez 3-5 minutes

2. **L'Organizer s'ouvre** :
   - Sélectionnez votre archive
   - **"Distribute App"**

3. **Configuration** :
   - Sélectionnez : **App Store Connect**
   - Next
   - Sélectionnez : **Upload**
   - Next
   - Cochez : **Automatically manage signing**
   - Next
   - **Upload** → Attendez 5-10 minutes

### **Étape 4 : Attendre le build dans App Store Connect**

1. **Après 10-30 minutes**, le build apparaît dans :
   - App Store Connect → Votre App → **TestFlight** → **Builds**

2. **Sélectionnez le build** :
   - Section "Export Compliance"
   - Question : "Does your app use encryption?"
   - Répondez : **No** (sauf si vous avez ajouté du chiffrement)
   - Submit

3. **Statut** : Le build passe en **"Ready to Test"** ✅

---

## 🧪 PHASE 4 : Tests Sandbox

### **Étape 5 : Créer un Sandbox Tester**

1. **App Store Connect** → **Users and Access** → **Sandbox Testers**
2. **"+"** (Add Tester)

**Informations du testeur** :
```
Email: test.wheeltrack@icloud.com (exemple - utilisez un email fictif)
Password: Test1234! (ou votre mot de passe)
First Name: Test
Last Name: WheelTrack
Country/Region: France
App Store Territory: France
```

3. **Save**

**⚠️ IMPORTANT** : 
- Utilisez un email qui n'existe PAS déjà comme Apple ID
- Ce compte est UNIQUEMENT pour les tests Sandbox
- Les achats sont GRATUITS avec ce compte

---

### **Étape 6 : Tester sur votre iPhone/iPad**

#### **🔹 Préparation de l'appareil**

1. **Réglages** → **App Store** 
2. Si connecté → **Déconnexion** (Se déconnecter)
3. **NE PAS** vous reconnecter maintenant !

#### **🔹 Installation via TestFlight**

1. **Installez TestFlight** depuis l'App Store (si pas déjà fait)
2. **Ouvrez TestFlight**
3. **Connectez-vous** avec votre compte Apple Developer
4. **WheelTrack** devrait apparaître
5. **Installer** l'app

#### **🔹 Test des achats**

1. **Lancez WheelTrack**
2. **Allez dans** : Paramètres → Passer Premium (ou équivalent)
3. **Sélectionnez** un des produits (ex: Mensuel à 4,99€)
4. **Popup de connexion** :
   - Entrez le **Sandbox Tester** (test.wheeltrack@icloud.com)
   - Entrez le **mot de passe**
5. **Confirmez l'achat** :
   - Message : "Environnement Sandbox" apparaît
   - Cliquez **Acheter**
   - **C'EST GRATUIT** en Sandbox !
6. **Vérification** :
   - Le badge Premium apparaît ✅
   - Les fonctionnalités Premium sont débloquées ✅

#### **🔹 Tester la restauration**

1. **Supprimez l'app** de votre iPhone
2. **Réinstallez-la** via TestFlight
3. **Ouvrez l'app**
4. **Allez dans** Paramètres → Restaurer les achats
5. **Connectez-vous** avec le Sandbox Tester
6. **Le statut Premium** devrait être restauré ✅

---

## 🎯 CHECKLIST COMPLÈTE

### **Configuration App Store Connect**
- [ ] App créée avec Bundle ID `com.Wheel.WheelTrack`
- [ ] Produit 1 créé : `com.andygrava.wheeltrack.premium.monthly` (4,99€)
- [ ] Produit 2 créé : `com.andygrava.wheeltrack.premium.yearly` (49,99€)
- [ ] Produit 3 créé : `com.andygrava.wheeltrack.premium.lifetime` (79,99€)
- [ ] Les 3 produits en statut "Ready to Submit"
- [ ] Build uploadé via Xcode
- [ ] Build visible dans TestFlight
- [ ] Export Compliance complété

### **Tests Sandbox**
- [ ] Sandbox Tester créé
- [ ] App installée via TestFlight
- [ ] Test achat mensuel → Succès
- [ ] Test achat annuel → Succès
- [ ] Test achat lifetime → Succès
- [ ] Test restauration → Succès

### **Vérification fonctionnelle**
- [ ] Badge Premium affiché
- [ ] Fonctionnalités Premium débloquées
- [ ] Pas de crash lors de l'achat
- [ ] Message de succès affiché

---

## ❓ FAQ - Questions Fréquentes

### **Q : Combien de temps pour que les produits apparaissent ?**
R : Instantané à 5 minutes après la création

### **Q : Les produits doivent être "Approved" pour tester ?**
R : **NON !** Le statut "Ready to Submit" suffit pour Sandbox

### **Q : Puis-je tester sans build dans TestFlight ?**
R : **NON** pour les vrais achats. **OUI** localement avec Configuration.storekit (simulation)

### **Q : Les achats Sandbox coûtent-ils de l'argent ?**
R : **NON !** Totalement gratuits, aucun vrai paiement

### **Q : Combien de Sandbox Testers puis-je créer ?**
R : Jusqu'à 100 testeurs

### **Q : Que faire si "Product not found" ?**
R : Vérifiez que les Product IDs sont EXACTEMENT :
- `com.andygrava.wheeltrack.premium.monthly`
- `com.andygrava.wheeltrack.premium.yearly`
- `com.andygrava.wheeltrack.premium.lifetime`

---

## 🚨 ERREURS COURANTES ET SOLUTIONS

### **Erreur : "Cannot connect to iTunes Store"**
**Solution** : 
1. Vérifiez votre connexion internet
2. Déconnectez-vous de l'App Store et reconnectez avec Sandbox
3. Attendez 5 minutes et réessayez

### **Erreur : "Product not available in your country"**
**Solution** :
1. Vérifiez que les prix sont définis pour votre pays
2. Le Sandbox Tester doit avoir le même pays que les prix

### **Erreur : "This Apple ID has not been set up for Sandbox"**
**Solution** :
1. Créez un NOUVEAU Sandbox Tester dans App Store Connect
2. N'utilisez JAMAIS votre vrai Apple ID pour Sandbox

### **Le badge Premium ne s'affiche pas**
**Solution** :
1. Vérifiez que `FreemiumService.isPremium` est bien à `true`
2. Redémarrez l'app
3. Vérifiez les logs dans la console Xcode

---

## 🎉 RÉSULTAT FINAL

Après avoir suivi ce guide :

✅ **In-App Purchase activé** dans Xcode  
✅ **App créée** dans App Store Connect  
✅ **3 produits configurés** et prêts à tester  
✅ **Build uploadé** et disponible dans TestFlight  
✅ **Sandbox configuré** pour les tests  
✅ **Achats testés** et fonctionnels  

**Votre système de paiement est OPÉRATIONNEL ! 🚀**

---

## 📞 BESOIN D'AIDE ?

Si vous bloquez quelque part :
1. Vérifiez la section **Erreurs Courantes** ci-dessus
2. Consultez les logs dans Xcode Console
3. Vérifiez que les Product IDs correspondent exactement
4. Attendez 5-10 minutes (délai de synchronisation)

**Bon courage ! 💪**

