public class ConcurrentJobTracker<Key: Hashable, Output, Failure: Error>: AsyncJobTracking {
    
    required public init(memoizing: MemoizationOptions, worker: @escaping JobWorker<Key, Output, Failure>) {
        self.memoizing = memoizing
        self.worker = worker
    }
    
    // TODO: MainActor -> Actor
    @MainActor
    public func startJob(for key: Key) async throws -> Output {
        if !self.memoizing.contains(.started) {
            let task = runWorker(for: key)
            let res = await task.value
            return try returnResult(res)
        }
        if let keyStatus = self.status[key] {
            switch keyStatus {
            case .started:
                return try returnResult(await taskBy[key]!.value)
            case let .finished(res):
                return try returnResult(res)
            }
        } else {
            // run worker with memoization option
            setStarted(key)
            let task = runWorker(for: key)
            setTaskBy(key, task)
            let res = await task.value
            rememberResult(for: key, result: res)
            return try returnResult(res)
        }
    }
    
    // TODO: MainActor -> Actor
    @MainActor
    private func setStarted(_ key: Key) {
        self.status[key] = .started
    }
    // TODO: MainActor -> Actor
    @MainActor
    private func setTaskBy(_ key: Key, _ task: Task<Result<Output, Failure>, Never>) {
        self.taskBy[key] = task
    }
    
    
    private let memoizing: MemoizationOptions
    private let worker: JobWorker<Key, Output, Failure>
    // TODO: MainActor -> Actor
    @MainActor
    private var status: [Key:Status<Output, Failure>] = [:]
    // TODO: MainActor -> Actor
    @MainActor
    private var taskBy: [Key:Task<Result<Output, Failure>, Never>] = [:]
    
    private func returnResult(_ res: Result<Output, Failure>) throws -> Output {
        switch res {
        case let .success(out):
            return out
        case let .failure(err):
            throw err
        }
    }
    
    private func runWorker(for key: Key) -> Task<Result<Output, Failure>, Never> {
        return Task {
            let res: Result<Output, Failure>
            do {
                let out: Output = try await withCheckedThrowingContinuation({ continuation in
                    worker(key, continuation.resume(with:))
                })
                res = .success(out)
            } catch {
                res = .failure(error as! Failure)
            }
            return res
        }
    }
    
    // TODO: MainActor -> Actor
    @MainActor
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
}
