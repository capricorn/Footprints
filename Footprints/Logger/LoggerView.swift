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
        if model.speed < 0 {
            return "-- mph"
        } else {
            return "\(String(format: "%.1f", model.speed)) mph"
        }
    }
    
    var totalDistanceLabel: String {
        "\(String(format: "%.02f", model.distance)) mi"
    }
    
    var bgGradient: LinearGradient {
        LinearGradient(colors: [.accent, .darkAccent], startPoint: .top, endPoint: .bottom)
    }
    
    var runtimeView: some View {
        VStack {
            Group {
                if model.recordingComplete {
                    Text(model.runtimeLabel)
                        .phaseAnimator([0,1]) { view, phase in
                            view.opacity(phase)
                        }
                } else {
                    Text(model.runtimeLabel)
                        .contentTransition(.numericText())
                }
            }
            .padding()
        }
        //.padding()
        .font(.custom("Impact", size: 200).monospaced())
        .scaledToFit()
        .minimumScaleFactor(0.1)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // TODO: Work on palette
        //.foregroundStyle(.white.opacity(0.95))
        .foregroundStyle(Color.accent)
        .background { Color.foreground }
        //.background { Color.accent }
        //.clipShape(RoundedRectangle(cornerRadius: 10))
        // TODO: Gradient instead..?
    }
    
    var statisticsView: some View {
        HStack {
            VStack {
                Text("PACE")
                    .font(.body.smallCaps())
                Text("--")  // TODO: Live estimated pace
            }
            .frame(maxWidth: .infinity)
            VStack {
                Text("DISTANCE")
                    .font(.body.smallCaps())
                Text(totalDistanceLabel)
            }
            .frame(maxWidth: .infinity)
            VStack {
                Text("SPEED")
                    .font(.body.smallCaps())
                Text(speedLabel)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    var body: some View {
        ZStack {
            GeometryReader { reader in
                VStack {
                    runtimeView
                        .frame(maxWidth: .infinity, maxHeight: reader.size.height/8)
                        //.background { bgGradient }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding()
                        //.padding(.bottom)
                        //.ignoresSafeArea([.container])
                        //.border(.red)
                    statisticsView
                        .frame(maxWidth: .infinity)
                    /*
                    if model.recordingComplete {
                        Text(model.runtimeLabel)
                            .phaseAnimator([0,1]) { view, phase in
                                view.opacity(phase)
                            }
                    } else {
                        Text(model.runtimeLabel)
                            .contentTransition(.numericText())
                    }
                     */
                    /*
                    HStack {
                        Text(speedLabel)
                        Text(totalDistanceLabel)
                    }
                    Text(pointsCountLabel)
                        .font(.caption)
                     */
                    
                    Spacer()
                    Image(systemName: "record.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: reader.size.width/5, height: reader.size.width/5)
                        .foregroundColor(model.recordButtonForegroundColor)
                        .onTapGesture(perform: model.record)
                        .animation(.easeInOut, value: model.recording)
                        .padding(.bottom, 8)
                }
                //.font(.system(size: 32))
                /*
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
                 */
            }
        }
        // TODO: Consider
        //.ignoresSafeArea()
        .onReceive(model.motionPublisher) { accel in
            do {
                try model.recordMotion(accel)
            } catch {
                print("Failed to record device motion: \(error)")
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
        LoggerView(model: model)
    }
}

#Preview {
    PreviewView()
        .environment(\.databaseQueue, try! DatabaseQueue.createTemporaryDBQueue())
}
