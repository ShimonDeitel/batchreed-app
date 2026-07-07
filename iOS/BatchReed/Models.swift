import Foundation

struct Basket: Identifiable, Codable, Equatable {
    let id: UUID
    var basketName: String
    var reedSize: String
    var weavePattern: String
    var dimensions: String
    var createdDate: Date

    init(
        id: UUID = UUID(),
        basketName: String = "Market Basket",
        reedSize: String = "#3 Round",
        weavePattern: String = "Plain",
        dimensions: String = "10x8x6",
        createdDate: Date = Date()
    ) {
        self.id = id
        self.basketName = basketName
        self.reedSize = reedSize
        self.weavePattern = weavePattern
        self.dimensions = dimensions
        self.createdDate = createdDate
    }
}

/// Pro bonus feature entry: Reed Soak Timer.
struct BRProEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var reedType: String
    var soakMinutes: String
    var quantityNeeded: String
    var basketSize: String
    var createdDate: Date

    init(
        id: UUID = UUID(),
        reedType: String = "#3 Round",
        soakMinutes: String = "10",
        quantityNeeded: String = "40",
        basketSize: String = "10x8x6",
        createdDate: Date = Date()
    ) {
        self.id = id
        self.reedType = reedType
        self.soakMinutes = soakMinutes
        self.quantityNeeded = quantityNeeded
        self.basketSize = basketSize
        self.createdDate = createdDate
    }
}

enum BRWeavePatternOption {
    static let all = ["Plain", "Twill", "Chase", "Randing", "Twining"]
}
