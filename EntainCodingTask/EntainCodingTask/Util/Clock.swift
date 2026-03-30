protocol Clock {
    func sleep(for duration: Duration) async throws
}

struct SystemClock: Clock {
    func sleep(for duration: Duration) async throws {
        try await Task.sleep(for: duration)
    }
}