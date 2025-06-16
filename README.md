# 💰 Perso

Une application Flutter moderne et élégante pour gérer vos dettes et crédits personnels avec synchronisation cloud et sécurité biométrique.

## 📱 Aperçu

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase">
  <img src="https://img.shields.io/badge/GetX-9C27B0?style=for-the-badge&logo=flutter&logoColor=white" alt="GetX">
  <img src="https://img.shields.io/badge/Hive-FF6B35?style=for-the-badge&logo=flutter&logoColor=white" alt="Hive">
</div>

### ✨ Fonctionnalités principales

- 🔐 **Authentification sécurisée** avec Google Sign-In
- 💾 **Double stockage** : Local (Hive) + Cloud (Firestore)
- 🔒 **Sécurité avancée** : PIN + Biométrie (empreinte/Face ID)
- 📊 **Interface intuitive** avec onglets séparés "Je dois" / "J'ai prêté"
- 🔍 **Recherche intelligente** par nom, montant ou notes
- 📧 **Notifications automatiques** pour les rappels de remboursement
- 📄 **Export professionnel** en PDF et Excel
- 📈 **Statistiques détaillées** avec graphiques
- 🔄 **Synchronisation automatique** entre appareils
- 🎨 **Design moderne** avec animations fluides

## 🚀 Technologies utilisées

### Framework & Architecture
- **Flutter** - Framework UI multiplateforme
- **GetX** - Gestion d'état réactive et navigation
- **Architecture MVVM** - Séparation claire des responsabilités

### Stockage & Synchronisation
- **Hive** - Base de données locale rapide et légère
- **Cloud Firestore** - Base de données NoSQL en temps réel
- **Synchronisation bidirectionnelle** automatique

### Authentification & Sécurité
- **Firebase Auth** - Authentification robuste
- **Google Sign-In** - Connexion simplifiée
- **Local Auth** - Biométrie (empreinte digitale, Face ID)
- **Crypto** - Hachage sécurisé des codes PIN

### Fonctionnalités avancées
- **Flutter Local Notifications** - Rappels intelligents
- **Syncfusion Flutter PDF** - Génération de rapports PDF
- **Excel** - Export de données structurées
- **Shared Preferences** - Paramètres utilisateur persistants

## 📋 Prérequis

- Flutter SDK (≥ 3.0.0)
- Dart SDK (≥ 3.0.0)
- Android Studio / VS Code
- Compte Firebase configuré

## 🛠️ Installation

1. **Cloner le repository**
```bash
git clone https://github.com/votre-username/perso.git
cd perso
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Générer les adaptateurs Hive**
```bash
flutter packages pub run build_runner build
```

4. **Configuration Firebase**
   - Créer un projet Firebase
   - Ajouter votre application Android/iOS
   - Télécharger `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)
   - Placer les fichiers dans les dossiers appropriés

5. **Lancer l'application**
```bash
flutter run
```

## 📱 Structure de l'application

```
lib/
├── controllers/          # Contrôleurs GetX
│   └── debt_credit_controller.dart
├── models/              # Modèles de données
│   ├── debt_credit_item.dart
│   └── debt_credit_item.g.dart
├── screens/             # Écrans de l'application
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── auth_screen.dart
│   ├── pin_setup_screen.dart
│   ├── settings_screen.dart
│   └── statistics_screen.dart
├── services/            # Services métier
│   ├── auth_service.dart
│   ├── local_storage_service.dart
│   ├── firestore_service.dart
│   ├── notification_service.dart
│   ├── export_service.dart
│   └── security_service.dart
├── widgets/             # Composants réutilisables
│   ├── debt_credit_list.dart
│   ├── search_bar_widget.dart
│   └── add_item_dialog.dart
└── main.dart           # Point d'entrée
```

## 🎯 Fonctionnalités détaillées

### 💳 Gestion des dettes et crédits
- ➕ Ajout rapide avec formulaire intelligent
- ✏️ Modification en temps réel
- ✅ Marquage "Remboursé" avec historique
- 🗑️ Suppression sécurisée avec confirmation
- 📝 Notes personnalisées et rappels programmés

### 🔍 Recherche et filtres
- 🔎 Recherche instantanée multi-critères
- 👥 Filtrage par personne
- 💰 Filtrage par montant
- 📅 Filtrage par période
- ✅ Affichage des éléments remboursés/en cours

### 📊 Statistiques et analyses
- 📈 Graphiques circulaires interactifs
- 📋 Répartition par personnes
- 💹 Évolution temporelle
- 🎯 Moyennes et totaux
- 📉 Tendances de remboursement

### 🔒 Sécurité multicouche
- 🖼️ Authentification biométrique
- 🔢 Code PIN personnalisé
- 🔐 Chiffrement des données sensibles
- 🚪 Verrouillage automatique
- 🧹 Nettoyage lors de la déconnexion

### 📄 Export et rapports
- 📑 **PDF professionnel** avec logo et mise en forme
- 📊 **Excel structuré** avec formules automatiques
- 📈 **Rapports combinés** (dettes + crédits)
- 📧 **Partage direct** via email/applications
- 🎨 **Formatage monétaire** (FDJ - Francs Djiboutiens)

## ⚙️ Configuration

### Firebase
1. Console Firebase → Créer un projet
2. Activer Authentication (Google Sign-In)
3. Configurer Cloud Firestore
4. Télécharger les fichiers de configuration

### Notifications
L'application gère automatiquement :
- 🔔 Rappels de remboursement
- ⏰ Notifications programmées
- 📱 Badges d'application
- 🎵 Sons personnalisés

## 🛡️ Sécurité

- **Authentification Firebase** - Connexion sécurisée
- **Hachage SHA-256** - Protection des codes PIN
- **Biométrie locale** - Empreinte/Face ID
- **Chiffrement des données** - Protection en local et cloud
- **Validation côté client** - Prévention des erreurs

## 🎨 Design

- **Material Design 3** - Interface moderne et familière
- **Animations fluides** - Transitions naturelles
- **Mode sombre** - Confort visuel (à venir)
- **Responsive** - Adaptation à tous les écrans
- **Accessibilité** - Support des lecteurs d'écran

## 🚀 Roadmap

- [ ] 🌙 Mode sombre
- [ ] 🌍 Multi-langues (FR/EN/AR)
- [ ] 💱 Multi-devises
- [ ] 🔄 Sauvegarde automatique
- [ ] 📊 Plus de graphiques
- [ ] 🤝 Partage entre utilisateurs
- [ ] 📷 Photos des reçus
- [ ] 🎯 Objectifs de remboursement

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commit vos changements (`git commit -m 'Ajout nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Ouvrir une Pull Request

## 📞 Support

- 📧 Email : votre-email@exemple.com
- 🐛 Issues : [GitHub Issues](https://github.com/votre-username/perso/issues)
- 💬 Discussions : [GitHub Discussions](https://github.com/votre-username/perso/discussions)

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🙏 Remerciements

- Flutter et l'équipe Dart
- Firebase pour l'infrastructure
- GetX pour la gestion d'état
- Hive pour le stockage local
- La communauté Flutter pour l'inspiration

---

<div align="center">
  <p>Fait avec ❤️ avec Flutter</p>
  <p>⭐ N'hésitez pas à donner une étoile si ce projet vous aide !</p>
</div>
