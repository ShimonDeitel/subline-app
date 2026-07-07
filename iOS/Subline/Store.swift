import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [Subscription] = []
    @Published var isPro: Bool = false

    /// Free-tier cap on number of items. Always kept comfortably above
    /// the seed-data count so a fresh install never hits the paywall.
    static let freeLimit = 8

    private let fileName = "subline_items.json"

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(fileName)
    }

    init() {
        load()
        if items.isEmpty {
            seedData()
            save()
        }
    }

    var isAtFreeLimit: Bool {
        !isPro && items.count >= Store.freeLimit
    }

    func add(_ item: Subscription) -> Bool {
        guard isPro || items.count < Store.freeLimit else { return false }
        items.insert(item, at: 0)
        save()
        return true
    }

    func update(_ item: Subscription) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Subscription) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func seedData() {
        items = (0..<4).map { i in
            var item = Subscription()
            item.createdAt = Date().addingTimeInterval(Double(-i) * 86400)
            return item
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([Subscription].self, from: data) {
            items = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
