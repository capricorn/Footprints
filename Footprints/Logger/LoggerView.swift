//
//  LoggerView.swift
//  Footprints
//
//  Created by Collin Palmer on 3/22/24.
//

import SwiftUI

struct LoggerView: View {
    @StateObject var model: LoggerViewModel
    // TODO: Provide default
    let gpsProvider: GPSProvider
    
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
        .onReceive(gpsProvider.location, perform: { loc in
            do {
                print("Received location update: \(loc)")
                try model.recordLocation(loc)
            } catch {
                print("Failed to record location: \(error)")
            }
        })
    }
}

private struct PreviewView: View {
    @StateObject var model: LoggerViewModel = LoggerViewModel()
    @StateObject var gpsProvider: LoggerMockGPSProvider = LoggerMockGPSProvider()
    
    var logCommandLabel: String {
        gpsProvider.logging ? "Stop" : "Start"
    }
    
    var body: some View {
        VStack {
            Button("\(logCommandLabel) logging") {
                if gpsProvider.logging {
                    gpsProvider.stop()
                } else {
                    gpsProvider.start()
                }
            }
            LoggerView(model: model, gpsProvider: gpsProvider)
        }
    }
}

#Preview {
    PreviewView()
}
