import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            BasketListView()
                .tabItem { Label("Home", systemImage: "list.bullet.clipboard") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(BRTheme.accent)
    }
}

struct BasketListView: View {
    @EnvironmentObject private var store: BatchReedStore
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var editingItem: Basket?

    var body: some View {
        NavigationStack {
            ZStack {
                BRTheme.backdrop.ignoresSafeArea()
                if store.baskets.isEmpty {
                    ContentUnavailableView("No Baskets Yet", systemImage: "square.stack.3d.up", description: Text("Tap + to log your first entry."))
                } else {
                    List {
                        ForEach(store.baskets) { item in
                            BasketRow(item: item)
                                .listRowBackground(BRTheme.card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingItem = item
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        store.deleteBasket(item.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Batch Reed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd(isPro: purchases.isPro) {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addBasketButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                BasketFormView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                BasketFormView(mode: .edit(item))
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

struct BasketRow: View {
    let item: Basket

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.basketName)
                .font(BRTheme.headlineFont)
                .foregroundStyle(BRTheme.ink)
            Text(String(describing: item.reedSize))
                .font(.caption)
                .foregroundStyle(BRTheme.inkFaded)
        }
        .padding(.vertical, 4)
    }
}

enum BasketFormMode: Identifiable {
    case add
    case edit(Basket)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id.uuidString
        }
    }
}

struct BasketFormView: View {
    @EnvironmentObject private var store: BatchReedStore
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    let mode: BasketFormMode

    @State private var draftBasketName: String = ""
    @State private var draftReedSize: String = ""
    @State private var draftWeavePattern: String = ""
    @State private var draftDimensions: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                BRTheme.backdrop.ignoresSafeArea()
                Form {
                    Section {
                TextField("Basket", text: $draftBasketName)
                    .accessibilityIdentifier("basketNameField")
                TextField("Reed Size", text: $draftReedSize)
                    .accessibilityIdentifier("reedSizeField")
                Picker("Weave Pattern", selection: $draftWeavePattern) {
                    ForEach(BRWeavePatternOption.all, id: \.self) { Text($0) }
                }
                TextField("Dimensions (in)", text: $draftDimensions)
                    .accessibilityIdentifier("dimensionsField")
                    }
                    .listRowBackground(BRTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("basketSaveButton")
                }
            }
            .onAppear { loadIfEditing() }
            .dismissKeyboardOnTap()
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func loadIfEditing() {
        if case .edit(let item) = mode {
        draftBasketName = item.basketName
        draftReedSize = item.reedSize
        draftWeavePattern = item.weavePattern
        draftDimensions = item.dimensions
        } else {
        draftBasketName = ""
        draftReedSize = ""
        draftWeavePattern = ""
        draftDimensions = ""
        }
    }

    private func save() {
        switch mode {
        case .add:
            store.addBasket(basketName: draftBasketName, reedSize: draftReedSize, weavePattern: draftWeavePattern, dimensions: draftDimensions, isPro: purchases.isPro)
        case .edit(let item):
            store.updateBasket(item.id, basketName: draftBasketName, reedSize: draftReedSize, weavePattern: draftWeavePattern, dimensions: draftDimensions)
        }
        BRHaptics.success()
        dismiss()
    }
}
