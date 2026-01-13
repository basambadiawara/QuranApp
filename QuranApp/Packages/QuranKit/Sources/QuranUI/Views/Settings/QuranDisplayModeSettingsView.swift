import SwiftUI

public struct QuranDisplayModeSettingsView: View {

    @Environment(QuranSettings.self) private var settings

    public init() {}

    public var body: some View {
        @Bindable var settings = settings

        OptionSelector(
            "Display Mode",
            systemImage: "rectangle.3.group",
            options: [.standard, .detailed],
            selection: displayModeBinding
        ) { option in

            HStack {
                Text(LocalizedStringKey(option.title), bundle: .module)
                Spacer()
                Text(LocalizedStringKey(option.detail), bundle: .module)
                    .foregroundStyle(.secondary)
            }

        } footer: { option in

            VStack(alignment: .leading, spacing: 12) {

                if option == .detailed {
                    Toggle(isOn: detailedSettingsBinding.isTranslationVisible) {
                        Text("Show translation", bundle: .module)
                    }
                    .font(.footnote)

                    fontSizeSlider(
                        title: "Quran Font Size",
                        value: $settings.detailedMode.quranFontSize,
                        range: 18...40
                    )

                    fontSizeSlider(
                        title: "Detail Font Size",
                        value: $settings.detailedMode.detailFontSize,
                        range: 12...24
                    )
                }

                Text(LocalizedStringKey(option.footer), bundle: .module)
            }

        } detail: {

            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "rectangle.3.group.fill")
                    Text("Display Mode", bundle: .module)
                        .font(.headline)
                }

                Text(LocalizedStringKey(QuranSettings.DisplayMode.description), bundle: .module)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .tint(.primary)
        }
    }

    // MARK: - Bindings

    private var displayModeBinding: Binding<QuranSettings.DisplayMode> {
        .init(
            get: { settings.displayMode },
            set: { settings.displayMode = $0 }
        )
    }

    private var detailedSettingsBinding: Binding<QuranSettings.DetailedModeSettings> {
        .init(
            get: { settings.detailedMode },
            set: { settings.detailedMode = $0 }
        )
    }

    // MARK: - Components

    private func fontSizeSlider(
        title: String,
        value: Binding<CGFloat>,
        range: ClosedRange<CGFloat>
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(LocalizedStringKey(title), bundle: .module)
                Spacer()
                Text("\(Int(value.wrappedValue))pt")
                    .foregroundStyle(.secondary)
            }

            Slider(value: value, in: range, step: 1)
        }
    }
}
