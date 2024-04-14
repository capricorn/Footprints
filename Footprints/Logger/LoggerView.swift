//
//  LoggerView.swift
//  Footprints
//
//  Created by Collin Palmer on 3/22/24.
//

import SwiftUI
import GRDB
import Combine

struct LoggerView: View {
    @Environment(\.databaseQueue) var dbQueue: DatabaseQueue
    @StateObject var model: LoggerViewModel = LoggerViewModel()
    
    // TODO: Eventually replace with `onReceive` equivalent
    @State private var locSubscriber: AnyCancellable?
    
    /// The number of points recorded in this session.
    var pointsCountLabel: String {
        (model.pointsCount == 1) ? "1 point" : "\(model.pointsCount) points"
    }
    
    var speedLabel: String {
        // TODO: Allow switching units (perhaps report speed as measurement?
        if model.speed == LoggerViewModel.SPEED_UNDETERMINED {
            return "-- mph"
        } else {
            return "\(String(format: "%.1f", model.speed)) mph"
        }
    }
    
    var totalDistanceLabel: String {
        "\(String(format: "%.02f", model.distance)) mi"
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text(model.runtimeLabel)
                HStack {
                    Text(speedLabel)
                    Text(totalDistanceLabel)
                }
                Text(pointsCountLabel)
                    .font(.caption)
            }
            .font(.system(size: 32))
            VStack {
                // TODO: At 1/3 boundary
                Spacer()
                Image(systemName: "record.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    .foregroundColor(model.recordButtonForegroundColor)
                    .onTapGesture(perform: model.record)
                    .animation(.easeInOut, value: model.recording)
            }
        }
        .onAppear {
            model.requestAuthorization()
            self.locSubscriber = model.locationPublisher.cachePrevious().sink { prevLoc, loc in
                do {
                    print("Received location update: \(loc)")
                    try model.recordLocation(loc, prevLoc: prevLoc)
                    
                    // TODO: Method for updating statistics
                    // TODO: Method for clearing statistics
                    let mph = Measurement<UnitSpeed>(value: loc.speed, unit: .metersPerSecond)
                    model.speed = mph.converted(to: .milesPerHour).value
                } catch {
                    print("Failed to record location: \(error)")
                }
            }
        }
    }
}

private struct PreviewView: View {
    @StateObject var model: LoggerViewModel = LoggerViewModel(gpsProvider: LoggerMockGPSProvider())
    @Environment(\.databaseQueue) var dbQueue: DatabaseQueue
    
    var dbName: String {
        URL(filePath: dbQueue.path).lastPathComponent
    }
    
    var body: some View {
        VStack {
            Text("DB: \(dbName)")
            LoggerView(model: model)
        }
    }
}

#Preview {
    PreviewView()
        .environment(\.databaseQueue, try! DatabaseQueue.createTemporaryDBQueue())
}
