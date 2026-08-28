import SwiftUI
import Charts

struct BarChart: View {
    let data: [ChartPoint]
    let period: Period
    
    private var labels: ChartAxisLabels {
        let y = AxisLabelY.weight
        switch period {
        case .weekly:  return ChartAxisLabels(x: .week,  y: y)
        case .monthly: return ChartAxisLabels(x: .month, y: y)
        case .yearly:  return ChartAxisLabels(x: .year,  y: y)
        }
    }
    
    var body: some View {
        Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value(labels.x.description, item.label),
                    y: .value(labels.y.description, item.value),
                    width: .ratio(0.8)
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
        .chartXScale(domain: data.map(\.label))
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
