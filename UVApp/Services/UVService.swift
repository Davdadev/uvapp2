import Foundation
import FirebaseFirestore

class UVService {
    static let shared = UVService()
    private let xmlURL = "https://uvdata.arpansa.gov.au/xml/uvvalues.xml"
    private let db = Firestore.firestore()
    
    private init() {}
    
    func fetchUVData() async throws -> [UVLocation] {
        guard let url = URL(string: xmlURL) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let locations = try parseXMLData(data)
        
        // Save to Firebase for widget access
        try await saveToFirebase(locations: locations)
        
        return locations
    }
    
    private func parseXMLData(_ data: Data) throws -> [UVLocation] {
        let parser = UVXMLParser()
        return try parser.parse(data: data)
    }
    
    private func saveToFirebase(locations: [UVLocation]) async throws {
        let timestamp = Date()
        
        // Save each location
        for location in locations {
            let docRef = db.collection("uvdata").document(location.id)
            try await docRef.setData([
                "locationName": location.locationName,
                "index": location.index,
                "fullTime": location.fullTime,
                "lastUpdate": Timestamp(date: timestamp)
            ])
        }
        
        // Save metadata
        try await db.collection("metadata").document("lastUpdate").setData([
            "timestamp": Timestamp(date: timestamp)
        ])
    }
}

// XML Parser for ARPANSA data
class UVXMLParser: NSObject, XMLParserDelegate {
    private var locations: [UVLocation] = []
    private var currentElement = ""
    private var currentLocationName = ""
    private var currentIndex = ""
    private var currentFullTime = ""
    private var foundCharacters = ""
    
    func parse(data: Data) throws -> [UVLocation] {
        locations = []
        let parser = XMLParser(data: data)
        parser.delegate = self
        
        if parser.parse() {
            return locations
        } else {
            throw NSError(domain: "XMLParseError", code: -1, userInfo: nil)
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        foundCharacters = ""
        
        if elementName == "location" {
            currentLocationName = ""
            currentIndex = ""
            currentFullTime = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        foundCharacters += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "locationName":
            currentLocationName = foundCharacters
        case "index":
            currentIndex = foundCharacters
        case "fullTime":
            currentFullTime = foundCharacters
        case "location":
            if !currentLocationName.isEmpty {
                let location = UVLocation(
                    id: UUID().uuidString,
                    locationName: currentLocationName,
                    index: Double(currentIndex) ?? 0.0,
                    fullTime: currentFullTime
                )
                locations.append(location)
            }
        default:
            break
        }
        
        foundCharacters = ""
    }
}
