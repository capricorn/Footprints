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
    @State private var sessionSubscriber: AnyDatabaseCancellable?
    
    var exportDataView: some View {
        HStack {
            Button("Export", systemImage: "square.and.arrow.up") {
                model.presentExportOptions = true
            }
            .padding()
            Spacer()
        }
    }
    
    var sortDirectionSystemName: String {
        (sortDirection == .ascending) ? "arrow.up" : "arrow.down"
    }
    
    var sortedSessions: [SessionModel] {
        (try? model.session(sort: sortField, direction: sortDirection, dbQueue: dbQueue)) ?? []
    }
    
    var groupedSessions: [Date: [SessionModel]] {
        sortedSessions.groupBy({ $0.startDate.firstOfMonth })
    }
    
    var groupedSessionDates: [Date] {
        groupedSessions.keys.sorted()
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
    
    var body: some View {
        VStack {
            listHeader
            ScrollView {
                VStack(alignment: .leading) {
                    // TODO: Necessary to sort keys..?
                    ForEach(groupedSessionDates, id: \.self) { (date: Date) in
                        VStack {
                            Section {
                                // TODO: Custom Formatter
                                Text("\(date.formatted(.dateTime))")
                            }
                            ForEach(groupedSessions[date]!, id: \.self.id) { (session: SessionModel) in
                                SessionListItemView(sessionItem: session)
                            }
                        }
                    }
                }
            }
            Spacer()
            exportDataView
        }
        .onAppear {
            // TODO: Move to vm
            let sessionObserver = ValueObservation.tracking { db in
                try! SessionModel.fetchAll(db)
            }
            
            sessionSubscriber = sessionObserver.start(in: dbQueue, onError: { error in
                print("DB error: \(error)")
            }, onChange: { sessions in
                self.sessions = sessions
            })
            
            // TODO: Eventually migrate to lazy vstack for these
            sessions = try! dbQueue.read { db in
                try! SessionModel.fetchAll(db)
            }
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
