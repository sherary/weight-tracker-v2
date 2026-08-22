import SwiftUI
import Charts

struct BarChart: View {
    let data: [ChartPoint]
    var dateRange: DateInterval = .init(start: .now, end: .now)
    
    var body: some View {
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
        .chartXScale(domain: dateRange.start...dateRange.end)
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
