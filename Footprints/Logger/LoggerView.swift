//
//  LoggerView.swift
//  Footprints
//
//  Created by Collin Palmer on 3/22/24.
//

import SwiftUI

struct LoggerView: View {
    @StateObject var model: LoggerViewModel
    
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
    }
}

#Preview {
    LoggerView(model: LoggerViewModel())
}
