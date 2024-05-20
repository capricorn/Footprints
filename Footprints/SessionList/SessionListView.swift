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
        Array(groupedSessions.keys)
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
    
    var sessionTransferable: SessionCSVTransferable {
        SessionCSVTransferable(dbQueue: dbQueue)
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
        ForEach(groupedSessionDates, id: \.self) { (date: Date) in
            VStack {
                Section {
                    // TODO: left / right rectangle divider (single pixel height); date in center
                    Text("\(date.formatted(.monthYearShort))")
                        .font(.subheadline.weight(.light))
                        .opacity(0.5)   // TODO: Font color?
                }
                ForEach(groupedSessions[date]!, id: \.self.id) { (session: SessionModel) in
                    SessionListItemView(sessionItem: session)
                }
            }
        }
    }
    
    var ungroupedSortView: some View {
        ForEach(sortedUngroupedSessions, id: \.self.id) { session in
            SessionListItemView(sessionItem: session)
        }
    }
    
    var body: some View {
        VStack {
            listHeader
            ScrollView {
                VStack(alignment: .leading) {
                    if sortField == .startDate {
                        dateSortView
                    } else {
                        ungroupedSortView
                    }
                }
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
            ShareLink(item: sessionTransferable, preview: SharePreview("sessions.csv")) {
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
