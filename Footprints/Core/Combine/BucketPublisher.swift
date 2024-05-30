//
//  BucketPublisher.swift
//  Footprints
//
//  Created by Collin Palmer on 5/30/24.
//

import Foundation
import Combine

// TODO: Should this be a connectable publisher of sorts?
// TODO: What's the best way to send data to it from the other combine publisher?
// (ie should it be a subscriber that takes its input into a bucket and then forwards?)
// TODO: async testing of combine code?

// Idea: return a controller closure that has a unique reference to the bucket itself?
// TODO: Rename as subject
class BucketPublisher<T, Failure: Error>: ConnectablePublisher, Cancellable {
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, [T] == S.Input {
        bucketSubject.receive(subscriber: subscriber)
    }
    
    
    typealias Output = [T]
    
    private var timerSubscriber: AnyCancellable? = nil
    private var bucket: [T] = []
    private let interval: TimeInterval
    
    private let bucketSubject = PassthroughSubject<[T], Failure>()
    
    init(interval: TimeInterval = 5) {
        self.interval = interval
    }
    
    func cancel() {
        timerSubscriber?.cancel()
        bucket = []
    }
    
    func connect() -> Cancellable {
        // TODO: Is this the desired approach?
        timerSubscriber = Timer
            .publish(every: self.interval, on: .main, in: .default)
            .autoconnect()
            .sink { _ in
            // TODO: Include timestamp?
            self.bucketSubject.send(self.bucket)
        }
        
        return self
    }
    
    /*
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, [T] == S.Input {
        // TODO -- allow the subscriber to subscribe
        bucketSubject.receive(subscriber: subscriber)
    }
     */
}

// Add to the bucket here
extension BucketPublisher: Subscriber {
    func receive(completion: Subscribers.Completion<Failure>) {
        // TODO: Error handling here?
    }
    
    typealias Input = T
    
    /*
    func receive(completion: Subscribers.Completion<Never>) {
        // TODO?
        /*
        switch completion {
        case .finished:
            <#code#>
        case .failure(let failure):
            <#code#>
        }
         */
    }
     */
    func receive(_ input: T) -> Subscribers.Demand {
        self.bucket.append(input)
        return .unlimited
    }
    
    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }
}

// TODO: Pass along parent failure?
// TODO: Extension on publisher instead
extension Publisher {
    // TODO: Just return bucket instead?
    func buffer(seconds: TimeInterval) -> BucketPublisher<Output, Failure> {
        let bucket = BucketPublisher<Output, Failure>(interval: seconds)
        // Send events from this publisher to the bucket
        self.subscribe(bucket)
        return bucket
    }
    
    /*
    func foo() {
        let connectable = BucketPublisher<[Int], Never>().makeConnectable()
    }
     */
}
