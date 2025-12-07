# Application de Gestion des Factures et Garanties

Une application mobile Flutter permettant de centraliser, organiser et suivre vos factures et garanties de produits. Ne perdez plus jamais une garantie ou ratez une date d'expiration !

## Fonctionnalités

### 📄 Gestion des Factures
- Ajouter, modifier et supprimer des factures
- Enregistrer les informations essentielles :
  - Nom du produit
  - Magasin
  - Montant
  - Date d'achat
  - Numéro de facture
  - Photo de la facture
  - Notes personnelles

### 🛡️ Gestion des Garanties
- Suivi des garanties avec dates d'expiration
- Calcul automatique de la date d'expiration basé sur la durée
- Alertes visuelles pour les garanties qui expirent bientôt :
  - 🔴 Rouge : Garantie expirée
  - 🟠 Orange : Expire dans moins de 7 jours
  - 🟡 Jaune : Expire dans moins de 30 jours
  - 🟢 Vert : Encore valide
- Notifications automatiques :
  - 7 jours avant expiration
  - 1 jour avant expiration
  - Le jour de l'expiration

### 📊 Tableau de bord
- Vue d'ensemble de vos factures et garanties
- Liste des garanties qui expirent bientôt
- Accès rapide aux factures récentes

## Installation

### Prérequis
- Flutter SDK (version 3.10.1 ou supérieure)
- Android Studio / Xcode pour le développement mobile
- Un appareil Android/iOS ou un émulateur

### Étapes d'installation

1. **Cloner ou naviguer vers le projet**
   ```bash
   cd test_zak_flutter
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Lancer l'application**
   ```bash
   flutter run
   ```

## Structure du projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── models/                   # Modèles de données
│   ├── invoice.dart         # Modèle Facture
│   └── warranty.dart        # Modèle Garantie
├── database/                 # Gestion de la base de données
│   └── database_helper.dart # Helper SQLite
├── services/                 # Services
│   └── notification_service.dart # Service de notifications
└── screens/                  # Écrans de l'application
    ├── home_screen.dart              # Écran d'accueil
    ├── invoices_list_screen.dart     # Liste des factures
    ├── warranties_list_screen.dart   # Liste des garanties
    ├── add_invoice_screen.dart       # Ajout/Modification facture
    ├── add_warranty_screen.dart      # Ajout/Modification garantie
    ├── invoice_detail_screen.dart    # Détails d'une facture
    └── warranty_detail_screen.dart   # Détails d'une garantie
```

## Utilisation

### Ajouter une facture
1. Accédez à l'onglet "Factures"
2. Appuyez sur le bouton "+"
3. Remplissez les informations (nom du produit obligatoire)
4. Optionnellement, ajoutez une photo de la facture
5. Enregistrez

### Ajouter une garantie
1. Accédez à l'onglet "Garanties"
2. Appuyez sur le bouton "+"
3. Remplissez les informations :
   - Nom du produit (obligatoire)
   - Date d'achat
   - Durée en mois
4. La date d'expiration sera calculée automatiquement
5. Optionnellement, ajoutez une photo de la garantie
6. Enregistrez

### Consulter les détails
- Appuyez sur une facture ou garantie dans la liste pour voir tous les détails
- Utilisez le bouton d'édition pour modifier
- Glissez vers la gauche pour supprimer

## Technologies utilisées

- **Flutter** : Framework de développement multiplateforme
- **SQLite (sqflite)** : Base de données locale
- **Image Picker** : Sélection de photos depuis la galerie
- **Flutter Local Notifications** : Notifications locales
- **Intl** : Formatage des dates et nombres
- **Flutter Slidable** : Actions de glissement pour supprimer

## Permissions requises

### Android
- `READ_EXTERNAL_STORAGE` : Pour accéder aux photos
- `WRITE_EXTERNAL_STORAGE` : Pour sauvegarder les photos
- `CAMERA` : Pour prendre des photos (optionnel)
- `POST_NOTIFICATIONS` : Pour les notifications
- `SCHEDULE_EXACT_ALARM` : Pour les notifications programmées

### iOS
Les permissions seront demandées automatiquement lors de l'utilisation.

## Base de données

L'application utilise SQLite pour stocker localement toutes les données. Les tables créées sont :
- `invoices` : Stocke toutes les factures
- `warranties` : Stocke toutes les garanties

## Améliorations futures possibles

- [ ] Recherche et filtres avancés
- [ ] Export des données (PDF, CSV)
- [ ] Synchronisation cloud
- [ ] Scanner de codes-barres pour ajouter des produits
- [ ] Catégories de produits
- [ ] Statistiques et graphiques
- [ ] Mode sombre
- [ ] Support multilingue

## Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une pull request.

## Licence

Ce projet est un projet personnel pour la gestion des factures et garanties.
