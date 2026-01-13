import SwiftUI
import QuranCore
import PageView

public struct QuranView: View {
    @Environment(QuranStore.self) var store
    @State var selection: Int? = 0
    public init() {}
    public var body: some View {
        GeometryReader { proxy in
            PageView(selection: $selection) {
                Page(value: 0) {
                    Text("Index Page").background()
                }
                
                ForEach(1..<605) { i in
                    Page(value: i) {
                        SofhaView(id: i)
                            .ignoresSafeArea()
                            .background()
                    }
                }
                
            }
            .overlay(alignment: .bottomTrailing)  {
                Menu {
                    Button("Close", systemImage: "xmark") {
                        
                    }
                    Button("Close", systemImage: "xmark") {
                        
                    }
                    Button("Close", systemImage: "xmark") {
                        
                    }
                    Button("Close", systemImage: "xmark") {
                        
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: proxy.size.height/17, height: proxy.size.height/17, alignment: .center)
                        .contentShape(.circle)
                        .imageScale(.large)
                        .padding(.trailing, 30)
                }
            }
            .pageViewStyle(.pager(withCurlEffect: true, isReversed: true))
        }
    }
}

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
            QuranView().ignoresSafeArea(.container, edges: .vertical)
        case .error(let string):
            Text(string)
        }
    }
    .environment(store)
    .environment(\.locale, .init(identifier: "fr"))
}

