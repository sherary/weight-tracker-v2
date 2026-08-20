import SwiftUI
import SwiftData

struct WeightHistoryView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var errorMessage: String?
    @State private var destinations: HistoryDestination? = nil
    @State private var selectedWeight: Weight?
    @State private var toggleDeleteAlert: Bool = false
    
    @Query(sort: \Weight.date, order: .reverse) private var weights: [Weight]

    // VIEW PROPS
    fileprivate typealias Symbol = (name: String, color: Color)
    fileprivate struct WeightRow: Identifiable {
        let weight: Weight
        let delta: Double?
        var id: Weight.ID { weight.id }
    }

    fileprivate var rows: [WeightRow] {
        weights.enumerated().map { index, weight in
            let prevIndex = index + 1
            let delta = prevIndex < weights.count
                ? weight.value - weights[prevIndex].value
                : 0
            
            return WeightRow(weight: weight, delta: delta)
        }
    }
    // VIEW PROPS
    
    var body: some View {
        Group {
            if let message = errorMessage, !message.isEmpty {
                ErrorView(text: message) {
                    errorMessage = nil
                }
            } else {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Text("Weight Histories")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Button {
                            destinations = .add
                        } label: {
                            Label("Add", systemImage: "plus")
                                .labelStyle(.iconOnly)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.primary)
                        }
                    }
                    .padding(.top, 32)
                    
                    List {
                        ForEach(rows) { row in
                            let style = indicator(for: row.delta ?? 0)
                            
                            HistoryTableCell(
                                data: row.weight,
                                symbol: style.name,
                                color: style.color,
                                delta: row.delta ?? 0
                            )
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    if let data = getItem(by: row.id) {
                                        destinations = .edit(data)
                                    }
                                } label: {
                                    Image(systemName: "square.and.pencil")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    selectedWeight = getItem(by: row.id)
                                    toggleDeleteAlert.toggle()
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .alert(
                        "Delete Item",
                        isPresented: $toggleDeleteAlert,
                        actions: {
                            HStack(alignment: .center) {
                                Button("Delete", role: .destructive) {
                                    guard let data = selectedWeight,
                                        let index = findIndex(id: data.id) else { return }
                                    
                                    delete(offsets: IndexSet(integer: index))
                                    commit()
                                    
                                    selectedWeight = nil
                                    toggleDeleteAlert.toggle()
                                }
                                
                                Button("Cancel", role: .cancel) {
                                    selectedWeight = nil
                                    toggleDeleteAlert.toggle()
                                }
                            }
                    }, message: {
                        if let data = selectedWeight {
                            Text("Are you sure you want to delete entry @\(data.date, format: .dateTime)?")
                        }
                    })
                }
                .sheet(item: $destinations) { destination in
                    Group {
                        switch destination {
                        case .add:
                            WeightSheet { weight in
                                save(data: weight)
                                commit()
                            }
                        case .edit(let data):
                            WeightSheet(id: data.id, onSave: nil)
                        }
                    }
                    .padding()
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

extension WeightHistoryView {
    fileprivate func findIndex(id: UUID) -> Int? {
        return weights.firstIndex(where: { $0.id == id })
    }
    
    fileprivate func getItem(by id: UUID) -> Weight? {
        if let index = findIndex(id: id) {
            return weights[index]
        }
        
        return nil
    }
    
    fileprivate func save(data: Weight) {
        withAnimation {
            modelContext.insert(data)
        }
    }

    fileprivate func delete(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(weights[index])
            }
        }
    }
    
    fileprivate func commit() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
            
            return
        }
    }
    
    fileprivate func indicator(for delta: Double) -> Symbol {
        var symbol = Symbol(name: "square.fill", color: .secondary)
        
        if delta > 0 {
            symbol.name = "arrowtriangle.up.fill"
            symbol.color = .red
        }
        
        if delta < 0 {
            symbol.name = "arrowtriangle.down.fill"
            symbol.color = .green
        }
        
        return symbol
    }
}

#Preview {
    WeightHistoryView()
        .modelContainer(for: Weight.self, inMemory: false)
}
