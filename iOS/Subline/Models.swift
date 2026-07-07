import Foundation

struct Subscription: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var name: String
    var monthlyCost: Double
    var renewalDate: Date

    init(id: UUID = UUID(), createdAt: Date = Date(), name: String = "", monthlyCost: Double = 0, renewalDate: Date = Date()) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.monthlyCost = monthlyCost
        self.renewalDate = renewalDate
    }
}
