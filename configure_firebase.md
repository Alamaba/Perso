# 🔥 Configuration Firebase - Guide Étape par Étape

## 📋 Prérequis
- Compte Google
- Node.js installé sur votre machine
- Flutter SDK configuré

## 🚀 Étapes de Configuration

### 1. Installer Firebase CLI
```bash
npm install -g firebase-tools
```

### 2. Se connecter à Firebase
```bash
firebase login
```
Une page web s'ouvrira pour vous connecter avec votre compte Google.

### 3. Créer un projet Firebase
1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Cliquez sur "Ajouter un projet"
3. Nommez votre projet (ex: "gestion-dettes-perso")
4. Désactivez Google Analytics (optionnel pour ce projet)
5. Cliquez sur "Créer le projet"

### 4. Configurer l'authentification
1. Dans Firebase Console, allez dans **Authentication**
2. Cliquez sur **Commencer**
3. Allez dans l'onglet **Sign-in method**
4. Activez **Google** :
   - Cliquez sur Google
   - Activez le fournisseur
   - Ajoutez votre email comme email d'assistance
   - Cliquez sur **Enregistrer**

### 5. Configurer Firestore Database
1. Dans Firebase Console, allez dans **Firestore Database**
2. Cliquez sur **Créer une base de données**
3. Choisissez **Commencer en mode test** (pour le développement)
4. Sélectionnez une région proche de vous
5. Cliquez sur **Terminé**

### 6. Configurer FlutterFire (IMPORTANT)
Dans votre terminal, dans le dossier du projet :

```bash
flutterfire configure
```

Cette commande va :
- Lister vos projets Firebase
- Vous demander de sélectionner le projet créé
- Configurer automatiquement Android et iOS
- Générer le fichier `firebase_options.dart` avec les vraies clés

### 7. Configuration Android (Automatique avec FlutterFire)
FlutterFire configure automatiquement :
- Le fichier `google-services.json`
- Les modifications dans `android/app/build.gradle`
- Les permissions nécessaires

### 8. Vérifier la configuration
Après `flutterfire configure`, votre fichier `lib/firebase_options.dart` devrait contenir de vraies clés API au lieu des placeholders.

## ✅ Test de la Configuration

### Lancer l'application
```bash
flutter run
```

### Vérifier les logs
Si Firebase est bien configuré, vous devriez voir dans les logs :
```
✅ Firebase initialisé avec succès
✅ Services GetX initialisés avec succès
```

## 🔧 Dépannage

### Erreur "Firebase not initialized"
- Vérifiez que `flutterfire configure` a été exécuté
- Vérifiez que le fichier `firebase_options.dart` contient de vraies clés

### Erreur Google Sign-In
- Vérifiez que Google Sign-In est activé dans Firebase Console
- Pour Android, assurez-vous que les SHA-1/SHA-256 sont configurés

### Obtenir les SHA-1/SHA-256 pour Android
```bash
cd android
./gradlew signingReport
```

Copiez les SHA-1 et SHA-256 et ajoutez-les dans :
Firebase Console > Paramètres du projet > Vos applications > Android > Empreintes de certificat

## 📱 Configuration Complète

Une fois Firebase configuré, votre application aura :
- ✅ Authentification Google fonctionnelle
- ✅ Stockage cloud avec Firestore
- ✅ Synchronisation automatique des données
- ✅ Écran de démarrage (Splash Screen)
- ✅ Navigation complète entre les écrans

## 🎯 Prochaines Étapes

1. Configurez Firebase avec ce guide
2. Lancez l'application avec `flutter run`
3. Testez la connexion Google
4. Ajoutez vos premières dettes/crédits
5. Testez l'export PDF/Excel

---

**💡 Conseil** : Gardez ce guide ouvert pendant la configuration pour suivre chaque étape ! 