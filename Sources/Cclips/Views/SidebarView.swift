import SwiftUI

struct SidebarView: View {
    @ObservedObject var store: ClipboardStore

    var body: some View {
        List {
            ForEach(ClipCollection.allCases) { collection in
                Button {
                    store.selectedCollection = collection
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: collection.systemImage)
                            .foregroundStyle(collection.accentColor)
                            .frame(width: 18)
                        Text(collection.title)
                        Spacer()
                        Text("\(store.clipCount(for: collection))")
                            .foregroundStyle(.secondary)
                            .font(.callout.monospacedDigit())
                    }
                }
                .buttonStyle(.plain)
                .listRowBackground(
                    store.selectedCollection == collection
                        ? collection.accentColor.opacity(0.14)
                        : Color.clear
                )
            }
        }
        .listStyle(.sidebar)
    }
}
