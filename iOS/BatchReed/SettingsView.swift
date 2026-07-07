import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: BatchReedStore
    @EnvironmentObject private var purchases: PurchaseManager
    @AppStorage("batchreed_haptics_enabled") private var hapticsEnabled: Bool = true
    @AppStorage("batchreed_show_notes") private var showNotes: Bool = true

    @State private var showingDeleteConfirm = false
    @State private var showingPaywall = false
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                BRTheme.backdrop.ignoresSafeArea()

                Form {
                    Section {
                        if purchases.isPro {
                            HStack {
                                Image(systemName: "checkmark.seal.fill").foregroundStyle(BRTheme.accent)
                                Text("Batch Reed Pro active")
                                    .foregroundStyle(BRTheme.ink)
                            }
                        } else {
                            Button {
                                showingPaywall = true
                            } label: {
                                HStack {
                                    Image(systemName: "star.fill").foregroundStyle(BRTheme.accent2)
                                    Text("Unlock Pro")
                                        .foregroundStyle(BRTheme.ink)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(BRTheme.inkFaded)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("settingsUnlockProButton")
                        }
                    }
                    .listRowBackground(BRTheme.card)

                    if purchases.isPro {
                        Section("Reed Soak Timer") {
                            Text("Soak timers with material quantity calculator per basket size.")
                                .font(.caption)
                                .foregroundStyle(BRTheme.inkFaded)
                            ForEach(store.proEntries) { p in
                                HStack {
                                    Text(p.reedType)
                                        .foregroundStyle(BRTheme.ink)
                                    Spacer()
                                    Text(p.soakMinutes)
                                        .font(.caption)
                                        .foregroundStyle(BRTheme.accent)
                                }
                            }
                            .onDelete { offsets in
                                for idx in offsets { store.deleteProEntry(store.proEntries[idx].id) }
                            }
                        }
                        .listRowBackground(BRTheme.card)
                    }

                    Section("Preferences") {
                        Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                            .onChange(of: hapticsEnabled) { _, newValue in
                                BRHaptics.enabled = newValue
                            }
                        Toggle("Show Notes", isOn: $showNotes)
                    }
                    .listRowBackground(BRTheme.card)

                    Section {
                        Button {
                            if store.canAdd(isPro: purchases.isPro) {
                                showingAdd = true
                            } else {
                                showingPaywall = true
                            }
                        } label: {
                            Label("Add Entry", systemImage: "plus")
                        }
                        .accessibilityIdentifier("settingsAddBasketButton")
                    }
                    .listRowBackground(BRTheme.card)

                    Section {
                        Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/batchreed-app/privacy.html")!)
                        Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/batchreed-app/terms.html")!)
                        Button("Restore Purchases") {
                            Task { await purchases.restore() }
                        }
                    }
                    .listRowBackground(BRTheme.card)

                    Section {
                        Button("Delete All Data", role: .destructive) {
                            showingDeleteConfirm = true
                        }
                    }
                    .listRowBackground(BRTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .confirmationDialog("Delete all data? This cannot be undone.", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
                Button("Delete Everything", role: .destructive) {
                    store.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingAdd) {
                BasketFormView(mode: .add)
            }
        }
    }
}
