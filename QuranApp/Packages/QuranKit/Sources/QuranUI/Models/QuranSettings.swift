import SwiftUI

@MainActor
@Observable
public final class QuranSettings: Sendable {
    // MARK: - Properties
    public var displayMode: DisplayMode = .standard
    public var detailedMode = DetailedModeSettings()
    public init() {}

    // MARK: - Nested Types
    public enum DisplayMode: String, Codable, Identifiable, CaseIterable, Sendable {
        case standard
        case detailed
        public var id: Self { self }
        
        public var systemImage: String {
            switch self {
            case .standard: "book.pages"
            case .detailed: "scroll"
            }
        }
        
        public var title: String {
            switch self {
            case .standard: String(localized: "Standard")
            case .detailed: String(localized: "Detailed")
            }
        }
        
        public var detail: String {
            switch self {
            case .standard: return String(localized: "Page by Page", table: "Localizable", bundle: .module)
            case .detailed: return String(localized: "Verse by Verse", bundle: .module)
            }
        }
        
        public var footer: String {
            switch self {
            case .standard: String(localized: "This mode provides a traditional reading experience with a fixed text size and limited display options.", bundle: .module)
            case .detailed: String(localized: "This mode offers a more flexible reading experience with adjustable text size and additional display options for deeper study.", bundle: .module)
            }
        }
        
        static let description: String = {
            String(localized: "Choose how you would like the Quran to be displayed. Each mode provides a different reading experience, and you can switch between them at any time while reading.", bundle: .module)
        }()
    }

    public struct DetailedModeSettings: Sendable {
        public var quranFontSize: CGFloat = 24
        public var detailFontSize: CGFloat = 16
        public var isTranslationVisible: Bool = true
    }
}
