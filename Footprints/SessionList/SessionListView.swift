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
    @AppStorage(SortDirection.defaultsKey) var sortDirection: SortDirection = .ascending
    @AppStorage(SortField.defaultsKey) var sortField: SortField = .startDate
    @State var sessions: [SessionModel] = []
    @State private var sessionSubscriber: AnyDatabaseCancellable?
    
    enum SortDirection: String {
        static let defaultsKey = "SortDirection"
        case ascending
        case descending
        
        // TODO: Bool instead?
        func toggle() -> SortDirection {
            (self == .ascending) ? .descending : .ascending
        }
    }
    
    enum SortField: String {
        static let defaultsKey = "SortField"
        /// Total time that the session was recorded
        case runtime
        /// Date of session start
        case startDate
        /// The total distance traveled
        case distance
    }
    
    var exportDataView: some View {
        HStack {
            ShareLink(item: dbQueue.url) {
                Text("Export Data")
            }
            .padding()
            Spacer()
        }
    }
    
    var sortDirectionSystemName: String {
        (sortDirection == .ascending) ? "arrow.up" : "arrow.down"
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Sessions")
                    .font(.title)
                    .padding()
                Spacer()
                // TODO: Scale with font size?
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .onTapGesture {
                            // TODO -- filter popup menu
                        }
                    // TODO: Based on ascending/descending toggle
                    Image(systemName: sortDirectionSystemName)
                        .onTapGesture {
                            // TODO: 90 degrees rotation animation?
                            sortDirection = sortDirection.toggle()
                        }
                }
                .padding()
            }
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(sessions) { session in
                        SessionListItemView(sessionItem: session)
                            .padding()
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
    }
}

private struct PreviewView: View {
    @Environment(\.databaseQueue) var dbQueue: DatabaseQueue
    
    var body: some View {
        SessionListView()
            .onAppear {
                try! dbQueue.write { db in
                    for _ in 0..<5 {
                        let startTime = Float(Date.now.timeIntervalSince1970)
                        let endTime = Float(Date.now.addingTimeInterval(342).timeIntervalSince1970)
                        
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
