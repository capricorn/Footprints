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
    @Environment(\.quickActionPublisher) var quickActionPublisher
    
    enum Navigation: String, CaseIterable, Identifiable {
        case logger
        case sessions
        
        var id: Self {
            self
        }
    }
    
    // TODO: Handle this with tab view
    enum TabViewSelection: Hashable {
        case logger
        case sessions
        case calendar
    }
    
    @StateObject var loggerViewModel: LoggerViewModel = LoggerViewModel()
    @State private var tabSelection: TabViewSelection = .sessions
    
    var body: some View {
        TabView(selection: $tabSelection) {
            SessionListView()
                .tag(TabViewSelection.sessions)
                .tabItem {
                    Label("Sessions", systemImage: "list.bullet.rectangle")
                }
            LoggerView(model: loggerViewModel)
                .tag(TabViewSelection.logger)
                .tabItem {
                    Label("Logger", systemImage: "record.circle")
                }
            CalendarContainerView()
                .tag(TabViewSelection.calendar)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
        }
        .onReceive(quickActionPublisher) { action in
            switch action {
            case .record:
                tabSelection = .logger
                loggerViewModel.quickActionRecord()
            }
        }
    }
}

#Preview {
    ContentView()
}
