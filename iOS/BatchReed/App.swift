import SwiftUI

@main
struct BatchReedApp: App {
    @StateObject private var store = BatchReedStore()
    @StateObject private var purchases = PurchaseManager()
    @AppStorage("batchreed_haptics_enabled") private var hapticsEnabled: Bool = true

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .environmentObject(purchases)
                .preferredColorScheme(.light)
                .onAppear {
                    BRHaptics.enabled = hapticsEnabled
                }
        }
    }
}
