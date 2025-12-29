# Development Guide

This guide covers development workflows and best practices for the UV Index app.

## Project Structure Overview

```
uvapp2/
├── UVApp.xcodeproj/              # Xcode project file
│   ├── project.pbxproj           # Project configuration
│   └── project.xcworkspace/      # Workspace with Swift Package Manager
├── UVApp/                        # Main iOS app target
│   ├── UVAppApp.swift           # App entry point
│   ├── ContentView.swift        # Main view
│   ├── Models/                  # Data models
│   ├── Views/                   # SwiftUI views
│   ├── ViewModels/              # View models (MVVM)
│   ├── Services/                # Business logic & networking
│   └── Resources/               # Assets, plists, etc.
├── UVAppWidget/                  # Widget extension target
│   ├── UVAppWidget.swift        # Widget implementation
│   └── Resources/               # Widget assets
├── README.md                     # Main documentation
├── FIREBASE_SETUP.md            # Firebase setup guide
└── LICENSE                       # MIT License

```

## Development Setup

### Prerequisites
- macOS 13.0 or later
- Xcode 15.0 or later
- Active Apple Developer account (for device testing)
- Firebase account (free tier is sufficient)

### Initial Setup
1. Clone the repository
2. Follow FIREBASE_SETUP.md to configure Firebase
3. Open `UVApp.xcodeproj` in Xcode
4. Wait for Swift Package Manager to resolve dependencies
5. Select your development team in project settings
6. Build and run

## Architecture

The app follows the MVVM (Model-View-ViewModel) pattern:

### Models (`Models/`)
- `UVDataModel.swift`: Defines data structures for UV locations and responses
- Codable structs for JSON/XML parsing

### Views (`Views/` & `ContentView.swift`)
- `ContentView.swift`: Main app view with location list
- `LocationRowView.swift`: Individual location card component
- SwiftUI-based declarative UI

### ViewModels (`ViewModels/`)
- `UVViewModel.swift`: Business logic for main view
  - Manages data fetching and state
  - Handles auto-refresh timer
  - Formats relative time strings

### Services (`Services/`)
- `UVService.swift`: Networking and data management
  - Fetches data from ARPANSA API
  - Parses XML responses
  - Saves data to Firebase Firestore

### Widget (`UVAppWidget/`)
- `UVAppWidget.swift`: Widget implementation
  - Timeline provider for widget updates
  - Multiple widget sizes (small, medium, large)
  - Reads data from Firebase Firestore

## Key Features Implementation

### 1. Auto-Refresh (Every Second)
Implemented in `UVViewModel.swift`:
```swift
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    Task { @MainActor in
        await self?.fetchData()
    }
}
```

**Note**: Refreshing every second is very frequent. For production:
- Consider longer intervals (5-15 minutes)
- Implement exponential backoff for errors
- Add user preference for refresh rate

### 2. Relative Time Display
Shows "1 min ago" style timestamps:
```swift
func getRelativeTimeString() -> String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    return formatter.localizedString(for: lastUpdateTime, relativeTo: Date())
}
```

### 3. Firebase Data Transmission
App writes to Firestore:
```swift
// In UVService.swift
private func saveToFirebase(locations: [UVLocation]) async throws {
    for location in locations {
        try await db.collection("uvdata").document(location.id).setData([...])
    }
}
```

Widget reads from Firestore:
```swift
// In UVAppWidget.swift
private func fetchUVDataFromFirebase() async -> [UVWidgetLocation] {
    let snapshot = try await db.collection("uvdata").getDocuments()
    // Process snapshot...
}
```

### 4. XML Parsing
Custom XML parser using `XMLParser` delegate:
```swift
class UVXMLParser: NSObject, XMLParserDelegate {
    // Implements delegate methods to parse ARPANSA XML
}
```

### 5. Color-Coded UV Index
Based on WHO/UV Index standards:
- Green (0-3): Low
- Yellow (3-6): Moderate  
- Orange (6-8): High
- Red (8-11): Very High
- Purple (11+): Extreme

## Testing

### Manual Testing
1. Run the app in simulator or on device
2. Verify locations are displayed
3. Check that UV index values are color-coded correctly
4. Verify "last updated" time changes
5. Test widget installation and updates

### Firebase Testing
1. Open Firebase Console → Firestore Database
2. Run the app
3. Verify `uvdata` collection is populated
4. Check `metadata` document is updated
5. Add/remove the widget and verify data appears

### Widget Testing
1. Run app at least once to populate data
2. Add widget to home screen
3. Verify widget shows correct data
4. Wait 5+ minutes and verify widget updates
5. Test all three widget sizes

## Common Development Tasks

### Changing Refresh Interval

**App Refresh** (`UVViewModel.swift`):
```swift
timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) // 60 seconds
```

**Widget Refresh** (`UVAppWidget.swift`):
```swift
let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())! // 15 minutes
```

### Adding New Location Data Fields

1. Update `UVLocation` model in `UVDataModel.swift`
2. Update XML parser in `UVService.swift`
3. Update Firestore save logic in `UVService.swift`
4. Update UI components to display new fields

### Customizing UI Colors

**App Colors** (`LocationRowView.swift` and `ContentView.swift`):
- Modify gradient colors in `ContentView`
- Update `uvColorForIndex()` function

**Widget Colors** (`UVAppWidget.swift`):
- Update `uvColorForIndex()` in each widget view

### Adding Analytics

1. Enable Analytics in Firebase Console
2. Add FirebaseAnalytics to Swift Package dependencies
3. Import FirebaseAnalytics in relevant files
4. Add tracking events:
```swift
import FirebaseAnalytics
Analytics.logEvent("uv_data_fetched", parameters: ["location_count": locations.count])
```

## Debugging Tips

### Firebase Connection Issues
- Check `GoogleService-Info.plist` is in correct location
- Verify Firebase project ID matches
- Check Xcode console for Firebase initialization messages
- Test Firestore access in Firebase Console

### XML Parsing Issues
- Print raw XML response for inspection
- Verify ARPANSA API is accessible
- Check XML structure matches expected format
- Add error logging in parser delegate methods

### Widget Not Updating
- Widgets have limited update frequency (iOS limits background updates)
- Ensure app ran at least once to write Firebase data
- Check widget timeline policy is set correctly
- Verify Firebase rules allow read access

### Performance Optimization
- Current implementation fetches every second (very frequent!)
- Consider:
  - Caching responses
  - Only updating when values change
  - Longer refresh intervals
  - Background fetch instead of timer

## Building for Release

1. Update version number in project settings
2. Update bundle identifier if needed
3. Configure signing with production certificate
4. Update Firebase security rules for production
5. Test thoroughly on physical devices
6. Archive and upload to App Store Connect

## Best Practices

1. **Error Handling**: Always handle network and parsing errors gracefully
2. **User Experience**: Show loading states and error messages
3. **Battery Life**: Minimize refresh frequency for production
4. **Data Usage**: Be conscious of API call frequency
5. **Firebase Costs**: Monitor usage to stay within free tier
6. **Security**: Never commit real Firebase credentials
7. **Testing**: Test on multiple device sizes and iOS versions

## Troubleshooting

### Build Errors
- Clean build folder: Product → Clean Build Folder (Cmd+Shift+K)
- Reset Package caches: File → Packages → Reset Package Caches
- Delete DerivedData folder

### Runtime Crashes
- Check Xcode console for error messages
- Verify Firebase is initialized before use
- Check network connectivity
- Validate XML parsing logic

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Resources

- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [SwiftUI Documentation](https://developer.apple.com/xcode/swiftui/)
- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [ARPANSA UV Data](https://www.arpansa.gov.au/our-services/monitoring/ultraviolet-radiation-monitoring)
