import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @Query(sort: \Weight.date, order: .reverse) private var weightHistory: [Weight]
    @Environment(\.modelContext) private var modelContext
    @State private var vm = AnalyticsViewModel()

    var body: some View {
        VStack {
            InlineTitle(text: "Analytics") {}
                .padding(.top, 32)

            Picker("Filter", selection: $vm.selectedFilter) {
                ForEach(DataFilter.allCases, id: \.self) { filter in
                    Text(filter.title).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            
            Card(spacing: 24) {
                if vm.dateRange != DateInterval(start: .now, end: .now) {
                    ChartTitle(
                        dateRange: vm.dateRange,
                        period: vm.selectedFilter
                    )
                }
                
                if let chartPoints = vm.chartPoints,
                    !chartPoints.isEmpty
                {
                    BarChart(
                        data: chartPoints,
                        period: vm.selectedFilter
                    )
                }
            }
            
            MetricsCard(
                total: vm.totalWeight ?? 0,
                average: vm.averageWeight ?? 0
            )
            
            Spacer()
            
            #if DEBUG
            HStack(alignment: .center) {
                Button("Seed") {
                    modelContext.seedYearOfWeights()
                    reloadData()
                }
                .tint(.blue)
                
                Button("Clear") {
                    modelContext.deleteAllWeights()
                    reloadData()
                }
                .tint(.red)
            }
            #endif
        }
        .padding(.horizontal, 16)
        .task {
            reloadData()
        }
        .onChange(of: vm.dateRange) {
            reloadData()
        }
    }
}

extension AnalyticsView {
    private func reloadData() {
        let fetchData = getItems()
        
        switch fetchData {
        case .success(let data):
            if let data = data {
                vm.setWeights(with: data)
            }
        case .failure(let err):
            vm.errorMessage = err.localizedDescription
        }
    }
    
    private func getItems() -> Result<[Weight]?, Error> {
        let startDate = vm.dateRange.start
        let endDate = vm.dateRange.end
        
        let descriptor = FetchDescriptor<Weight>(
            predicate: #Predicate { $0.date >= startDate && $0.date < endDate },
            sortBy: [SortDescriptor(\.date)]
        )
        
        do {
            let data = try modelContext.fetch(descriptor)
            
            return .success(data)
        } catch {
            return .failure(error)
        }
    }
}

#Preview {
    AnalyticsView()
        .modelContainer(for: Weight.self, inMemory: false)
}
