# mailgpt

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# MailMind - AI-Powered Email Assistant

A Flutter application that integrates with Gmail to provide AI-powered email summaries and chat functionality.

## 🎨 Features

- **Splash Screen** with animated loading dots
- **Onboarding Flow** for first-time users
- **Firebase Authentication** (Email/Password & Google Sign-In)
- **Remember Me** functionality with token persistence
- **Gradient Theme** (Black & Dark Blue)
- **Gmail Integration** to fetch and manage emails
- **AI Email Summaries** using OpenAI
- **Chat with Emails** using AI assistant
- **Named Routing** for navigation

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase config (auto-generated)
├── utils/
│   └── routes.dart             # Route definitions
├── services/
│   ├── token_service.dart      # Token & storage management
│   └── api_service.dart        # Backend API integration
└── screens/
    ├── splash_screen.dart      # Animated splash screen
    ├── onboarding_screen.dart  # First-time user onboarding
    ├── login_screen.dart       # Login page
    ├── signup_screen.dart      # Signup page
    └── home_screen.dart        # Main email dashboard
```

## 🚀 Setup Instructions

### 1. Prerequisites

- Flutter SDK (>=3.0.0)
- Firebase project configured
- Backend API running on `http://localhost:5000`

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### Initialize Firebase
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This will generate `firebase_options.dart` automatically.

#### Enable Authentication Methods
1. Go to Firebase Console
2. Navigate to Authentication → Sign-in method
3. Enable:
    - Email/Password
    - Google Sign-In

#### Configure Gmail API
1. Go to Google Cloud Console
2. Enable Gmail API
3. Configure OAuth consent screen
4. Add scopes:
    - `https://www.googleapis.com/auth/gmail.readonly`
    - `email`
    - `profile`

### 4. Update API Base URL

If your backend is not on localhost, update in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'YOUR_BACKEND_URL';
```

### 5. Run the App

```bash
flutter run
```

## 🎯 App Flow

### First Launch
1. **Splash Screen** → Shows for 3 seconds with loading animation
2. **Onboarding Screen** → 3-page introduction (shown once)
3. **Login Screen** → User authentication

### Subsequent Launches
1. **Splash Screen** → Shows for 3 seconds
2. **Auto-Login** → If "Remember Me" was checked, goes directly to Home
3. **Login Screen** → Otherwise, shows login page

### Home Screen Features
- View all fetched emails
- Fetch new emails from Gmail
- Generate AI summaries for emails
- Delete emails
- View full email details
- Logout functionality

## 🔐 Authentication & Token Management

### Remember Me Feature
When user checks "Remember Me" on login:
- Firebase JWT token is stored
- User data is cached locally
- Auto-login on app restart

### Token Storage
Using `shared_preferences`:
- `auth_token` - Firebase JWT
- `remember_me` - Boolean flag
- `user_id`, `user_email`, `user_name`, `profile_pic` - User data
- `onboarding_complete` - Onboarding status

## 📱 Screens Overview

### 1. Splash Screen
- Gradient background (black to dark blue)
- App logo with glow effect
- Animated loading dots (3 dots)
- 3-second display duration
- Auto-navigation logic

### 2. Onboarding Screen
- 3 pages with swipe navigation
- Page indicators
- Skip button
- "Get Started" on last page
- Shows only once (tracked in storage)

### 3. Login Screen
- Email/Password fields
- Remember Me checkbox
- Google Sign-In button
- Password visibility toggle
- Form validation
- Link to signup page

### 4. Signup Screen
- Full Name field
- Email field
- Password field
- Confirm Password field
- Password visibility toggles
- Google Sign-In option
- Form validation
- Link to login page

### 5. Home Screen
- User profile card
- Email count display
- List of fetched emails
- Pull-to-refresh
- Fetch Gmail button
- Email cards with:
    - Subject & sender
    - AI summary (if generated)
    - Summarize button
    - Delete button
- Modal sheet for full email details
- Logout button

## 🎨 Design System

### Color Palette
```dart
Gradient Colors:
- #000000 (Pure Black)
- #1a1a2e (Dark Navy)
- #16213e (Navy Blue)
- #0f3460 (Deep Blue)

Accent Colors:
- Colors.blue (Primary actions)
- Colors.green (AI features)
- Colors.red (Destructive actions)
```

### Typography
- Headings: Bold, White
- Body: Regular, White70
- Labels: White60
- Links: Blue

## 🔌 API Integration

All API calls are handled through `ApiService`:

```dart
// Auth
ApiService.verifyUser(...)
ApiService.getCurrentUser()

// Mails
ApiService.getAllMails()
ApiService.getMailById(id)
ApiService.fetchGmailEmails(...)
ApiService.summarizeEmail(id)
ApiService.deleteMail(id)

// Chat
ApiService.getChatHistory(mailId)
ApiService.sendChatMessage(...)
```

## 🛠️ Backend Requirements

Ensure your backend is running with:
- MongoDB connected
- OpenAI API key configured
- All endpoints from API documentation working

Backend should be accessible at `http://localhost:5000` (or update the URL).

## 📝 Notes

### Google Sign-In Configuration

For Android (`android/app/src/main/AndroidManifest.xml`):
```xml
<!-- No additional configuration needed with FlutterFire -->
```

For iOS (`ios/Runner/Info.plist`):
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### Gmail API Permissions

Users will need to grant permission to read their Gmail when signing in. The app requests:
- Read-only access to Gmail
- Basic profile information

## 🐛 Troubleshooting

### Token Issues
If auto-login fails, clear app data:
```dart
await TokenService.clearAll();
```

### Firebase Connection
Check `firebase_options.dart` is properly generated and imported.

### API Connection
Ensure backend is running and accessible. Check console logs for API errors.

### Gmail Fetch Fails
- Verify Gmail API is enabled in Google Cloud Console
- Check OAuth scopes are configured correctly
- Ensure user has granted Gmail permissions

## 📦 Dependencies

- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `google_sign_in` - Google OAuth
- `http` - API calls
- `shared_preferences` - Local storage

## 🚀 Production Checklist

Before deploying to production:

1. ✅ Update API base URL to production server
2. ✅ Configure Firebase for production
3. ✅ Set up proper error tracking
4. ✅ Test all authentication flows
5. ✅ Verify Gmail API quotas
6. ✅ Add proper app icons and splash screens
7. ✅ Test on both Android and iOS
8. ✅ Review and update OAuth consent screen
9. ✅ Set up proper security rules in Firebase

## 📄 License

This project is for educational purposes.

## 👨‍💻 Developer Notes

- Uses Material 3 design
- Named routing for better navigation management
- Token-based authentication with persistence
- Gradient backgrounds throughout the app
- Responsive UI with proper loading states
- Error handling with user-friendly messages
