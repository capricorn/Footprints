//
//  SessionListItemView.swift
//  Footprints
//
//  Created by Collin Palmer on 4/9/24.
//

import SwiftUI

struct SessionListItemView: View {
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
                Button(action: {
                    // TODO
                    // TODO -- should actually be a share action?
                }) {
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
