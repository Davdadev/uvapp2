import WidgetKit
import SwiftUI
import FirebaseCore
import FirebaseFirestore

// Entry for widget timeline
struct UVWidgetEntry: TimelineEntry {
    let date: Date
    let locations: [UVWidgetLocation]
}

struct UVWidgetLocation {
    let locationName: String
    let index: Double
    let fullTime: String
}

// Timeline Provider
struct UVWidgetProvider: TimelineProvider {
    
    init() {
        // Initialize Firebase if not already initialized
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    func placeholder(in context: Context) -> UVWidgetEntry {
        UVWidgetEntry(date: Date(), locations: [
            UVWidgetLocation(locationName: "Loading...", index: 0, fullTime: "")
        ])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (UVWidgetEntry) -> Void) {
        Task {
            let locations = await fetchUVDataFromFirebase()
            let entry = UVWidgetEntry(date: Date(), locations: locations)
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<UVWidgetEntry>) -> Void) {
        Task {
            let locations = await fetchUVDataFromFirebase()
            let entry = UVWidgetEntry(date: Date(), locations: locations)
            
            // Refresh every 5 minutes
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            
            completion(timeline)
        }
    }
    
    private func fetchUVDataFromFirebase() async -> [UVWidgetLocation] {
        let db = Firestore.firestore()
        
        do {
            let snapshot = try await db.collection("uvdata").getDocuments()
            
            var locations: [UVWidgetLocation] = []
            for document in snapshot.documents {
                let data = document.data()
                if let name = data["locationName"] as? String,
                   let index = data["index"] as? Double,
                   let fullTime = data["fullTime"] as? String {
                    locations.append(UVWidgetLocation(
                        locationName: name,
                        index: index,
                        fullTime: fullTime
                    ))
                }
            }
            
            return locations.isEmpty ? [
                UVWidgetLocation(locationName: "No data", index: 0, fullTime: "")
            ] : locations
        } catch {
            return [UVWidgetLocation(locationName: "Error loading", index: 0, fullTime: "")]
        }
    }
}

// Widget View
struct UVWidgetEntryView: View {
    var entry: UVWidgetEntry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: UVWidgetEntry
    
    var body: some View {
        if let firstLocation = entry.locations.first {
            VStack(spacing: 8) {
                Text("UV Index")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ZStack {
                    Circle()
                        .fill(uvColorForIndex(firstLocation.index))
                        .frame(width: 60, height: 60)
                    
                    VStack(spacing: 2) {
                        Text("\(String(format: "%.1f", firstLocation.index))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                Text(firstLocation.locationName)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .padding()
        }
    }
    
    private func uvColorForIndex(_ index: Double) -> Color {
        switch index {
        case 0..<3: return Color.green
        case 3..<6: return Color.yellow
        case 6..<8: return Color.orange
        case 8..<11: return Color.red
        default: return Color.purple
        }
    }
}

struct MediumWidgetView: View {
    let entry: UVWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("UV Index")
                .font(.headline)
                .padding(.bottom, 4)
            
            HStack(spacing: 12) {
                ForEach(Array(entry.locations.prefix(3).enumerated()), id: \.offset) { _, location in
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(uvColorForIndex(location.index))
                                .frame(width: 45, height: 45)
                            
                            Text("\(String(format: "%.1f", location.index))")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        Text(location.locationName)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding()
    }
    
    private func uvColorForIndex(_ index: Double) -> Color {
        switch index {
        case 0..<3: return Color.green
        case 3..<6: return Color.yellow
        case 6..<8: return Color.orange
        case 8..<11: return Color.red
        default: return Color.purple
        }
    }
}

struct LargeWidgetView: View {
    let entry: UVWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("UV Index")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(Array(entry.locations.prefix(6).enumerated()), id: \.offset) { _, location in
                HStack {
                    Text(location.locationName)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(uvColorForIndex(location.index))
                            .frame(width: 40, height: 40)
                        
                        Text("\(String(format: "%.1f", location.index))")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
    }
    
    private func uvColorForIndex(_ index: Double) -> Color {
        switch index {
        case 0..<3: return Color.green
        case 3..<6: return Color.yellow
        case 6..<8: return Color.orange
        case 8..<11: return Color.red
        default: return Color.purple
        }
    }
}

// Widget Configuration
@main
struct UVAppWidget: Widget {
    let kind: String = "UVAppWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UVWidgetProvider()) { entry in
            UVWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("UV Index")
        .description("Display current UV index for different locations")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
