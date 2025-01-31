# KakaoFarmer - Application mobile de commerce et formation

## Description

KakaoFarmer est une application mobile développée avec Flutter qui connecte les producteurs de cacao aux acheteurs tout en offrant des ressources éducatives pour améliorer les pratiques agricoles. Cette plateforme tout-en-un permet aux cacaoculteurs de commercialiser leurs produits et d'accéder à des formations professionnelles.

## Fonctionnalités principales

### Module E-commerce
- Création de profils vendeurs pour les producteurs de cacao
- Mise en ligne des lots de cacao avec photos et descriptions détaillées
- Système de notation de la qualité du cacao
- Suivi des commandes en temps réel

### Module Formation
- Vidéos tutorielles sur les bonnes pratiques agricoles
- Conseils de formation

## Prérequis techniques

- Flutter SDK >= 3.0.0
- Dart >= 2.17.0
- Android SDK >= 21
- FastApi (Python) pour le backend

## Installation

1. Cloner le dépôt :
```bash
git clone https://github.com/EikouJ/Kakao-farmer-app.git
```

2. Installer les dépendances :
```bash
cd Kakao-farmer-app
flutter pub get
```

3. Lancer l'application :
```bash
flutter run
```

## Structure du projet

```
lib/
├── api/           # Services API
├── models/        # Modèles de données
├── screens/       # Écrans de l'application
├── services/      # Services dans l'application
├── utils/         # Utilitaires
├── widgets/       # Widgets réutilisables
└── main.dart      # Point d'entrée de l'application
```

## Tests

Exécuter les tests unitaires :
```bash
flutter test
```

Exécuter les tests d'intégration :
```bash
flutter drive --target=test_driver/app.dart
```

## Déploiement

### Android
1. Générer une clé de signature
2. Configurer le fichier key.properties
3. Construire l'APK :
```bash
flutter build apk --release
```

## Contribution

1. Fork le projet
2. Créer une branche pour votre fonctionnalité
3. Committer vos changements
4. Pousser vers la branche
5. Créer une Pull Request

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## Contact

- Email : support@KakaoFarmer.com
- Site web : www.KakaoFarmer.com
- Twitter : @KakaoFarmer

## Remerciements

- Équipe de développement Flutter
- Communauté des producteurs de cacao
- Partenaires techniques et financiers
