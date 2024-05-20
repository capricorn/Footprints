//
//  PredicateFIFO.swift
//  Footprints
//
//  Created by Collin Palmer on 4/18/24.
//

import Foundation

class PredicateFIFO<T>: ObservableObject {
    // TODO: Protocols to expose via? (Sequence, ..?)
    @Published var arr: [T] = []
    var pred: ([T]) -> Bool = { _ in false }
    
    func push(_ element: T) {
        arr.append(element)
        
        while pred(arr) {
            arr.removeFirst()
        }
    }
}
