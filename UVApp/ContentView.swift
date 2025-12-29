import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = UVViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    if viewModel.isLoading && viewModel.locations.isEmpty {
                        ProgressView("Loading UV data...")
                            .padding()
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                            Text(error)
                                .multilineTextAlignment(.center)
                                .padding()
                            Button("Retry") {
                                Task {
                                    await viewModel.fetchData()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    } else {
                        VStack(spacing: 0) {
                            // Header with last update time
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("UV Index")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    Text("Last updated \(viewModel.getRelativeTimeString())")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if viewModel.isLoading {
                                    ProgressView()
                                }
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground).opacity(0.8))
                            
                            // Location list
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.locations) { location in
                                        LocationRowView(location: location)
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
