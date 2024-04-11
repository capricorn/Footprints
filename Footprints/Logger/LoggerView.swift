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
    @StateObject var model: LoggerViewModel = LoggerViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                Group {
                    if model.recording {
                        Text("\(model.elapsedLogTime ?? 0)")
                    } else {
                        Text(Date.now.formatted(.dateTime))
                    }
                }
                .font(.system(size: 32))
            }
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
        .onReceive(model.locationPublisher.cachePrevious(), perform: { prevLoc, loc in
            do {
                print("Received location update: \(loc)")
                // TODO: Take new struct that contains distance alongside loc update
                try model.recordLocation(loc, prevLoc: prevLoc)
            } catch {
                print("Failed to record location: \(error)")
            }
        })
        .onAppear {
            model.requestAuthorization()
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
