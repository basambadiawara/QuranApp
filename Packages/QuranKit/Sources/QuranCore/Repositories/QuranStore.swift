import Foundation

@MainActor
@Observable
public final class QuranStore: Sendable {
    
    // MARK: - Singleton
    public static let shared = QuranStore()

    // MARK: - Properties
    public private(set) var ayas: [Aya] = []
    public private(set) var suras: [Sura] = []
    public private(set) var sofhas: [Sofha] = []
    public private(set) var state: State = .idle
    
    public private(set) var sofhaMetadata: [Sofha.Metadata] = []

    // MARK: - Initializer
    public init() {}

    // MARK: - Public Logic
    @MainActor
    public func load() async {
        do {
            self.state = .loading
            async let quranTask: QuranDTO = Bundle.module.load("quran.min.json")
            async let metaTask: [Sofha.Metadata] = Bundle.module.load("sofha-meta.json")
            
            // 3. Attendre les résultats
            let (quran, meta) = try await (quranTask, metaTask)
            
            self.ayas = quran.ayas
            self.suras = quran.suras
            self.sofhas = quran.sofhas
            
            sofhaMetadata = meta
            self.state = .loaded

        } catch {
            self.state = .error(error.localizedDescription)
        }
    }

    // MARK: - Private Infrastructure
    private static func fetchAndDecode() async throws -> QuranDTO {
        guard let url = Bundle.module.url(forResource: "quran.min", withExtension: "json") else {
            throw QuranError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(QuranDTO.self, from: data)
        
        let isValid = decoded.ayas.count == 6236 &&
                      decoded.suras.count == 114 &&
                      decoded.sofhas.count == 604
        
        guard isValid else {
            throw QuranError.invalidDataCount(
                ayas: decoded.ayas.count,
                suras: decoded.suras.count,
                sofhas: decoded.sofhas.count
            )
        }
        
        return decoded
    }
    
    public enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }
    
    public var isLoaded: Bool { state == .loaded }
    
    public func aya(id: Int) -> Aya { ayas[id-1] }
    public func ayas(in range: ClosedRange<Int>) -> [Aya] { Array(ayas[range]) }
    public func ayas(for sura: Sura) -> [Aya] { Array(ayas[(sura.ayaRange.lowerBound-1)...(sura.ayaRange.upperBound-1)]) }
    public func ayas(for sofha: Sofha) -> [Aya] { Array(ayas[(sofha.ayaRange.lowerBound-1)...(sofha.ayaRange.upperBound-1)]) }

    public func sura(id: Int) -> Sura { suras[id-1] }
    public func suras(in range: ClosedRange<Int>) -> [Sura] { Array(suras[range]) }
    public func suras(for sofha: Sofha) -> [Sura] { Array(suras[(sofha.suraRange.lowerBound-1)...(sofha.suraRange.upperBound-1)]) }

    public func sofha(id: Int) -> Sofha { sofhas[id-1] }
    public func sofhas(in range: ClosedRange<Int>) -> [Sofha] { Array(sofhas[range]) }
    public func sofhas(for sura: Sura) -> [Sofha] { Array(sofhas[(sura.sofhaRange.lowerBound-1)...(sura.sofhaRange.upperBound-1)]) }
    public func metadata(sofhaId: Int) -> Sofha.Metadata { sofhaMetadata[sofhaId-1] }
}

// MARK: - Errors


extension Bundle {
    func load<T: Decodable>(_ fileName: String) async throws -> T {
        guard let url = self.url(forResource: fileName, withExtension: nil) else {
            throw QuranError.fileNotFound
//            fatalError("File \(fileName) not found")
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
