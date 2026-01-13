import SwiftUI

public enum QuranError: Error, LocalizedError {
    case fileNotFound
    case invalidDataCount(ayas: Int, suras: Int, sofhas: Int)

    public var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Le fichier quran.json est introuvable."
        case let .invalidDataCount(a, s, sof):
            return "Données corrompues : Ayats(\(a)/6236), Suras(\(s)/114), Sofhas(\(sof)/604)."
        }
    }
}
