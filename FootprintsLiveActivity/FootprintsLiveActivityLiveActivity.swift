//
//  FootprintsLiveActivityLiveActivity.swift
//  FootprintsLiveActivity
//
//  Created by Collin Palmer on 4/25/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FootprintsLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FootprintsLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FootprintsLiveActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension FootprintsLiveActivityAttributes {
    fileprivate static var preview: FootprintsLiveActivityAttributes {
        FootprintsLiveActivityAttributes(name: "World")
    }
}

extension FootprintsLiveActivityAttributes.ContentState {
    fileprivate static var smiley: FootprintsLiveActivityAttributes.ContentState {
        FootprintsLiveActivityAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FootprintsLiveActivityAttributes.ContentState {
         FootprintsLiveActivityAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FootprintsLiveActivityAttributes.preview) {
   FootprintsLiveActivityLiveActivity()
} contentStates: {
    FootprintsLiveActivityAttributes.ContentState.smiley
    FootprintsLiveActivityAttributes.ContentState.starEyes
}
