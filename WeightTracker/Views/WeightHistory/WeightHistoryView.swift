import SwiftUI
import SwiftData

struct WeightHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Weight.date, order: .reverse) private var weightHistories: [Weight]
    
    @State private var vm = WeightHistoryViewModel()
    @State private var destinations: HistoryDestination? = nil
    
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
    
    private var weights: [Weight] {
        let start = vm.dateRange.start
        let end = vm.dateRange.end
        
        return weightHistories.filter { $0.date >= start && $0.date < end }
    }
    // VIEW PROPS
    
    var body: some View {
        Group {
            if let message = vm.errorMessage, !message.isEmpty {
                ErrorView(text: message) {
                    vm.errorMessage = nil
                }
            } else {
                VStack(alignment: .leading) {
                    InlineTitle(text: "Weight Histories") {
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
                    
                    Picker("Filter", selection: $vm.selectedFilter) {
                        ForEach(DataFilter.allCases, id: \.self) { filter in
                            Text(filter.title).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    
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
                                SwipableIcon(
                                    symbol: "square.and.pencil",
                                    tint: .blue,
                                    onSave: {
                                        editById(id: row.id)
                                    }
                                )
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                SwipableIcon(
                                    symbol: "trash",
                                    tint: .red,
                                    onSave: {
                                        vm.selectedWeight = getItem(by: row.id)
                                    }
                                )
                            }
                            .onTapGesture {
                                editById(id: row.id)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .multipleChoiceAlert(
                        title: "Delete Item",
                        data: $vm.selectedWeight,
                        type: .delete,
                        onConfirm: deleteAlertOnConfirm,
                        onCancel: deleteAlertOnCancel,
                        message: { item in
                            Text("Are you sure you want to delete entry @\(item.date, format: .dateTime)?")
                        }
                    )
                }
                .sheet(item: $destinations) { destination in
                    Group {
                        switch destination {
                        case .add:
                            WeightSheet { weight in
                                if isExist(by: weight.date) {
                                    vm.weightToEdit = weight
                                    
                                    return
                                }
                                
                                save(data: weight)
                                commit()
                            }
                        case .edit(let data):
                            WeightSheet(id: data.id, onSave: nil)
                        }
                    }
                    .padding()
                }
                .multipleChoiceAlert(
                    title: "Cannot Proceed",
                    data: $vm.weightToEdit,
                    type: .choice("Change"),
                    onConfirm: replaceAlertOnConfirm,
                    onCancel: replaceAlertOnCancel,
                    message: { item in
                        Text("Your item for today already exists. Would you like to replace the old one?")
                    }
                )
            }
        }
        .padding(.horizontal, 16)
    }
}

extension WeightHistoryView {
    fileprivate func editById(id: UUID) {
        if let data = getItem(by: id) {
            destinations = .edit(data)
        }
    }
    
    fileprivate func replaceAlertOnConfirm() {
        guard let data = vm.weightToEdit else { return }
        
        let target = Calendar.current.startOfDay(for: data.date)
        let descriptor = FetchDescriptor<Weight>(
            predicate: #Predicate { $0.date == target },
            sortBy: [SortDescriptor(\.date)]
        )
        
        do {
            if let item = try modelContext.fetch(descriptor).first {
                item.value = data.value
                item.date = data.date
            } else {
                save(data: data)
            }
            
            commit()
        } catch {
            // I know it's a silent error handling,
            // which is pointless,
            // but at this point,
            // user does not need to know what happened to the data 🤷🏻‍♀️
            modelContext.rollback()
        }
    }
    
    fileprivate func replaceAlertOnCancel() {
        vm.selectedWeight = nil
    }
    
    fileprivate func deleteAlertOnConfirm() {
        guard let data = vm.selectedWeight,
            let index = findIndex(id: data.id) else { return }
        
        delete(offsets: IndexSet(integer: index))
        commit()
        
        vm.selectedWeight = nil
    }
    
    fileprivate func deleteAlertOnCancel() {
        vm.selectedWeight = nil
    }
    
    fileprivate func findIndex(id: UUID) -> Int? {
        return weights.firstIndex(where: { $0.id == id })
    }
    
    fileprivate func getItem(by id: UUID) -> Weight? {
        if let index = findIndex(id: id) {
            return weights[index]
        }
        
        return nil
    }
    
    fileprivate func isExist(by date: Date) -> Bool {
        return weightHistories.contains {
            Calendar.current.isDate(
                $0.date,
                equalTo: date,
                toGranularity: .day
            )
        }
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
            vm.errorMessage = error.localizedDescription
            
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
