//
//  SessionListItemView.swift
//  Footprints
//
//  Created by Collin Palmer on 4/9/24.
//

import SwiftUI
import GRDB

struct SessionListItemView: View {
    @Environment(\.databaseQueue) var dbQueue
    var sessionItem: SessionModel
    
    var dateLabel: String {
        let startDate = Date(timeIntervalSince1970: TimeInterval(sessionItem.startTimestamp))
        let endDate = Date(timeIntervalSince1970: TimeInterval(sessionItem.endTimestamp))
        
        return "\(startDate.formatted(.dateTime)) - \(endDate.formatted(.dateTime))"
    }
    
    var countLabel: String {
        (sessionItem.count == 1) ? "point" : "points"
    }
    
    // TODO: Support different units
    var distanceLabel: String {
        "\(String(format: "%.2f", sessionItem.totalDistance)) mi"
    }
    
    var runtimeLabel: String {
        (sessionItem.totalLogTime ?? .zero).duration.formatted(.time(pattern: .hourMinuteSecond))
    }
    
    var sessionTransferable: SessionModelTransferable {
        // TODO: Swap out with dbQueue reference instead
        try! dbQueue.read { db in
            SessionModelTransferable(db: db, session: sessionItem)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dateLabel)
                .lineLimit(1)
            Text(sessionItem.id.uuidString)
                .font(.caption)
                .monospaced()
            Text(runtimeLabel)
                .font(.caption)
                .monospaced()
            HStack {
                Group {
                    Text("\(sessionItem.count) \(countLabel)")
                    Text(distanceLabel)
                }
                .font(.caption)
                Spacer()
                ShareLink(item: sessionTransferable, preview: SharePreview("TODO")) {
                    Text("GPX")
                        .font(.caption.smallCaps())
                }
            }
        }
        .padding()
    }
}

#Preview {
    SessionListItemView(sessionItem: SessionModel(
        id: UUID(),
        startTimestamp: Float(Date.now.timeIntervalSince1970),
        endTimestamp: Float(Date.now.addingTimeInterval(600).timeIntervalSince1970), 
        count: 5))
}
