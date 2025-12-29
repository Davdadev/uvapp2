import SwiftUI

// Shared UV Index utility functions
struct UVIndexHelper {
    
    // UV Index color coding based on WHO/international standards
    static func colorForIndex(_ index: Double) -> Color {
        switch index {
        case 0..<3:
            return Color.green  // Low
        case 3..<6:
            return Color.yellow  // Moderate
        case 6..<8:
            return Color.orange  // High
        case 8..<11:
            return Color.red  // Very High
        default:
            return Color.purple  // Extreme
        }
    }
    
    // Get description for UV index level
    static func descriptionForIndex(_ index: Double) -> String {
        switch index {
        case 0..<3:
            return "Low"
        case 3..<6:
            return "Moderate"
        case 6..<8:
            return "High"
        case 8..<11:
            return "Very High"
        default:
            return "Extreme"
        }
    }
}
