import SwiftUI

struct MetricsCard: View {
    let total: Double
    let average: Double
    
    var body: some View {
        HStack(alignment: .center) {
            Card {
                Text("Total")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text(total, format: .number.precision(.fractionLength(2)))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
            }
            
            Card {
                Text("Average")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text(average, format: .number.precision(.fractionLength(2)))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
            }
        }
    }
}

