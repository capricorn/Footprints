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
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
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

#Preview {
    LoggerView(model: LoggerViewModel())
}
