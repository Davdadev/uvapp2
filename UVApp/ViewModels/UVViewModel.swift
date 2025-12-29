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
    private var isCurrentlyFetching = false
    
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
        
        // Refresh every second as specified in requirements
        // NOTE: For production, consider increasing to 5-15 minutes to avoid:
        // - Excessive API calls
        // - High Firebase write costs
        // - Battery drain
        // - Potential rate limiting
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchData()
            }
        }
    }
    
    func fetchData() async {
        // Prevent concurrent fetches
        guard !isCurrentlyFetching else { return }
        
        isCurrentlyFetching = true
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedLocations = try await service.fetchUVData()
            locations = fetchedLocations
            lastUpdateTime = Date()
            errorMessage = nil // Clear any previous errors
        } catch {
            // Only update error message, keep previous data if available
            errorMessage = "Failed to fetch UV data: \(error.localizedDescription)"
            print("UV Data fetch error: \(error)")
        }
        
        isLoading = false
        isCurrentlyFetching = false
    }
    
    func getRelativeTimeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: lastUpdateTime, relativeTo: Date())
    }
}
