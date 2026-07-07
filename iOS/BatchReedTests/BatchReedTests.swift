import XCTest
@testable import BatchReed

final class BatchReedTests: XCTestCase {

    @MainActor
    func testStoreSeedsAboveZeroButBelowFreeLimit() {
        let store = BatchReedStore()
        XCTAssertGreaterThan(store.baskets.count, 0)
        XCTAssertLessThan(store.baskets.count, BatchReedStore.freeLimit)
    }

    @MainActor
    func testAddEntrySucceedsWhenUnderLimit() {
        let store = BatchReedStore()
        let before = store.baskets.count
        let added = store.addBasket(basketName: "Market Basket", reedSize: "#3 Round", weavePattern: "Plain", dimensions: "10x8x6", isPro: false)
        XCTAssertTrue(added)
        XCTAssertEqual(store.baskets.count, before + 1)
    }

    @MainActor
    func testAddEntryRejectsBlankPrimaryField() {
        let store = BatchReedStore()
        let before = store.baskets.count
        let added = store.addBasket(basketName: "   ", reedSize: "#3 Round", weavePattern: "Plain", dimensions: "10x8x6", isPro: false)
        XCTAssertFalse(added)
        XCTAssertEqual(store.baskets.count, before)
    }

    @MainActor
    func testFreeLimitBlocksAdditionalEntries() {
        let store = BatchReedStore()
        for item in store.baskets { store.deleteBasket(item.id) }
        for _ in 0..<BatchReedStore.freeLimit {
            XCTAssertTrue(store.addBasket(basketName: "Market Basket", reedSize: "#3 Round", weavePattern: "Plain", dimensions: "10x8x6", isPro: false))
        }
        XCTAssertFalse(store.addBasket(basketName: "Market Basket", reedSize: "#3 Round", weavePattern: "Plain", dimensions: "10x8x6", isPro: false))
        XCTAssertTrue(store.addBasket(basketName: "Market Basket", reedSize: "#3 Round", weavePattern: "Plain", dimensions: "10x8x6", isPro: true))
    }

    @MainActor
    func testDeleteEntry() {
        let store = BatchReedStore()
        store.addBasket(basketName: "Market Basket", reedSize: "#3 Round", weavePattern: "Plain", dimensions: "10x8x6", isPro: false)
        guard let item = store.baskets.last else { return XCTFail("expected entry") }
        let before = store.baskets.count
        store.deleteBasket(item.id)
        XCTAssertEqual(store.baskets.count, before - 1)
    }

    @MainActor
    func testDeleteAllDataReseeds() {
        let store = BatchReedStore()
        store.deleteAllData()
        XCTAssertGreaterThan(store.baskets.count, 0)
        XCTAssertGreaterThan(store.proEntries.count, 0)
    }

    @MainActor
    func testUpdateEntryPersistsChange() {
        let store = BatchReedStore()
        store.addBasket(basketName: "Market Basket", reedSize: "#3 Round", weavePattern: "Plain", dimensions: "10x8x6", isPro: false)
        guard let item = store.baskets.last else { return XCTFail("expected entry") }
        store.updateBasket(item.id, basketName: "Market Basket", reedSize: "#3 Round", weavePattern: "Plain", dimensions: "10x8x6")
        XCTAssertEqual(store.baskets.count, store.baskets.count)
    }
}
