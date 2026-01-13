import SwiftUI

public struct OptionSelector<Option: Hashable, Content: View, Footer: View, Detail: View>: View {
    let title: String
    let systemImage: String?
    let options: [Option]
    @Binding var selection: Option
    
    let content: (Option) -> Content
    let footer: ((Option) -> Footer)?
    let sectionFooter: Footer?
    let detailView: Detail?
    
    public var body: some View {
        NavigationLink {
            PickerDestination(parent: self)
        } label: {
            Label {
                Text(LocalizedStringKey(title), bundle: .module)
            } icon: {
                if let systemImage {
                    Image(systemName: systemImage)
                }
            }
            .badge(Text(LocalizedStringKey("\(selection)".capitalized), bundle: .module))
        }
    }
    
    private struct PickerDestination: View {
        let parent: OptionSelector<Option, Content, Footer, Detail>
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            List {
                if let detailView = parent.detailView {
                    Section {
                        detailView
                    }
                }
                
                if let footer = parent.footer {
                    ForEach(parent.options, id: \.self) { option in
                        Section {
                            optionRow(for: option)
                        } footer: {
                            footer(option)
                        }
                    }
                } else {
                    Section {
                        ForEach(parent.options, id: \.self) { option in
                            optionRow(for: option)
                        }
                    } footer: {
                        if let sectionFooter = parent.sectionFooter {
                            sectionFooter
                        }
                    }
                }
            }
            .navigationTitle(Text(LocalizedStringKey(parent.title), bundle: .module))
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: parent.selection) { dismiss() }
        }
        
        private func optionRow(for option: Option) -> some View {
            Button {
                parent.selection = option
            } label: {
                HStack {
                    parent.content(option)
                    Spacer()
                    if parent.selection == option {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                            .fontWeight(.semibold)
                    }
                }
            }
            .tint(.primary)
        }
    }
}

// MARK: - Initializers Cleanup
extension OptionSelector {
    // Base init: Content only
    public init(
        _ title: String,
        systemImage: String? = nil,
        options: [Option],
        selection: Binding<Option>,
        @ViewBuilder content: @escaping (Option) -> Content
    ) where Footer == EmptyView, Detail == EmptyView {
        self.title = title
        self.systemImage = systemImage
        self.options = options
        self._selection = selection
        self.content = content
        self.footer = nil
        self.sectionFooter = nil
        self.detailView = nil
    }
    
    // With Detail View
    public init(
        _ title: String,
        systemImage: String? = nil,
        options: [Option],
        selection: Binding<Option>,
        @ViewBuilder content: @escaping (Option) -> Content,
        @ViewBuilder detail: @escaping () -> Detail
    ) where Footer == EmptyView {
        self.title = title
        self.systemImage = systemImage
        self.options = options
        self._selection = selection
        self.content = content
        self.footer = nil
        self.sectionFooter = nil
        self.detailView = detail()
    }
    
    // With Static Section Footer
    public init(
        _ title: String,
        systemImage: String? = nil,
        options: [Option],
        selection: Binding<Option>,
        @ViewBuilder content: @escaping (Option) -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) where Detail == EmptyView {
        self.title = title
        self.systemImage = systemImage
        self.options = options
        self._selection = selection
        self.content = content
        self.footer = nil
        self.sectionFooter = footer()
        self.detailView = nil
    }
    
    // With Dynamic Option Footer
    public init(
        _ title: String,
        systemImage: String? = nil,
        options: [Option],
        selection: Binding<Option>,
        @ViewBuilder content: @escaping (Option) -> Content,
        @ViewBuilder footer: @escaping (Option) -> Footer
    ) where Detail == EmptyView {
        self.title = title
        self.systemImage = systemImage
        self.options = options
        self._selection = selection
        self.content = content
        self.footer = footer
        self.sectionFooter = nil
        self.detailView = nil
    }
    
    // Full Init (Dynamic Footer + Detail)
    public init(
        _ title: String,
        systemImage: String? = nil,
        options: [Option],
        selection: Binding<Option>,
        @ViewBuilder content: @escaping (Option) -> Content,
        @ViewBuilder footer: @escaping (Option) -> Footer,
        @ViewBuilder detail: @escaping () -> Detail
    ) {
        self.title = title
        self.systemImage = systemImage
        self.options = options
        self._selection = selection
        self.content = content
        self.footer = footer
        self.sectionFooter = nil
        self.detailView = detail()
    }
}

#Preview {
    @Previewable @State var selection = 1
    NavigationStack {
        
        List {
            OptionSelector("Select an Opetion", systemImage: "house", options: [1,2,3], selection: $selection) { i in
                Section {
                    Text("Selection: \(i)")
                } footer: {
                    Text("Footer")
                }
            } detail: {
                VStack {
                    Text("Detail")
                }
            }
            
        }
    }
}
