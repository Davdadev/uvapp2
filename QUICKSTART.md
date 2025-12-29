# Quick Start Guide

Get your UV Index app up and running in minutes!

## Prerequisites

- Mac with macOS 13.0+
- Xcode 15.0+
- Apple Developer account (for device testing)
- Firebase account (free)

## 5-Minute Setup

### Step 1: Firebase Setup (2 minutes)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add iOS app with bundle ID: `com.uvapp.UVApp`
4. Download `GoogleService-Info.plist`
5. Replace `UVApp/Resources/GoogleService-Info.plist` with your file
6. Enable Firestore Database (start in test mode)

### Step 2: Build & Run (3 minutes)

1. Open `UVApp.xcodeproj` in Xcode
2. Wait for Swift Package Manager to download dependencies (~1-2 minutes)
3. Select your development team in project settings
4. Select a simulator or device
5. Press ⌘+R to build and run

### Step 3: Add Widget (optional)

1. With the app running, go to the home screen
2. Long press to enter jiggle mode
3. Tap the + button
4. Search for "UV Index"
5. Select widget size and add to home screen

## What You'll See

- **App**: List of Australian locations with current UV index
- **Color coding**: Green (low) to Purple (extreme)
- **Live updates**: Refreshes every second
- **Time stamp**: "Last updated X ago"
- **Widget**: Home screen widget showing UV data

## Troubleshooting

### "Firebase not configured" error
- Verify `GoogleService-Info.plist` is in `UVApp/Resources/`
- Clean build folder (⌘+Shift+K) and rebuild

### Build errors
- Check Xcode version is 15.0+
- Verify internet connection for package downloads
- Try: File → Packages → Reset Package Caches

### No data showing
- Check internet connection
- Verify Firestore is enabled in Firebase Console
- Check Xcode console for error messages

## Important Notes

⚠️ **Production Use**: The app refreshes every second as specified. For production:
- Change refresh interval to 5-15 minutes (see `REQUIREMENTS.md`)
- Monitor Firebase usage to stay within free tier
- Consider implementing offline caching

## Next Steps

- Read [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed Firebase configuration
- Check [DEVELOPMENT.md](DEVELOPMENT.md) for development guidelines
- Review [REQUIREMENTS.md](REQUIREMENTS.md) for production recommendations
- See [README.md](README.md) for comprehensive documentation

## Support

Having issues? Check:
1. Xcode console for error messages
2. Firebase Console → Firestore Database for data
3. Project documentation files listed above

---

**Tip**: Start with the simulator to avoid code signing issues, then move to a physical device for widget testing.
