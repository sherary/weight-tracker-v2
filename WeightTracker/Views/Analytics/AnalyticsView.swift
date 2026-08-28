import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    var onEmptyView: (() -> Void)?
    
    @Query(sort: \Weight.date, order: .reverse) private var weightHistory: [Weight]
    @Environment(\.modelContext) private var modelContext
    @State private var vm = AnalyticsViewModel()

    var body: some View {
        VStack {
            InlineTitle(text: "Analytics") {}
                .padding(.top, 32)

            Picker("Filter", selection: $vm.period) {
                ForEach(Period.allCases, id: \.self) { filter in
                    Text(filter.title).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            
            if let chartPoints = vm.chartPoints {
                Card(spacing: 24) {
                    ChartTitle(
                        dateRange: vm.dateRange,
                        period: vm.period
                    )
                    
                    BarChart(
                        data: chartPoints,
                        period: vm.period
                    )
                }
                
                MetricsCard(
                    total: vm.totalWeight ?? 0,
                    average: vm.averageWeight ?? 0
                )
            } else {
                EmptyAnalyticsView {
                    if let onEmptyView = onEmptyView {
                        onEmptyView()
                    }
                }
            }
            
            Spacer()
            
            #if DEBUG && targetEnvironment(simulator)
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
