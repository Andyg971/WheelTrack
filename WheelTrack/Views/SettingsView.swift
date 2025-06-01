import SwiftUI

public struct SettingsView: View {
    public init() {}

    public var body: some View {
        NavigationView {
            List {
                Text(NSLocalizedString("Setting 1", comment: "Label for setting 1"))
                Text(NSLocalizedString("Setting 2", comment: "Label for setting 2"))
            }
            .navigationTitle(NSLocalizedString("Settings", comment: "Navigation title for settings screen"))
        }
        .accessibilityIdentifier("SettingsView")
    }
}

#Preview {
    SettingsView()
} 