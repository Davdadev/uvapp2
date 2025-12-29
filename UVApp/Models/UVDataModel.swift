import Foundation

// Model for UV data from ARPANSA XML
struct UVLocation: Identifiable, Codable {
    let id: String
    let locationName: String
    let index: Double
    let fullTime: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case locationName = "location"
        case index
        case fullTime = "fullTime"
    }
}

struct UVDataResponse: Codable {
    let locations: [UVLocation]
    let lastUpdate: Date
}
