import Foundation

@MainActor
final class BatchReedStore: ObservableObject {
    @Published private(set) var baskets: [Basket] = []
    @Published private(set) var proEntries: [BRProEntry] = []

    static let freeLimit = 30

    private let fileURL: URL
    private let proFileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("batchreed_baskets.json")
        self.proFileURL = dir.appendingPathComponent("batchreed_pro.json")
        if ProcessInfo.processInfo.arguments.contains("-uiTestReset") {
            try? FileManager.default.removeItem(at: fileURL)
            try? FileManager.default.removeItem(at: proFileURL)
        }
        load()
        if baskets.isEmpty {
            seedDefaults()
        }
        if proEntries.isEmpty {
            seedProDefaults()
        }
    }

    private func seedDefaults() {
        baskets = [
            Basket(basketName: "Market Basket", reedSize: "#3 Round", weavePattern: "Plain", dimensions: "10x8x6"),
            Basket(basketName: "Egg Basket", reedSize: "#2 Round", weavePattern: "Twill", dimensions: "7x7x9")
        ]
        save()
    }

    private func seedProDefaults() {
        proEntries = [
            BRProEntry(reedType: "#3 Round", soakMinutes: "10", quantityNeeded: "40", basketSize: "10x8x6"),
            BRProEntry(reedType: "Flat Oval", soakMinutes: "15", quantityNeeded: "60", basketSize: "14x10x8")
        ]
        saveProEntries()
    }

    func canAdd(isPro: Bool) -> Bool {
        isPro || baskets.count < Self.freeLimit
    }

    @discardableResult
    func addBasket(basketName: String, reedSize: String, weavePattern: String, dimensions: String, isPro: Bool) -> Bool {
        let trimmed = basketName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, canAdd(isPro: isPro) else { return false }
        let item = Basket(basketName: basketName, reedSize: reedSize, weavePattern: weavePattern, dimensions: dimensions)
        baskets.append(item)
        save()
        return true
    }

    func updateBasket(_ id: UUID, basketName: String, reedSize: String, weavePattern: String, dimensions: String) {
        guard let idx = baskets.firstIndex(where: { $0.id == id }) else { return }
        baskets[idx].basketName = basketName
        baskets[idx].reedSize = reedSize
        baskets[idx].weavePattern = weavePattern
        baskets[idx].dimensions = dimensions
        save()
    }

    func deleteBasket(_ id: UUID) {
        baskets.removeAll { $0.id == id }
        save()
    }

    func deleteAllData() {
        baskets = []
        proEntries = []
        seedDefaults()
        seedProDefaults()
    }

    // MARK: - Pro entries

    @discardableResult
    func addProEntry(reedType: String, soakMinutes: String, quantityNeeded: String, basketSize: String) -> Bool {
        let entry = BRProEntry(reedType: reedType, soakMinutes: soakMinutes, quantityNeeded: quantityNeeded, basketSize: basketSize)
        proEntries.append(entry)
        saveProEntries()
        return true
    }

    func deleteProEntry(_ id: UUID) {
        proEntries.removeAll { $0.id == id }
        saveProEntries()
    }

    // MARK: - Persistence

    private struct Snapshot: Codable {
        var items: [Basket]
    }
    private struct ProSnapshot: Codable {
        var items: [BRProEntry]
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL), let decoded = try? JSONDecoder().decode(Snapshot.self, from: data) {
            baskets = decoded.items
        }
        if let data = try? Data(contentsOf: proFileURL), let decoded = try? JSONDecoder().decode(ProSnapshot.self, from: data) {
            proEntries = decoded.items
        }
    }

    private func save() {
        let snapshot = Snapshot(items: baskets)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func saveProEntries() {
        let snapshot = ProSnapshot(items: proEntries)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: proFileURL, options: .atomic)
    }
}
