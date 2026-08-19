import SwiftUI

struct HistoryTableCell: View {
    let data: Weight
    let symbol: String
    let color: Color
    let delta: Double
    
    init(data: Weight, symbol: String, color: Color, delta: Double = 0) {
        self.data = data
        self.symbol = symbol
        self.color = color
        self.delta = delta
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: symbol)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24, alignment: .center)
                .foregroundStyle(color)
            
            VStack(alignment: .leading) {
                Text("\(data.value, format: .number.precision(.fractionLength(2))) kg")
                    .font(.system(size: 24, weight: .bold))
                
                Text("@\(data.date, format: .dateTime)")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if delta != 0 {
                Text(delta, format: .number.sign(strategy: .always()).precision(.fractionLength(2)))
                    .foregroundStyle(color)
            }
        }
    }
}
