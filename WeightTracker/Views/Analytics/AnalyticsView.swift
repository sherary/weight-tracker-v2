import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @Query(sort: \Weight.date, order: .reverse) private var weights: [Weight]
    @Environment(\.modelContext) private var modelContext
    @StateObject private var vm = AnalyticsViewModel()

    var body: some View {
        VStack {
            InlineTitle(text: "Analytics") {}
                .padding(.top, 32)

            Card(spacing: 24) {
                if vm.weeklyDateRange != DateInterval(start: .now, end: .now) {
                    chartTitle(weeklyRange: vm.weeklyDateRange)
                }
                
                if let data = vm.chartData {
                    BarChart(data: data, dateRange: vm.weeklyDateRange)
                }
            }
            
            metricCard
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .task {
            vm.getDateRange()
            let fetchData = getItems()
            
            switch fetchData {
            case .success(let data):
                if let data = data {
                    vm.chartData = vm.transForm(data: data)
                    vm.totalWeight = vm.getTotalWeight(for: data)
                    
                    guard let totalWeight = vm.totalWeight else { return }
                    vm.averageWeight = vm.getAverage(for: totalWeight)
                }
            case .failure(let err):
                vm.errorMessage = err.localizedDescription
            }
        }
    }
      
    private func chartTitle(weeklyRange: DateInterval) -> some View {
        return HStack {
            VStack(alignment: .leading) {
                Text("\(weeklyRange.start, formatter: FormatterService.Date.shortMonth) - \(weeklyRange.end, formatter: FormatterService.Date.shortMonth)")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("Weight fluctuations during the week")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var metricCard: some View {
        return HStack(alignment: .center) {
            Card {
                Text("Total")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text(vm.totalWeight ?? 0, format: .number.precision(.fractionLength(2)))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
            }
            
            Card {
                Text("Average")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text(vm.averageWeight ?? 0, format: .number.precision(.fractionLength(2)))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
            }
        }
    }
}

extension AnalyticsView {
    private func getItems() -> Result<[Weight]?, Error> {
        let startDate = vm.weeklyDateRange.start
        let endDate = vm.weeklyDateRange.end
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
