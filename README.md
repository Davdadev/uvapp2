# UV Index App

A Swift iOS application that displays real-time UV index data from ARPANSA (Australian Radiation Protection and Nuclear Safety Agency) with an accompanying widget.

## Features

- **Real-time UV Data**: Fetches UV index data from https://uvdata.arpansa.gov.au/xml/uvvalues.xml
- **Multiple Locations**: Displays UV index for different Australian locations
- **Auto-refresh**: Updates every second with relative time display (e.g., "1 min ago")
- **Color-coded UV Index**: Visual indicators based on standard UV index scale:
  - Green (0-3): Low
  - Yellow (3-6): Moderate
  - Orange (6-8): High
  - Red (8-11): Very High
  - Purple (11+): Extreme
- **Home Screen Widget**: Three widget sizes (small, medium, large) for quick UV index viewing
- **Firebase Integration**: Uses Firebase Firestore to transmit data from app to widget (no app groups)

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.0+
- Firebase project setup

## Setup Instructions

### 1. Firebase Configuration

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add an iOS app to your project with bundle ID: `com.uvapp.UVApp`
3. Download the `GoogleService-Info.plist` file
4. Replace the placeholder file at `UVApp/Resources/GoogleService-Info.plist` with your downloaded file
5. Enable Firestore Database in your Firebase project:
   - Go to Firestore Database
   - Create a database in production mode
   - Set up security rules (for development, you can use test mode)

### 2. Build and Run

1. Open `UVApp.xcodeproj` in Xcode
2. Select your development team in the project settings
3. Build and run the app on a simulator or device

### 3. Widget Setup

1. Run the app at least once to initialize Firebase and fetch data
2. Add the widget to your home screen:
   - Long press on the home screen
   - Tap the "+" button
   - Search for "UV Index"
   - Select your preferred widget size

## Architecture

### App Structure

```
UVApp/
├── UVAppApp.swift          # Main app entry point with Firebase initialization
├── ContentView.swift        # Main view with location list
├── Models/
│   └── UVDataModel.swift   # Data models for UV locations
├── Views/
│   └── LocationRowView.swift # Individual location display component
├── ViewModels/
│   └── UVViewModel.swift   # View model with auto-refresh logic
├── Services/
│   └── UVService.swift     # Networking and XML parsing service
└── Resources/
    ├── Assets.xcassets
    └── GoogleService-Info.plist

UVAppWidget/
├── UVAppWidget.swift       # Widget implementation with Firebase integration
└── Resources/
    └── Assets.xcassets
```

### Data Flow

1. **App Fetches Data**: `UVService` fetches XML data from ARPANSA API every second
2. **XML Parsing**: Custom XML parser extracts location and UV index data
3. **Firebase Storage**: Data is saved to Firestore collection `uvdata`
4. **Widget Reads Data**: Widget timeline provider reads from Firestore
5. **Display**: Both app and widget display the latest UV index data

### Firebase Collections

- `uvdata`: Stores individual location UV data
  - Document ID: Location ID
  - Fields: `locationName`, `index`, `fullTime`, `lastUpdate`
- `metadata`: Stores last update timestamp
  - Document ID: `lastUpdate`
  - Fields: `timestamp`

## Customization

### Change Refresh Interval

In `UVViewModel.swift`, modify the timer interval:
```swift
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) // Change 1.0 to desired seconds
```

### Widget Update Frequency

In `UVAppWidget.swift`, modify the timeline update interval:
```swift
let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())! // Change 5 to desired minutes
```

### UV Index Color Scheme

Modify the `uvColorForIndex` function in views to customize colors:
```swift
private func uvColorForIndex(_ index: Double) -> Color {
    // Customize color ranges here
}
```

## Troubleshooting

### Widget Not Updating

1. Ensure the app has been run at least once to initialize Firebase
2. Check that data is being written to Firestore in the Firebase Console
3. Verify the widget has permission to access the network
4. Try removing and re-adding the widget

### Firebase Errors

1. Verify `GoogleService-Info.plist` is correctly configured
2. Ensure Firestore is enabled in your Firebase project
3. Check Firebase security rules allow read/write access
4. Verify internet connectivity

### XML Parsing Issues

The app expects ARPANSA XML format with the following structure:
```xml
<locations>
  <location>
    <locationName>City Name</locationName>
    <index>7.5</index>
    <fullTime>2024-01-01 12:00:00</fullTime>
  </location>
</locations>
```

## License

This project is open source and available under the MIT License.

## Credits

UV data provided by ARPANSA (Australian Radiation Protection and Nuclear Safety Agency)