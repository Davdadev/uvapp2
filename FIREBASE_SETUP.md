# Firebase Setup Guide

This guide will help you set up Firebase for the UV Index app.

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter a project name (e.g., "UV Index App")
4. (Optional) Enable Google Analytics
5. Click "Create project"

## Step 2: Add iOS App to Firebase

1. In your Firebase project, click the iOS icon to add an iOS app
2. Enter the iOS bundle ID: `com.uvapp.UVApp`
3. (Optional) Enter app nickname: "UV Index App"
4. (Optional) Enter App Store ID (if you have one)
5. Click "Register app"

## Step 3: Download Configuration File

1. Download the `GoogleService-Info.plist` file
2. Replace the placeholder file at `UVApp/Resources/GoogleService-Info.plist` with your downloaded file
3. **Important**: Make sure the file is added to the UVApp target in Xcode

## Step 4: Enable Firestore Database

1. In the Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Select "Start in production mode" (or "test mode" for development)
4. Choose a Cloud Firestore location (select closest to your target users)
5. Click "Enable"

## Step 5: Configure Firestore Security Rules

For development and testing, you can use these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to uvdata and metadata collections
    match /uvdata/{document=**} {
      allow read, write: if true;
    }
    match /metadata/{document=**} {
      allow read, write: if true;
    }
  }
}
```

**Important**: For production, implement proper security rules to restrict access:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow anyone to read UV data
    match /uvdata/{document=**} {
      allow read: if true;
      allow write: if request.auth != null; // Only authenticated users can write
    }
    match /metadata/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Step 6: Add Firebase SDK (Already Done)

The Xcode project is already configured to use Firebase iOS SDK via Swift Package Manager. The dependencies included are:
- FirebaseCore
- FirebaseFirestore

## Step 7: Build and Run

1. Open `UVApp.xcodeproj` in Xcode
2. Wait for Swift Package Manager to resolve dependencies
3. Select your development team in project settings
4. Build and run the app

## Firestore Data Structure

The app creates the following collections:

### `uvdata` Collection
Each document represents a location:
```
Document ID: {location_id}
Fields:
  - locationName (string): Name of the location
  - index (number): UV index value
  - fullTime (string): Timestamp from ARPANSA
  - lastUpdate (timestamp): When this data was updated
```

### `metadata` Collection
```
Document ID: "lastUpdate"
Fields:
  - timestamp (timestamp): Last time data was fetched
```

## Troubleshooting

### "Firebase not configured" error
- Ensure `GoogleService-Info.plist` is in the correct location
- Verify the file is added to the UVApp target
- Clean build folder (Cmd+Shift+K) and rebuild

### "Permission denied" errors
- Check Firestore security rules
- For testing, use test mode rules (allow all access)

### Widget not showing data
- Run the main app first to populate Firestore
- Ensure widget extension has network access
- Check Firebase Console to verify data is being written

## Firebase Console Access

You can monitor data in real-time:
1. Go to Firebase Console → Firestore Database
2. View the `uvdata` and `metadata` collections
3. You should see documents appear as the app fetches UV data

## Cost Considerations

Firebase has a generous free tier:
- **Firestore**: 
  - 50K document reads per day
  - 20K document writes per day
  - 1 GB storage
  
For this app's usage pattern (updating every second when app is active), you should stay within the free tier for personal use. However, be aware of:
- Each fetch writes to multiple documents (one per location)
- Each widget update reads from Firestore
- Consider adjusting update frequency for production use

## Security Best Practices

1. **Never commit real Firebase credentials to public repositories**
2. Use environment-specific configuration files
3. Implement proper authentication for write operations
4. Use Firebase App Check to prevent abuse
5. Monitor usage in Firebase Console
6. Set up budget alerts in Google Cloud Platform
