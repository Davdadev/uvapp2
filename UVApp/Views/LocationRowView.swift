import SwiftUI

struct LocationRowView: View {
    let location: UVLocation
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(location.locationName)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(location.fullTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // UV Index display with color coding
            ZStack {
                Circle()
                    .fill(uvColorForIndex(location.index))
                    .frame(width: 70, height: 70)
                
                VStack(spacing: 2) {
                    Text("\(String(format: "%.1f", location.index))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("UV")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // UV Index color coding based on standard scale
    private func uvColorForIndex(_ index: Double) -> Color {
        switch index {
        case 0..<3:
            return Color.green
        case 3..<6:
            return Color.yellow
        case 6..<8:
            return Color.orange
        case 8..<11:
            return Color.red
        default:
            return Color.purple
        }
    }
}

struct LocationRowView_Previews: PreviewProvider {
    static var previews: some View {
        LocationRowView(
            location: UVLocation(
                id: "1",
                locationName: "Sydney",
                index: 7.5,
                fullTime: "2024-01-01 12:00:00"
            )
        )
        .padding()
    }
}
