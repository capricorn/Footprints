//
//  ArrayExtensions.swift
//  Footprints
//
//  Created by Collin Palmer on 5/15/24.
//

import Foundation

extension Array {
    func groupBy<Key>(_ grouper: (Element) -> Key) -> [Key:[Element]] where Key: Hashable {
        var groupings: [Key:[Element]] = [:]
        
        for e in self {
            let key = grouper(e)
            
            if groupings[key] == nil {
                groupings[key] = []
            }
            
            groupings[key]!.append(e)
        }
        
        return groupings
    }
}
