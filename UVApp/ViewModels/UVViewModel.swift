import Foundation
import Combine

@MainActor
class UVViewModel: ObservableObject {
    @Published var locations: [UVLocation] = []
    @Published var lastUpdateTime: Date = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var timer: Timer?
    private let service = UVService.shared
    
    init() {
        startAutoRefresh()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func startAutoRefresh() {
        // Initial fetch
        Task {
            await fetchData()
        }
        
        // Refresh every second as specified
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchData()
            }
        }
    }
    
    func fetchData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedLocations = try await service.fetchUVData()
            locations = fetchedLocations
            lastUpdateTime = Date()
        } catch {
            errorMessage = "Failed to fetch UV data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func getRelativeTimeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: lastUpdateTime, relativeTo: Date())
    }
}
