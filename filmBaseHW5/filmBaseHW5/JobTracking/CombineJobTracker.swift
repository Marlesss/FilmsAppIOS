import Dispatch
import Combine
import Foundation

public class CombineJobTracker<Key: Hashable, Output, Failure: Error>: PublishingJobTracking {
    public typealias JobPublisher = Publishers.CompactMap<CurrentValueSubject<Optional<Output>, Failure>, Output>
    
    public required init(memoizing: MemoizationOptions, worker: @escaping JobWorker<Key, Output, Failure>) {
        self.memoizing = memoizing
        self.worker = worker
    }
    
    public func startJob(for key: Key) -> JobPublisher {
        return syncQueue.sync {
            if !self.memoizing.contains(.started) {
                let toPublic: CurrentValueSubject<Output?, Failure> = CurrentValueSubject<Output?, Failure>(nil)
                let toSubscribe = toPublic.compactMap({$0})
                DispatchQueue.global(qos: .userInteractive).async {
                    self.worker(key, {result in
                        self.sendResult(publisher: toPublic, result: result)
                    })
                }
                return toSubscribe
            }
            if self.status[key] == nil {
                self.status[key] = .started
                
                let toPublic: CurrentValueSubject<Output?, Failure> = CurrentValueSubject<Output?, Failure>(nil)
                let toSubscribe = toPublic.compactMap({$0})
                DispatchQueue.global().async {
                    self.worker(key, {result in
                        self.sendResult(publisher: toPublic, result: result)
                        self.rememberResult(key: key, result: result)
                    })
                }
                self.publisher[key] = toSubscribe
            }
            return publisher[key]!
        }
    }
    
    private let memoizing: MemoizationOptions
    private let worker: JobWorker<Key, Output, Failure>
    private var status: [Key:Status<Output, Failure>] = [:]
    private var publisher: [Key:JobPublisher] = [:]
    private let syncQueue = DispatchQueue(label: "syncQueue", qos: .userInteractive)
    
    private func sendResult(publisher: CurrentValueSubject<Output?, Failure>, result: Result<Output, Failure>) {
        self.syncQueue.sync {
            switch result {
            case let .success(out):
                publisher.send(out)
            case let .failure(err):
                publisher.send(completion: .failure(err))
            }
        }
    }
    
    private func rememberResult(key: Key, result: Result<Output, Failure>) {
        self.syncQueue.sync {
            if self.memoizing.contains(.succeeded), case .success(_) = result {
                self.status[key] = .finished(result)
                return
            }
            if self.memoizing.contains(.failed), case .failure(_) = result {
                self.status[key] = .finished(result)
                return
            }
            self.status.removeValue(forKey: key)
        }
    }
}
