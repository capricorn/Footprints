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
    @State var sessions: [SessionModel] = []
    @State private var sessionSubscriber: AnyDatabaseCancellable?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Sessions")
                    .font(.title)
                ForEach(sessions) { session in
                    SessionListItemView(sessionItem: session)
                        .padding()
                }
                Spacer()
            }
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
                        
                        try! SessionModel(id: UUID(), startTimestamp: startTime, endTimestamp: endTime).insert(db)
                    }
                }
            }
    }
}

#Preview {
    PreviewView()
        .environment(\.databaseQueue, try! .createTemporaryDBQueue())
}
