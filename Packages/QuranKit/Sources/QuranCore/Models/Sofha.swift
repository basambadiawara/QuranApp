import Foundation

public struct Sofha: Identifiable, Hashable, Sendable {
    public let id: Int
    let ayaRange: ClosedRange<Int>
    let suraRange: ClosedRange<Int>
    let rubuRange: ClosedRange<Int>
}

//MARK: - Data Transfer Object

extension Sofha: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case ayaRange = "aya_range"
        case suraRange = "sura_range"
        case rubuRange = "juz_range"
    }
}

extension Sofha {
    public struct Metadata: Decodable {
        public let glyphs: String
        public let headersLines: [Int: Int]?
        public let spans: [Span]
        
        public init(glyphs: String, headersLines: [Int : Int]?=nil, spans: [Span]) {
            self.glyphs = glyphs
            self.headersLines = headersLines
            self.spans = spans
        }

        public struct Span: Decodable {
            public let reference: String
            public let location: Int
            public let length: Int
            
            public init(reference: String, location: Int, length: Int) {
                self.reference = reference
                self.location = location
                self.length = length
            }
            
            public var range: Range<Int> {
                .init(uncheckedBounds: (lower: location, upper: location + length))
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case glyphs = "text"
            case spans
            case headersLines = "headers_lines"
        }
    }
}

