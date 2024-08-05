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
    @State private var presentExportOptions = false
    var sessionItem: SessionModel
    
    let dateIntervalFormatter = DateIntervalFormatter()
    
    var dateLabel: String {
        return dateIntervalFormatter.string(from: sessionItem.dateInterval)!
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
            return "--/mi"
        }
        
        return "\(pace.formatted(.minuteSecondShort))/mi"
    }
    
    var sessionTransferable: SessionModelTransferable {
        SessionModelTransferable(dbQueue: dbQueue, session: sessionItem)
    }
    
    var accelerometerCSVTransferable: GRDBToCSVTransferable<DeviceAccelerationModel, SessionAccelerometerCSV> {
        GRDBToCSVTransferable(
            dbQueue: dbQueue,
            filename: { "footprints_accel_\(sessionItem.id.uuidString)_\(Date.now.formatted(.iso8601.timeSeparator(.omitted)))" },
            codableMap: { SessionAccelerometerCSV.from($0) }, 
            recordFetcher: { db in
                try DeviceAccelerationModel
                    .filter(Column("sessionId") == sessionItem.id)
                    .fetchAll(db)
            })
    }
    
    var locCSVTransferable: GRDBToCSVTransferable<GPSLocationModel, GPSLocationCSV> {
        GRDBToCSVTransferable(
            dbQueue: dbQueue,
            filename: { "footprints_loc_\(sessionItem.id.uuidString)_\(Date.now.formatted(.iso8601.timeSeparator(.omitted)))" },
            codableMap: { GPSLocationCSV.from($0) },
            recordFetcher: { db in
                try GPSLocationModel
                    .filter(Column("sessionId") == sessionItem.id)
                    .fetchAll(db)
            })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dateLabel)
                .lineLimit(1)
                .padding(.bottom, 2)
            HStack {
                Text("\(Image(systemName: "stopwatch")) \(runtimeLabel)")
                    .padding(.trailing, 4)
                // TODO: Figure out how to rotate
                Text("\(Image(systemName: "ruler")) \(distanceLabel)")
                    .padding(.trailing, 4)
                if let paceLabel {
                    Text("\(Image(systemName: "figure.run")) \(paceLabel)")
                }
                Spacer()
            }
            .monospaced()
            .font(.caption)
            .padding(.bottom, 2)
            HStack(spacing: 4) {
                Group {
                    Text("\(sessionItem.count) \(countLabel)")
                        .padding(.trailing, 4)
                    
                    if let fiveKTime = sessionItem.fiveKTime {
                        HStack(spacing: 4) {
                            Text("5K")
                                .font(.caption.bold())
                            Text("\(fiveKTime.formatted(.minuteSecondShort))")
                                .font(.caption.monospaced())
                        }
                    }
                }
                .font(.caption)
                Spacer()
                Text("\(Image(systemName: "square.and.arrow.up"))")
                    .font(.caption.smallCaps())
                    .onTapGesture {
                        presentExportOptions = true
                    }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .confirmationDialog("Export", isPresented: $presentExportOptions) {
                ShareLink(item: sessionTransferable, preview: SharePreview("\(sessionItem.id.uuidString).gpx")) {
                    Text("Export GPX")
                }
                ShareLink(item: locCSVTransferable, preview: SharePreview("\(sessionItem.id.uuidString).csv")) {
                    Text("Export GPS CSV")
                }
                // TODO: Use proper csv name?
                ShareLink(item: accelerometerCSVTransferable, preview: SharePreview("\(sessionItem.id.uuidString).csv")) {
                    Text("Export Accelerometer CSV")
                }
        }
    }
}

#Preview("With 5k") {
    SessionListItemView(
        sessionItem: SessionModel(
            id: UUID(),
            startTimestamp: Date.now.timeIntervalSince1970,
            endTimestamp: Date.now.addingTimeInterval(600).timeIntervalSince1970,
            count: 5,
            fiveKTime: 25*60))
    .environment(\.databaseQueue, try! .createTemporaryDBQueue())
}

#Preview("Without 5k") {
    SessionListItemView(
        sessionItem: SessionModel(
            id: UUID(),
            startTimestamp: Date.now.timeIntervalSince1970,
            endTimestamp: Date.now.addingTimeInterval(600).timeIntervalSince1970,
            count: 5))
    .environment(\.databaseQueue, try! .createTemporaryDBQueue())
}
