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
    
    var paceLabel: String? {
        guard let pace = sessionItem.pace else {
            return "-- mile"
        }
        
        return "\(pace.formatted(.minuteSecondShort)) mile"
    }
    
    var sessionTransferable: SessionModelTransferable {
        SessionModelTransferable(dbQueue: dbQueue, session: sessionItem)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dateLabel)
                .lineLimit(1)
            Text(sessionItem.id.uuidString)
                .font(.caption)
                .monospaced()
            Text("\(Image(systemName: "stopwatch")) \(runtimeLabel)")
                .font(.caption)
                .monospaced()
            HStack {
                Group {
                    Text("\(sessionItem.count) \(countLabel)")
                    Text(distanceLabel)
                    if let paceLabel {
                        Text(paceLabel)
                    }
                }
                .font(.caption)
                Spacer()
                ShareLink(item: sessionTransferable, preview: SharePreview("\(sessionItem.id.uuidString).gpx")) {
                    Text("GPX\(Image(systemName: "location"))")
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
        startTimestamp: Date.now.timeIntervalSince1970,
        endTimestamp: Date.now.addingTimeInterval(600).timeIntervalSince1970, 
        count: 5))
}
