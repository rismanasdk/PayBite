#  Paybite - E-Commerce & Complaint Management System

A modern Flutter mobile application for online food ordering with integrated complaint management and admin dashboard.

## Features

### User Features
-  **Google Authentication** - Secure login via Google
-  **Product Browsing** - Browse food items with image and details
-  **Shopping Cart** - Add/remove products before checkout
-  **Checkout** - Purchase products with order tracking
-  **Order History** - View all past transactions
-  **Complaint System** - Report issues with image evidence
-  **Session Management** - Auto-logout on inactivity

### Admin Features
-  **Dashboard** - Overview of sales, orders, and complaints
-  **Product Management** - Add, edit, delete food items
-  **Order Management** - Track and update order status
-  **Complaint Resolution** - Manage and respond to complaints
-  **User Management** - View user information and activity

##  Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Authentication, Firestore, Cloud Storage)
- **Image Storage**: Cloudinary
- **State Management**: Streams & FutureBuilder
- **Platform**: Android, iOS, Web, Linux, Windows, macOS

##  Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
└── src/
    ├── assets/              # Images, icons
    ├── config/              # Cloudinary config
    ├── features/            # Feature modules
    │   ├── auth/
    │   ├── home/
    │   ├── checkout/
    │   ├── complaint/
    │   ├── history/
    │   └── admin/
    ├── models/              # Data models
    │   ├── product.dart
    │   ├── order.dart
    │   └── complaint.dart
    ├── services/            # Firebase & utilities
    │   ├── firebase_service.dart
    │   ├── auth_service.dart
    │   └── session_manager.dart
    └── utils/               # Helper utilities
```

##  Getting Started

### Prerequisites
- Flutter SDK (latest)
- Firebase account
- Cloudinary account
- Google OAuth credentials

### Installation

1. **Clone repository**
```bash
git clone https://github.com/rismanasdk/paybite.git
cd paybite
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
- Create Firebase project at [Firebase Console](https://console.firebase.google.com)
- Download `google-services.json` (Android) and place in `android/app/`
- Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`
- Generate `lib/firebase_options.dart` using FlutterFire CLI
- Change Content `web/index.html.example` on line 33

4. **Configure Cloudinary** (optional for image upload)
- Create account at [Cloudinary](https://cloudinary.com)
- Update credentials in `lib/src/config/cloudinary_config.dart`

5. **Configure Firebase Rules**
```bash
# Deploy Firestore security rules
firebase deploy --only firestore:rules
```

6. **Run the app**
```bash
flutter run
```

##  Firestore Security Rules

The app uses role-based access control (RBAC):
- **Admin**: Full access to all collections
- **User**: Limited to own data (orders, complaints)

See [FIRESTORE_RULES_FIXED.txt](./FIRESTORE_RULES_FIXED.txt) for complete security rules.

##  Key Dependencies

```yaml
firebase_core: ^2.x
firebase_auth: ^4.x
cloud_firestore: ^4.x
google_sign_in: ^6.x
image_picker: ^1.x
http: ^1.x
```

##  UI Components

- Material Design 3
- Custom widgets for product cards, order cards
- Responsive layout for all screen sizes
- Bottom navigation for navigation

##  API Integration

### Firestore Collections
- **users** - User profiles and roles
- **products** - Food items inventory
- **orders** - Purchase transactions
- **complaints** - Customer feedback

### Firebase Authentication
- Google OAuth sign-in
- Anonymous mode (testing)
- Session token management

##  Testing

Test accounts can be created via Google OAuth. For admin testing:
- Use test account with `role: 'admin'` in Firestore

##  Environment Setup

Create `.env` file (not committed):
```
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_UPLOAD_PRESET=your_preset
```

##  Known Issues & Troubleshooting

### Permission Denied Error
- Check Firestore security rules are deployed
- Verify user role in Firestore `users` collection
- Clear app cache and re-login

### Display Name Shows Anonymous
- User must login via Google
- Display name pulled from Firestore, not Firebase Auth
- Ensure user document created on first login

##  Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

##  License

This project is licensed under the MIT License - see [LICENSE](./LICENSE) file for details.

##  Author

**Risman Hadinata**
- GitHub: [@rismanasdk](https://github.com/rismanasdk)

##  Roadmap

- [ ] Push notifications for orders
- [ ] Payment gateway integration
- [ ] Real-time notifications
- [ ] Advanced analytics for admin
- [ ] Multi-language support (i18n)
- [ ] Dark mode support
- [ ] Loyalty points system

---

**Last Updated**: April 2026
