# Instagram Clone - Flutter App

A production-ready Flutter application that replicates Instagram's core features with Firebase authentication and Firestore database. Built using **Clean Architecture**, **BLoC Pattern**, and featuring **Offline-First Architecture** with local caching, smart image compression, and real-time connectivity detection.

## ✨ Key Features

### 🔐 Authentication
- Sign Up with email and password
- Sign In with email and password
- Secure password confirmation
- Firebase Authentication integration
- Session management

### 📱 Posts & Stories
- Create posts with image compression
- Create stories with smart compression
- View feed with stories carousel
- Pagination with cursor-based navigation (no duplicates)
- Like and comment on posts
- Real-time updates

### 🚀 Offline-First Architecture
- **Instant app load** from local cache (no loading spinner)
- **Automatic background sync** when online
- **Hive local database** for persistent caching
- **Fallback to cached data** when offline
- **Network error handling** with graceful degradation
- Works perfectly offline without internet connection

### 🖼️ Smart Image Handling
- **Dynamic compression** based on file size:
  - >10MB: 35% quality, 70% size reduction
  - 5-10MB: 45% quality, 60% size reduction
  - 2-5MB: 60% quality, 40% size reduction
  - <2MB: 75% quality, minimal compression
- **Cached Network Images** for offline viewing
- **Photo placeholders** while loading
- Automatic image caching with `cached_network_image`
- Supabase storage integration

### 🌐 Connectivity Features
- **Real-time connectivity detection** with DNS verification
- **Instant offline banner** in AppBar when disconnected
- **Blocks actions** when offline (like, comment, refresh)
- **DNS lookup verification** for true internet access (not just network)
- **1.5-second timeout** for fast detection

### 📊 Data Management
- **Hive local database** for offline caching
- **Cursor-based pagination** for efficient data loading
- **Background data sync** when online
- **No duplicate posts** in pagination
- **Automatic cache invalidation** and updates

## 🏗️ Architecture

- **Clean Architecture** principles with 3 layers
- **BLOC Pattern** for state management
- **Dependency Injection** with GetIt
- **Repository pattern** with offline-first data flow
- **Use Cases** for business logic separation

## 📦 Project Structure

```
lib/
├── core/
│   ├── error/
│   │   └── failures.dart
│   ├── usecase/
│   │   └── usecase.dart
│   └── utils/
│       ├── compression_service.dart      # Smart image compression
│       ├── connectivity_service.dart     # Network detection with DNS
│       ├── local_storage_service.dart    # Hive offline caching
│       ├── cache_service.dart            # JSON string caching
│       └── supabase_storage_service.dart # File upload service
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── home/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── post_remote_data_source.dart # Firestore with pagination
│       │   ├── models/
│       │   ├── repositories/
│       │   │   └── post_repository_impl.dart    # Offline-first repo
│       │   └── datasources/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── bloc/
│           │   ├── post_bloc.dart      # BLoC with instant cache load
│           │   ├── post_event.dart
│           │   └── post_state.dart
│           ├── pages/
│           │   ├── home_page.dart      # Feed with offline banner
│           │   ├── create_post_page.dart
│           │   ├── add_story_page.dart
│           │   └── user_profile_page.dart
│           └── widgets/
│               ├── post_widget.dart
│               ├── story_widget.dart
│               └── comments_bottom_sheet.dart
├── service_locator/
│   └── service_locator.dart
└── main.dart
```

## 📚 Dependencies

### State Management
- `flutter_bloc: ^8.1.6` - State management
- `bloc: ^8.1.4` - BLoC pattern

### Firebase & Backend
- `firebase_core: ^3.15.2` - Firebase initialization
- `firebase_auth: ^5.7.0` - Authentication
- `cloud_firestore: ^5.4.0` - Database with pagination
- `firebase_storage: ^12.2.0` - Cloud storage

### Local Storage & Caching
- `hive: ^2.2.3` - Local database
- `hive_flutter: ^1.1.0` - Hive Flutter integration
- `cached_network_image: ^3.3.1` - Image caching with placeholders

### Image & Media
- `image: ^4.1.3` - Image processing & compression
- `image_picker: ^1.1.1` - Select images
- `video_compress: ^3.1.2` - Video compression

### Network & Connectivity
- `connectivity_plus: ^6.0.1` - Network detection
- `http: ^1.1.0` - HTTP requests
- `supabase_flutter: ^1.10.3` - Supabase integration

### Utilities
- `get_it: ^7.6.0` - Service locator/DI
- `dartz: ^0.10.1` - Functional programming
- `equatable: ^2.0.5` - Value equality
- `timeago: ^3.7.0` - Relative timestamps

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (version 3.10.4+)
- Dart SDK
- Firebase project
- Supabase project (for file uploads)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flutter_test_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add Android and iOS apps
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place in:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. **Supabase Setup** (for image uploads)
   - Create a Supabase project
   - Configure Supabase URL and API key in `main.dart`
   - Enable storage buckets

5. **Run the app**
   ```bash
   flutter run
   ```

## 🎯 How It Works

### Offline-First Data Flow

1. **App Launch**
   - Load cached data instantly from Hive (synchronously)
   - Show UI with cached posts/stories immediately
   - Fetch fresh data from Firebase in background
   - Update UI when fresh data arrives

2. **User Online**
   - Fetch latest data from Firebase
   - Cache automatically for offline use
   - UI shows fresh content

3. **User Offline**
   - Can't perform actions (like, comment, refresh blocked)
   - Shows "You are currently offline" banner
   - All data from cache loads instantly
   - No loading indicators, smooth experience

4. **User Reconnects**
   - Banner disappears automatically
   - Fresh data syncs from Firebase
   - UI updates with latest posts

### Image Compression Flow

1. User selects image
2. Compression Service analyzes file size
3. Applies dynamic quality based on size
4. Reduces file by 70-85% for large images
5. Uploads to Supabase
6. Cached locally on device

### Pagination

- Uses cursor-based pagination (efficient)
- Reset cursor on refresh (page 1)
- No duplicate posts when scrolling
- 5-second timeout per request
- Fallback to cache on error

## 🔒 Firestore Structure

```javascript
// users collection
{
  uid: "user123",
  email: "user@example.com",
  name: "John Doe",
  profileImageUrl: "https://...",
  createdAt: timestamp
}

// posts collection
{
  id: "post123",
  userId: "user123",
  userName: "John Doe",
  userImage: "https://...",
  imageUrl: "https://...",  // Supabase URL
  description: "My post caption",
  createdAt: timestamp,
  likes: ["user2", "user3"],
  comments: [
    {
      userId: "user2",
      userName: "Jane",
      text: "Nice post!",
      createdAt: timestamp
    }
  ]
}

// stories collection
{
  id: "story123",
  userId: "user123",
  userName: "John Doe",
  userImage: "https://...",
  imageUrl: "https://...",  // Supabase URL
  createdAt: timestamp,
  expiresAt: timestamp  // 24 hours
}
```

## 🧪 Testing

```bash
# Run tests
flutter test

# Run code analysis
flutter analyze

# Check for issues
flutter doctor
```

## 🛠️ Troubleshooting

### Images Not Loading
- Check Supabase bucket permissions
- Verify image URLs are correct
- Clear cache: `flutter pub get && flutter clean`

### Offline Banner Not Appearing
- Check connectivity service is initialized
- Verify DNS lookup timeout (1.5 seconds)
- Test with actual airplane mode

### Posts Not Refreshing
- Ensure you're online (check banner)
- Pull-to-refresh only fetches from Firebase when online
- Cached data appears instantly without refresh

### Slow Loading
- First load shows cache instantly
- Background sync updates in <5 seconds
- Network timeout is 5 seconds max

## 📈 Performance Optimizations

- **Hive for fast local access** (~1ms reads)
- **Image compression** reduces network by 70-85%
- **Cached network images** prevent re-downloads
- **Cursor pagination** efficient Firebase queries
- **BLoC instant cache emit** no loading screen
- **5-second network timeout** prevents hanging
- **1.5-second connectivity check** for quick detection

## 🚢 Deployment

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 📝 License

MIT License - feel free to use for personal or commercial projects

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📧 Support

For issues, questions, or suggestions:
- Create an issue in the repository
- Contact: your-email@example.com

---

**Built with ❤️ using Flutter, Firebase & Hive**
# instagram-clone
