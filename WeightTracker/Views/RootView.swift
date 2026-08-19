import SwiftUI

struct RootView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Analytics", systemImage: "cellularbars", value: 0) {
                AnalyticsView()
            }
            
            Tab("Histories", systemImage: "list.bullet", value: 1) {
                WeightHistoryView()
            }
        }
    }
}

#Preview {
    RootView()
}
