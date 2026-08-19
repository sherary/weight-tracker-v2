import SwiftUI
import SwiftData

struct WeightSheet: View {
    var id: UUID
    let onSave: ((Weight) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var data: Weight = Weight()
    
    private let dateRange: ClosedRange<Date> = {
        let now = Date.now
        var fiscalYear = DateComponents()
        fiscalYear.year = Calendar.current.component(.year, from: now)
        fiscalYear.month = 1
        fiscalYear.day = 1
        
        guard let startingDate = Calendar.current.date(from: fiscalYear) else {
            return now...(Calendar.current.date(byAdding: .day, value: 7, to: now) ?? Date.now)
        }
        
        return startingDate...now
    }()
    
    init(id: UUID? = nil, onSave: @escaping (Weight) -> Void) {
        if let id = id {
            self.id = id
            _data = State(initialValue: Weight())
            self.onSave = onSave
        } else {
            self.id = UUID()
            self.onSave = onSave
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Weight Form")
                .font(.system(size: 24, weight: .bold))
                .padding(.bottom, 16)
            
            VStack(alignment: .leading) {
                Text("Weight")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundStyle(.primary.opacity(0.8))
                
                TextField("55,5", value: $data.value, format: .number.precision(.fractionLength(2)))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.mint, lineWidth: 0.8)
                    )
            }
            .padding(.bottom, 24)
            
            ZStack {
                VStack(alignment: .leading) {
                    Text("Date")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(.primary.opacity(0.8))
                    
                    Text(data.date, format: .dateTime)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.mint, lineWidth: 0.8)
                        )
                }
                .zIndex(0)
                
                GeometryReader { proxy in
                    DatePicker(
                        "Date",
                        selection: $data.date,
                        in: dateRange,
                        displayedComponents: .date
                    )
                        .labelsHidden()
                        .fixedSize()
                        .scaleEffect(x: proxy.size.width, y: proxy.size.height / 34, anchor: .center)
                        .opacity(0.011)
                }
                .frame(height: 48)
                .contentShape(Rectangle())
                .zIndex(1)
                .offset(y: 20)
            }
            .padding(.bottom, 24)
            
            Button {
                if let onSave = onSave {
                    onSave(data)
                }
                
                dismiss()
            } label: {
                Label("Save", systemImage: "folder")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.mint)
                    )
            }
            .disabled(data.value.isNaN)
            .padding(.vertical, 16)
        }
        .presentationDetents([.fraction(0.7)])
        .presentationBackground(Color.white)
    }
}
