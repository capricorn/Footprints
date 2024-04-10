//
//  ContentView.swift
//  Footprints
//
//  Created by Collin Palmer on 3/22/24.
//

import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    enum Navigation: String, CaseIterable, Identifiable {
        case logger
        case sessions
        
        var id: Self {
            self
        }
    }
    
    var body: some View {
        // TODO: NavigationSplitView?
        // Setup a navigation link
        NavigationSplitView(sidebar: {
            // **TODO: Implement as list**
            //Text("test")
            ForEach(Navigation.allCases) { selection in
                //Text("\(selection.rawValue)")
                NavigationLink(selection.rawValue, destination: {
                    //Text("\(selection.rawValue)")
                    switch selection {
                    case .logger:
                        LoggerView()
                    case .sessions:
                        SessionListView()
                    }
                })
            }
        }, detail: {
            // TODO: Handle navigation here
            Text("Placeholder")
            //LoggerView()
            //switch
        })
        /*
        NavigationStack {
            // Does this require specifying a separate navigation pane?
            NavigationLink(destination: {
                LoggerView()
            }, label: { Text("Test")})
            /*
            Text("Test1")
                .navigatio
             */
            
        }
         */
    }
}

#Preview {
    ContentView()
}
