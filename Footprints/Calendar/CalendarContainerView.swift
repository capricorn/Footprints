//
//  CalendarContainerView.swift
//  Footprints
//
//  Created by Collin Palmer on 5/14/24.
//

import SwiftUI
import GRDB

struct CalendarContainerView: View {
    @Environment(\.databaseQueue) var dbQueue: DatabaseQueue
    /// The day of the month a log occurred
    @State var daysLogged: [Int] = []
    @State private var sessionSubscriber: AnyDatabaseCancellable?
    
    // TODO: Assess accuracy
    
    func collectDaysLogged() throws -> [Int] {
        let monthStartTimestamp = Calendar.current.firstOfMonth.timeIntervalSince1970
        let monthSessions = try dbQueue.read { db in
            try SessionModel
                .filter(Column("startTimestamp") > monthStartTimestamp)
                .fetchAll(db)
        }
        
        return monthSessions.map { session in
            Date(timeIntervalSince1970: session.startTimestamp).dayOfMonth
        }
    }
    
    var body: some View {
        VStack {
            CalendarView(daysLogged)
                .padding([.horizontal], 32)
                .onAppear {
                    do {
                        let sessionObserver = ValueObservation.tracking { db in
                            try! SessionModel.fetchAll(db)
                        }
                        
                        daysLogged = try collectDaysLogged()
                        sessionSubscriber = sessionObserver.start(in: dbQueue, onError: { _ in }, onChange: { _ in
                            daysLogged = try! self.collectDaysLogged()
                        })
                    } catch {
                        print("Failed to load calendar: \(error)")
                    }
                }
            Spacer()
        }
    }
}

private struct PreviewView: View {
    @Environment(\.databaseQueue) var dbQueue: DatabaseQueue
    
    var body: some View {
        CalendarContainerView()
            .onAppear {
                try! dbQueue.write { db in
                    // TODO: Use a fixed date here
                    try! SessionModel(id: UUID(), startTimestamp: Date.now.timeIntervalSince1970, endTimestamp: 0, count: 0).insert(db)
                }
            }
    }
}

#Preview {
    PreviewView()
        .environment(\.databaseQueue, try! .createTemporaryDBQueue())
}
