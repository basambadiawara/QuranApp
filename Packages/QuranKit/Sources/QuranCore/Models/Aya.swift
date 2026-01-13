public struct Aya: Identifiable, Hashable, Sendable {
    public var id: Int
    public var number: Int
    public var text: String
    public var suraId: Int
    public var rubuId: Int
    public var sofhaId: Int
}

//MARK: - Data Transfer Object

extension Aya: Decodable {
    enum CodingKeys: String, CodingKey {
        case id, number, text
        case suraId = "sura"
        case sofhaId = "sofha"
        case rubuId = "rubu"
    }
}
