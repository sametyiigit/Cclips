import Foundation

@MainActor
final class PasteStackController {
    private var queue: [UUID] = []
    private var index = 0

    var remainingCount: Int {
        max(queue.count - index, 0)
    }

    func enqueue(clipID: UUID) {
        queue.append(clipID)
    }

    func replaceQueue(with clipIDs: [UUID]) {
        queue = clipIDs
        index = 0
    }

    func advance() -> UUID? {
        guard index < queue.count else {
            clear()
            return nil
        }

        let clipID = queue[index]
        index += 1

        if index >= queue.count {
            defer { clear() }
            return clipID
        }

        return clipID
    }

    func clear() {
        queue.removeAll()
        index = 0
    }
}
