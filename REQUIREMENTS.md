# Project Requirements & Implementation Notes

## Original Requirements

The project was requested with the following specifications:

1. **UV Data Source**: https://uvdata.arpansa.gov.au/xml/uvvalues.xml
2. **Display**: Show UV index for different locations
3. **Auto-refresh**: Update every second
4. **Time Display**: Show "last updated 1min ago" style timestamps
5. **Widget**: Include a home screen widget
6. **Data Transmission**: Use Firebase (not App Groups) to share data between app and widget

## Implementation Details

### Auto-Refresh Rate: 1 Second

⚠️ **Important Consideration**: The requirement specifies updating every second. While implemented as requested, this is **extremely aggressive** and has several implications:

**Issues with 1-second refresh:**
- **API Load**: Makes 3,600 requests per hour to ARPANSA's server
- **Firebase Costs**: Writes to Firestore 3,600 times per hour (will exceed free tier quickly)
- **Battery Drain**: Constant network activity significantly impacts battery life
- **Rate Limiting**: May trigger rate limits on the ARPANSA API
- **Data Costs**: High mobile data usage for users

**Recommended for Production:**
```swift
// Current (as specified):
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true)

// Recommended:
timer = Timer.scheduledTimer(withTimeInterval: 300.0, repeats: true) // 5 minutes
// or
timer = Timer.scheduledTimer(withTimeInterval: 900.0, repeats: true) // 15 minutes
```

**Why ARPANSA Data Doesn't Need Per-Second Updates:**
- UV index measurements are typically updated every 10-30 minutes
- UV levels change gradually based on sun position
- Real-time per-second data is not available from the source
- Fetching every second will return the same data repeatedly

### XML Data Structure

The app expects XML in this format from ARPANSA:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<uvvalues>
  <location>
    <locationName>Adelaide</locationName>
    <index>7.5</index>
    <fullTime>2024-01-15 12:30:00</fullTime>
  </location>
  <location>
    <locationName>Brisbane</locationName>
    <index>9.2</index>
    <fullTime>2024-01-15 12:30:00</fullTime>
  </location>
  <!-- More locations... -->
</uvvalues>
```

**Note**: If the actual XML structure differs, the parser in `UVService.swift` will need adjustment.

### Firebase Data Flow

```
App (Every 1 second):
  ├─ Fetch XML from ARPANSA
  ├─ Parse XML data
  └─ Write to Firestore:
      ├─ Collection: "uvdata"
      │   └─ Documents: {location_id}
      │       ├─ locationName: string
      │       ├─ index: number
      │       ├─ fullTime: string
      │       └─ lastUpdate: timestamp
      └─ Collection: "metadata"
          └─ Document: "lastUpdate"
              └─ timestamp: timestamp

Widget (Every 5 minutes):
  ├─ Read from Firestore collection "uvdata"
  └─ Display UV index for locations
```

### Why Firebase Instead of App Groups?

As specified, Firebase is used instead of App Groups for data transmission. This has both advantages and disadvantages:

**Advantages:**
- ✅ Widget can update even when app is not running
- ✅ Data persists in cloud
- ✅ Can support multiple devices
- ✅ Real-time data synchronization

**Disadvantages:**
- ❌ Requires internet connection
- ❌ Ongoing operational costs (beyond free tier)
- ❌ More complex setup
- ❌ External dependency
- ❌ Privacy considerations (data stored externally)

**App Groups Alternative** (not implemented per requirements):
If you want to switch to App Groups in the future:
- More efficient for single-device use
- No cloud costs
- Works offline
- More privacy-friendly
- Simpler setup

### UV Index Color Coding

The app uses WHO/international UV Index standards:

| UV Index | Risk Level | Color | Description |
|----------|------------|-------|-------------|
| 0-2.9 | Low | Green | Minimal sun protection required |
| 3-5.9 | Moderate | Yellow | Protection required |
| 6-7.9 | High | Orange | Protection required |
| 8-10.9 | Very High | Red | Extra protection required |
| 11+ | Extreme | Purple | Maximum protection required |

### Widget Update Frequency

- **Recommended**: 5-15 minutes (currently set to 5 minutes)
- **iOS Limit**: WidgetKit has system-imposed update frequency limits
- **Battery Impact**: More frequent updates = more battery drain
- **Network Usage**: Each update requires Firestore read

### Testing Considerations

Due to the 1-second refresh rate, during development:

1. **Monitor Firebase Usage**: Check Firebase Console → Usage to avoid unexpected costs
2. **Test Error Handling**: Simulate network failures and API errors
3. **Battery Testing**: Monitor battery drain on physical devices
4. **Rate Limiting**: Be prepared for API rate limits during testing
5. **Offline Behavior**: Test app behavior without internet connection

### Production Recommendations

Before releasing to production, consider:

1. **Increase Refresh Interval**: Change from 1 second to 5-15 minutes
2. **Add User Settings**: Let users choose update frequency
3. **Implement Caching**: Cache responses to reduce unnecessary updates
4. **Add Smart Refresh**: Only update when values actually change
5. **Background Fetch**: Use iOS background fetch instead of timer
6. **Firebase Security**: Implement proper Firestore security rules
7. **Error Recovery**: Implement exponential backoff for errors
8. **Usage Analytics**: Track API usage to optimize costs

### Cost Estimates (1-second refresh)

**Firebase Firestore (if app runs continuously):**
- Writes: 3,600/hour × 24 hours = 86,400 writes/day
- Free tier: 20,000 writes/day
- **Exceeds free tier**: ~$0.35/day or ~$10.50/month for writes alone

**With 5-minute refresh:**
- Writes: 12/hour × 24 hours = 288 writes/day
- **Within free tier**: $0/month

### API Rate Limiting

ARPANSA may implement rate limiting. If you encounter 429 (Too Many Requests) errors:

1. Implement exponential backoff
2. Reduce refresh frequency
3. Add request caching
4. Contact ARPANSA for API terms of use

## Compliance & Attribution

- **Data Source**: ARPANSA (Australian Radiation Protection and Nuclear Safety Agency)
- **API Usage**: Ensure compliance with ARPANSA's terms of service
- **Attribution**: Consider adding proper attribution in the app
- **Data Accuracy**: UV data is provided as-is from ARPANSA

## Future Enhancements

Potential improvements not in original requirements:

1. **Push Notifications**: Alert users when UV index is very high
2. **Location Services**: Show UV for user's current location
3. **Historical Data**: Chart UV index trends over time
4. **Sun Protection Tips**: Provide advice based on UV level
5. **Offline Mode**: Cache last known values for offline use
6. **Apple Watch**: Extend to watchOS
7. **Widgets Configuration**: Let users select which locations to show
8. **Dark Mode**: Optimize UI for dark mode
9. **Accessibility**: VoiceOver support and Dynamic Type
10. **Localization**: Support multiple languages

## Support

For issues or questions:
- Check FIREBASE_SETUP.md for Firebase configuration
- Check DEVELOPMENT.md for development guidelines
- Review README.md for general documentation
