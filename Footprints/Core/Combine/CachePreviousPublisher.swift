//
//  OldNewPublisher.swift
//  Footprints
//
//  Created by Collin Palmer on 4/11/24.
//

import Foundation
import Combine

private class CacheSubscriber<Input, Failure: Error>: Subscriber {
    private var prevValue: Input?
    private let bufferSubject: PassthroughSubject<(Input?, Input), Failure> = PassthroughSubject()
    
    // TODO: Implement Publisher interface..?
    var publisher: AnyPublisher<(Input?, Input), Failure> {
        bufferSubject.eraseToAnyPublisher()
    }
    
    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }
    
    func receive(_ input: Input) -> Subscribers.Demand {
        bufferSubject.send((prevValue, input))
        prevValue = input
        
        return .unlimited
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        // TODO
    }
}

extension AnyPublisher {
    func cachePrevious() -> AnyPublisher<(Output?,Output), Failure> {
        let subscriber = CacheSubscriber<Output, Failure>()
        self.subscribe(subscriber)
        
        return subscriber.publisher
    }
}
