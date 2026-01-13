import Foundation

public struct Sura: Identifiable, Hashable, Sendable {
    public let id: Int
    //public let name: String
    let ayaRange: ClosedRange<Int>
    let sofhaRange: ClosedRange<Int>
    let rubuRange: ClosedRange<Int>
}

//MARK: - Data Transfer Object

extension Sura: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case ayaRange = "aya_range"
        case sofhaRange = "sofha_range"
        case juzRange = "juz_range"
        case hizbRange = "hizb_range"
        case rubuRange = "rubu_range"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try c.decode(Int.self, forKey: .id)

        self.ayaRange = try c.decode(ClosedRange<Int>.self, forKey: .ayaRange)
        self.sofhaRange = try c.decode(ClosedRange<Int>.self, forKey: .sofhaRange)
        self.rubuRange = try c.decode(ClosedRange<Int>.self, forKey: .rubuRange)
        
    }
}
