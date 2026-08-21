import SwiftUI
import SwiftData
import Charts

struct ChartPoint: Identifiable {
    let id: UUID
    let date: Date
    let value: Double
}

struct AnalyticsView: View {
    @Query(sort: \Weight.date, order: .reverse) private var weights: [Weight]
    @Environment(\.modelContext) private var modelContext
    
    @State private var chartData: [ChartPoint]?
    @State private var errorMessage: String?
    @State private var weeklyDateRange: DateInterval = .init(start: .now, end: .now)
    @State private var totalWeight: Double?
    @State private var averageWeight: Double?
    
    private let dateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        return formatter
    }()
    
    var body: some View {
        VStack {
            InlineTitle(text: "Analytics") {}
                .padding(.top, 32)
            
            VStack(alignment: .leading, spacing: 24) {
                if weeklyDateRange != DateInterval(start: .now, end: .now) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(weeklyDateRange.start, formatter: dateFormat) - \(weeklyDateRange.end, formatter: dateFormat)")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Weight fluctuations during the week")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                
                if let data = chartData {
                    Chart {
                        ForEach(data) { item in
                            BarMark(
                                x: .value("Date", item.date, unit: .day),
                                y: .value("Weight", item.value),
                                width: .ratio(0.5)
                            )
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [.mint, .blue, .purple],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                        }
                    }
                    .chartXScale(domain: weeklyDateRange.start...weeklyDateRange.end)
                    .chartYAxis {
                        AxisMarks { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let v = value.as(Double.self) {
                                    Text("\(v, format: .number.precision(.fractionLength(2))) kg")
                                }
                            }
                        }
                    }
                    .chartYScale(domain: .automatic(includesZero: true, reversed: false))
                    .frame(height: 300)
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.quinary.opacity(0.6))
            )
            
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("Total")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Text(totalWeight ?? 0, format: .number.precision(.fractionLength(2)))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.primary)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.quinary.opacity(0.6))
                )
                
                VStack(alignment: .leading) {
                    Text("Average")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Text(averageWeight ?? 0, format: .number.precision(.fractionLength(2)))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.primary)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.quinary.opacity(0.6))
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .task {
            getDateRange()
            let fetchData = getItems()
            
            switch fetchData {
            case .success(let data):
                if let data = data {
                    chartData = transForm(data: data)
                    
                    totalWeight = getTotalWeight(for: data)
                    averageWeight = getAverage(for: totalWeight ?? 1)
                }
            case .failure(let err):
                errorMessage = err.localizedDescription
            }
        }
    }
    
    private func getAverage(for total: Double) -> Double {
        guard let chartData = chartData else {
            return total / 7
        }
        
        return total / Double(chartData.count)
    }
    
    private func getTotalWeight(for data: [Weight]) -> Double {
        return data.map(\.value).reduce(0, +)
    }
    
    private func getDateRange(for date: Date = Date.now) {
        guard let weeklyDateRange = Calendars.getISO8601WeeklyDateRange(for: date) else {
            return
        }
        
        self.weeklyDateRange = weeklyDateRange
    }
    
    private func transForm(data: [Weight]) -> [ChartPoint] {
        guard let minValue = data.map({ $0.value }).min() else { return [] }
        
        let result = data.map {
            ChartPoint(id: $0.id, date: $0.date, value: $0.value - minValue)
        }

        return result
    }
    
    private func getItems() -> Result<[Weight]?, Error> {
        let descriptor = FetchDescriptor<Weight>(
            predicate: #Predicate { $0.date >= weeklyDateRange.start && $0.date <= weeklyDateRange.end },
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
