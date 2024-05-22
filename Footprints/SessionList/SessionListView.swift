//
//  SessionListView.swift
//  Footprints
//
//  Created by Collin Palmer on 4/9/24.
//

import SwiftUI
import GRDB
import Combine

struct SessionListView: View {
    @Environment(\.databaseQueue) var dbQueue: DatabaseQueue
    @AppStorage(SessionListViewModel.SortDirection.defaultsKey) var sortDirection: SessionListViewModel.SortDirection = .ascending
    @AppStorage(SessionListViewModel.SortField.defaultsKey) var sortField: SessionListViewModel.SortField = .startDate
    @StateObject var model: SessionListViewModel = SessionListViewModel()
    // TODO: Migrate to vm
    @State var sessions: [SessionModel] = []
    
    var exportDataView: some View {
        HStack {
            Button("Export", systemImage: "square.and.arrow.up") {
                model.presentExportOptions = true
            }
            .padding()
            Spacer()
        }
    }
    
    var sortedUngroupedSessions: [SessionModel] {
        sessions.sorted(using: sortField.comparator(sortDirection: sortDirection))
    }
    
    var sortDirectionSystemName: String {
        (sortDirection == .ascending) ? "arrow.up" : "arrow.down"
    }
    
    /// Sessions sorted and grouped by month.
    var groupedSessions: [Date: [SessionModel]] {
        sessions
            .sorted(using: sortField.comparator(sortDirection: sortDirection))
            .groupBy({ $0.startDate.firstOfMonth })
    }
    
    /// A list of months in which sessions occurred, sorted.
    var groupedSessionDates: [Date] {
        groupedSessions
            .keys
            .sorted(using: KeyPathComparator(\.self, order: sortDirection.order))
    }
    
    var sortFieldPicker: some View {
        // TODO: Display filter logo as well..?
        Picker("Sort Field", systemImage: "line.3.horizontal.decrease.circle", selection: $sortField) {
            ForEach(SessionListViewModel.SortField.allCases) { field in
                Text(field.label)
                    .tag(field)
            }
        }
    }
    
    var sessionsCSVTransferable: GRDBToCSVTransferable<SessionModel, SessionCSV> {
        GRDBToCSVTransferable(
            dbQueue: dbQueue,
            filename: { "footprints_sessions_\(Date.now.formatted(.iso8601.timeSeparator(.omitted)))" },
            codableMap: { SessionCSV.from($0) })
    }
    
    var listHeader: some View {
        HStack {
            Text("Sessions")
                .font(.title)
                .padding()
            Spacer()
            // TODO: Scale with font size?
            HStack {
                sortFieldPicker
                // TODO: Based on ascending/descending toggle
                Image(systemName: sortDirectionSystemName)
                    .onTapGesture {
                        // TODO: 90 degrees rotation animation?
                        sortDirection = sortDirection.toggle()
                    }
            }
            .padding()
        }
    }
    
    var dateSortView: some View {
        List {
            ForEach(groupedSessionDates, id: \.self) { (date: Date) in
                // TODO: Move header elsewhere
                Section(header: Text("\(date.formatted(.monthYearShort))").font(.subheadline.weight(.light))) {
                    ForEach(groupedSessions[date]!, id: \.self.id) { (session: SessionModel) in
                        SessionListItemView(sessionItem: session)
                    }
                    .onDelete { indexSet in
                        do {
                            try model.deleteSessionsFromList(sessions: groupedSessions[date]!, indices: indexSet, dbQueue: dbQueue)
                        } catch {
                            print("Failed to delete session(s): \(error)")
                        }
                    }
                 }
            }
        }
    }
    
    var ungroupedSortView: some View {
        List {
            ForEach(sortedUngroupedSessions, id: \.self.id) { session in
                SessionListItemView(sessionItem: session)
            }
            .onDelete { indexSet in
                do {
                    try model.deleteSessionsFromList(sessions: sortedUngroupedSessions, indices: indexSet, dbQueue: dbQueue)
                } catch {
                    print("Failed to delete session(s): \(error)")
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            listHeader
            if sortField == .startDate {
                dateSortView
            } else {
                ungroupedSortView
            }
            Spacer()
            exportDataView
        }
        .onAppear {
            sessions = (try? model.session(sort: sortField, direction: sortDirection, dbQueue: dbQueue)) ?? []
        }
        .confirmationDialog("Export", isPresented: $model.presentExportOptions) {
            ShareLink(item: dbQueue.url) {
                Text("Export SQLite")
            }
            // TODO: Some sort of accurate preview..?
            ShareLink(item: sessionsCSVTransferable, preview: SharePreview("sessions.csv")) {
                Text("Export CSV")
            }
        }
    }
}

private struct PreviewView: View {
    @Environment(\.databaseQueue) var dbQueue: DatabaseQueue
    
    var body: some View {
        SessionListView()
            .onAppear {
                try! dbQueue.write { db in
                    for _ in 0..<5 {
                        let startTime = Date.now.timeIntervalSince1970
                        let endTime = Date.now.addingTimeInterval(342).timeIntervalSince1970
                        
                        try! SessionModel(
                            id: UUID(),
                            startTimestamp: startTime,
                            endTimestamp: endTime,
                            count: Int.random(in: 0...50)).insert(db)
                    }
                }
            }
    }
}

#Preview {
    PreviewView()
        .environment(\.databaseQueue, try! .createTemporaryDBQueue())
}
