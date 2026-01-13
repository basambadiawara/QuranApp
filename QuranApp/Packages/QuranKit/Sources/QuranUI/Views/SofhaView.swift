import SwiftUI
import QuranCore
import PageView
import FontLoader

public struct SofhaView: View {
    let sofhaId: Sofha.ID
    @Environment(QuranStore.self) var store
    public init(id sofhaId: Sofha.ID) {
        self.sofhaId = sofhaId
    }
    
    public var body: some View {
        if (1...604).contains(sofhaId) {
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    HStack {
                        HStack(spacing: 0) {
                            Text("20").fontWeight(.medium)
                            Text(verbatim: "ﭑ")
                                .font(.loaded("QCF_P100", size: proxy.size.height/17*15 * 30.0 / 800.0, in: .module))
                                .padding(.trailing, 3)
                            Text("1/3").font(.callout).fontWeight(.medium)

                        }
                            .frame(width: UIDevice.current.topSideWidth)

                        Spacer()
                        Text( String(format: "%03dsurah", store.suras(for: store.sofhas[sofhaId-1]).first!.id))
                            .font(.loaded("sura_names", size: proxy.size.height/17*15 * 30.0 / 800.0, in: .module))
                            .frame(width: UIDevice.current.topSideWidth)

                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .frame(height: proxy.size.height/17)
                    SelectableTextView(
                        text: metadata.glyphs,
                        attributedText: generateAttributedString(
                            metadata: metadata,
                            height: proxy.size.height/17*15
                        ),
                        ranges: store.metadata(sofhaId: sofhaId).spans.map(\.range),
                        editMenu: makeEditMenu(for:)
                    )
                    
                    .background(alignment: .top) {
                        headers(positions: store.metadata(sofhaId: sofhaId).headersLines ?? [:])
                    }
                    .frame(height: proxy.size.height/17*15)
                    
                    Text(sofhaId.description)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .frame(height: proxy.size.height/17)

                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
            }
            .frame(minHeight: 350)
        } else {
            Text("Sofha not found")
        }
    }
    
    var metadata: Sofha.Metadata {
        store.metadata(sofhaId: sofhaId)
    }
    
    func generateAttributedString(metadata: Sofha.Metadata, height: CGFloat) -> NSMutableAttributedString {
        let text = metadata.glyphs
        let lineHeight = height / 15.0
        let fontSize = height * 27.0 / 800.0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        
        let fontName = String(format: "QCF_P%03d", sofhaId)
        let font = UIFont.loaded(fontName, size: fontSize, in: .module) ?? .systemFont(ofSize: fontSize)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor(.primary),
            .paragraphStyle: paragraphStyle,
            .writingDirection: [NSWritingDirection.rightToLeft.rawValue | NSWritingDirectionFormatType.override.rawValue]
        ]
        
        //print(text)
        
        return NSMutableAttributedString(string: text, attributes: attributes)
    }

    func headers(positions: [Sura.ID : Int]) -> some View {
        GeometryReader { proxy in
            // bands behind surah names
            if ![1, 2].contains(sofhaId) {
                ForEach(positions.keys.sorted(), id: \.self) { surahId in
                    suraHeader(for: surahId, size: .init(width: proxy.size.width, height: proxy.size.height/15), fontsize: proxy.size.height * 30.0 / 800.0)
                        .offset(y: CGFloat(positions[surahId]!) * proxy.size.height / 15.0)
                }
            }
        }
    }
    
    func suraHeader(for suraId: Sura.ID, size: CGSize, fontsize: CGFloat) -> some View {
    Image(.headerShape)
        .resizable()
        .renderingMode(.template)
        .frame(width: size.width, height: size.height)
    //.opacity(0.7)
        .overlay(alignment: .center, content: {
            Text( String(format: "%03dsurah", suraId))
                .font(.loaded("sura_names", size: fontsize, in: .module))
                .offset(y: size.height * 0.08)
                .environment(\.layoutDirection, .rightToLeft)
        })
}
    
    private func makeEditMenu(for selections: [Range<Int>]) -> UIMenu {
            let pageActions = UIMenu(title: "Page Actions", options: .displayInline, children: [
                UIAction(title: "Bookmark", image: UIImage(systemName: "bookmark")) { _ in }
            ])

            let highlightActions = UIMenu(title: "Highlight", options: .displayInline, children: [
                UIAction(title: "Add Highlight", image: UIImage(systemName: "highlighter")) { _ in }
            ])
            
            return UIMenu(children: [pageActions, highlightActions])
        }

}

private struct SelectableTextView: UIViewRepresentable {
    var text: String
    var attributedText: NSMutableAttributedString
    var delimiter: String
    var ranges: [NSRange]
    private var editMenu: (_ selectedRanges: [NSRange]) -> UIMenu

    init(
        text: String,
        attributedText: NSMutableAttributedString,
        delimiter: String = "\u{200B}",
        ranges: [NSRange] = [],
        editMenu: @escaping (_ selectedRanges: [NSRange]) -> UIMenu
    ) {
        self.text = text
        self.attributedText = attributedText
        self.delimiter = delimiter
        self.editMenu = editMenu
        self.ranges = ranges
    }
    
    init(
        text: String,
        attributedText: NSMutableAttributedString,
        delimiter: String = "\u{200B}",
        ranges: [Range<Int>] = [],
        editMenu: @escaping (_ selectedRanges: [Range<Int>]) -> UIMenu
    ){
        self.text = text
        self.attributedText = attributedText
        self.delimiter = delimiter
        self.ranges = ranges.map { .init($0)}
        self.editMenu = { editMenu($0.compactMap {.init($0)}) }
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.isEditable = false
        tv.isSelectable = true
        tv.isUserInteractionEnabled = true
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.textContainer.lineFragmentPadding = 0
        tv.textContainerInset = .zero
        tv.textAlignment = .center
        tv.attributedText = attributedText
        tv.delegate = context.coordinator
        return tv
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        let fitting = CGSize(width: proposal.width ?? .greatestFiniteMagnitude,
                             height: proposal.height ?? .greatestFiniteMagnitude)
        return uiView.sizeThatFits(fitting)
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        DispatchQueue.main.async {
            // garde la sélection en place si le contenu change
            if !textView.attributedText.isEqual(to: self.attributedText) {
                let sel = textView.selectedRange
                textView.textAlignment = .center
                textView.attributedText = self.attributedText
                textView.selectedRange = sel
            }
        }
    }

    // MARK: - Coordinator
    // MARK: - Coordinator
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: SelectableTextView
        private var adjusting = false

        init(parent: SelectableTextView) { self.parent = parent }

        func textViewDidChangeSelection(_ textView: UITextView) {
            guard !adjusting else { return }
            adjusting = true; defer { adjusting = false }

            // 1) lire sélections courantes (supporte iOS ≤16 via selectedRange si tu veux)
            
            // 2) pour chaque sélection, produire la liste des blocs couverts (pas l’union)
            var snapped: [NSRange] = []
            if #available(iOS 26.0, *) {
                for sel in textView.selectedRanges {
                    snapped.append(contentsOf: snapSelection(sel, to: parent.ranges))
                }
            } else {
                // Fallback on earlier versions
            }

            if #available(iOS 26.0, *) {
                textView.selectedRanges = dedupAndSortRanges(snapped)
            } else {
                // Fallback on earlier versions
            }
            
            //print(textView.selectedRanges.count)

        }

        func textView(_ textView: UITextView,
                      editMenuForTextInRanges ranges: [NSValue],
                      suggestedActions: [UIMenuElement]) -> UIMenu? {
            // renvoyer les plages “snappées” actuelles au menu
            
            if #available(iOS 26.0, *) {
                return parent.editMenu(textView.selectedRanges)
            } else {
                return .none
            }
        }

        // --- Helpers ---

        /// Retourne la LISTE des blocs couverts par `sel` (caret -> 1 bloc ; plage -> tous les blocs chevauchés)
        private func snapSelection(_ sel: NSRange, to blocks: [NSRange]) -> [NSRange] {
            guard !blocks.isEmpty else { return [] }

            // Caret seul -> bloc contenant
            if sel.length == 0 {
                if let r = blocks.first(where: { NSLocationInRange(sel.location, $0) }) {
                    return [r]
                }
                return []
            }

            // Plage -> tous les blocs qui se chevauchent
            let selEnd = sel.location + sel.length
            var covered: [NSRange] = []
            for r in blocks {
                let rEnd = r.location + r.length
                let overlap = max(r.location, sel.location) < min(rEnd, selEnd)
                if overlap { covered.append(r) }
            }

            // Si aucun, mais le début tombe dans un bloc, renvoyer ce bloc
            if covered.isEmpty,
               let r = blocks.first(where: { NSLocationInRange(sel.location, $0) }) {
                return [r]
            }
            return covered
        }

        /// Trie par location et supprime les doublons exacts
        private func dedupAndSortRanges(_ ranges: [NSRange]) -> [NSRange] {
            let sorted = ranges.sorted { a, b in
                if a.location == b.location { return a.length < b.length }
                return a.location < b.location
            }
            var out: [NSRange] = []
            var seen = Set<String>()
            for r in sorted {
                let key = "\(r.location):\(r.length)"
                if !seen.contains(key) {
                    seen.insert(key)
                    out.append(r)
                }
            }
            return out
        }
    }}

#Preview {
    @Previewable @State var store = QuranStore()
    VStack {
        switch store.state {
        case .idle:
            ProgressView().task {
                await store.load()
            }
        case .loading:
            Text("Loading")
        case .loaded:
            SofhaView(id: 100).ignoresSafeArea(.container, edges: .vertical)
        case .error(let string):
            Text(string)
        }
    }
    .environment(store)
}

extension String {
    // Transforme tes Int (location, length) en une sous-chaîne correcte
    func safeSubstring(location: Int, length: Int) -> String? {
        // 1. Création des Index Swift (Safe)
        let start = self.index(self.startIndex, offsetBy: location, limitedBy: self.endIndex) ?? self.startIndex
        let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
        
        // 2. Extraction du texte
        return String(self[start..<end])
    }
}

extension UIDevice {
    /// Calcule la largeur disponible entre le bord et l'élément central (Notch/Island)
    public var topSideWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        
        // 1. Récupérer les insets de la fenêtre principale
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
        let topInset = window?.safeAreaInsets.top ?? 0
        
        // 2. Déduire la largeur de l'élément central (en points)
        let centerObstacleWidth: CGFloat
        
        if topInset > 51 {
            // Dynamic Island (iPhone 14 Pro, 15, 16, 17...)
            // L'île fait environ 125pt de large
            centerObstacleWidth = 125
        } else if topInset > 20 {
            // Notch Classique (iPhone X à 14)
            // L'encoche fait environ 160pt de large
            centerObstacleWidth = 160
        } else {
            // iPhone SE ou iPad (Pas d'obstacle central)
            return (screenWidth / 2) - 15
        }
        
        // 3. Calculer l'espace restant d'un côté
        // Formule : (Largeur Totale - Obstacle) / 2 - Marge de sécurité
        let availableWidth = (screenWidth - centerObstacleWidth) / 2
        
        return availableWidth - 12 // 12pt de marge pour ne pas coller à l'obstacle
    }
}
