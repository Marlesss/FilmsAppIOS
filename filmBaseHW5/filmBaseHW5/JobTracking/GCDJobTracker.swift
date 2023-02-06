import Dispatch

public class GCDJobTracker<Key: Hashable, Output, Failure: Error>: CallbackJobTracking {
    required public init(memoizing: MemoizationOptions, worker: @escaping JobWorker<Key, Output, Failure>) {
        self.memoizing = memoizing
        self.worker = worker
    }
    
    public func startJob(for key: Key, completion: @escaping (Result<Output, Failure>) -> Void) {
        
        requestQueue.sync() {
            if !self.memoizing.contains(.started) {
                self.startJobAtQueue(for: key, completion: {result in completion(result)})
                return
            }
            if let keyStatus = self.status[key] {
                switch keyStatus {
                case .started:
                    // join the waiting of result
                    self.wait(for: key, completion: completion)
                case let .finished(result):
                    // return already calculated result
                    completion(result)
                }
            } else {
                // run worker with memoization option
                self.status[key] = .started
                self.wait(for: key, completion: completion)
                self.startJobAtQueue(for: key) { result in
                    self.requestQueue.sync() {
                        self.rememberResult(for: key, result: result)
                        self.sendResult(for: key, result: result)
                    }
                }
            }
        }
    }
    
    private let memoizing: MemoizationOptions
    private let worker: JobWorker<Key, Output, Failure>
    private var status: [Key:Status<Output, Failure>] = [:]
    private var onWaiting: [Key:[(Result<Output, Failure>) -> Void]] = [:]
    private let workersQueue = DispatchQueue(label: "workers", qos: .userInitiated, attributes: .concurrent)
    private let requestQueue = DispatchQueue(label: "requests", qos: .userInteractive)
    
    private func startJobAtQueue(for key: Key, completion: @Sendable @escaping (Result<Output, Failure>) -> Void) {
        workersQueue.async {
            self.worker(key, completion)
        }
    }
    
    private func rememberResult(for key: Key, result: Result<Output, Failure>) {
        if memoizing.contains(.succeeded), case .success(_) = result {
            status[key] = .finished(result)
            return
        }
        if memoizing.contains(.failed), case .failure(_) = result {
            status[key] = .finished(result)
            return
        }
        status.removeValue(forKey: key)
    }
    
    private func sendResult(for key: Key, result: Result<Output, Failure>) {
        onWaiting[key]?.forEach({ completion in
            completion(result)
        })
        onWaiting.removeValue(forKey: key)
    }
    
    private func wait(for key: Key, completion: @escaping (Result<Output, Failure>) -> Void) {
        if onWaiting[key] == nil {
            onWaiting[key] = []
        }
        onWaiting[key]?.append(completion)
    }
}
