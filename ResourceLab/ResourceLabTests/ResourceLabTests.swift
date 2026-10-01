//
//  ResourceLabTests.swift
//  ResourceLabTests
//
//  Concurrent Resource Loader example project.
//
import Testing
@testable import ResourceLab

@Suite("ResourceLoader")

struct ResourceLoaderTests {

  // MARK: - Milestone 3: Cache

  @Test("Loading the same product twice only fetches once")
  func sameProductUsesCache() async throws {
    let apiClient = MockAPIClient()
    let loader = ResourceLoader(apiClient: apiClient)

    let first = try await loader.loadProduct(id: 1)
    let second = try await loader.loadProduct(id: 1)

    #expect(first.id == 1)
    #expect(second.id == 1)

    let callCount = await apiClient.fetchProductCalls
    #expect(callCount == 1)
  }

  @Test("Clearing cache causes the product to be fetched again")
  func clearCacheCausesRefetch() async throws {
    let apiClient = MockAPIClient()
    let loader = ResourceLoader(apiClient: apiClient)

    _ = try await loader.loadProduct(id: 1)

    await loader.clearCache()

    _ = try await loader.loadProduct(id: 1)

    let callCount = await apiClient.fetchProductCalls
    #expect(callCount == 2)
  }


  // MARK: - Milestone 4: Coalescing

  @Test("Concurrent requests for the same product share one fetch")
  func concurrentSameProductCoalesces() async throws {
    let apiClient = MockAPIClient()
    await apiClient.setDelay(.milliseconds(200))

    let loader = ResourceLoader(apiClient: apiClient)

    let products = try await withThrowingTaskGroup(
      of: Product.self
    ) { group in

      for _ in 0..<10 {
        group.addTask {
          try await loader.loadProduct(id: 1)
        }
      }

      var products: [Product] = []

      for try await product in group {
        products.append(product)
      }

      return products
    }

    #expect(products.count == 10)
    #expect(products.allSatisfy { $0.id == 1 })

    let callCount = await apiClient.fetchProductCalls
    #expect(callCount == 1)
  }


  // MARK: - Milestone 5: Failure cleanup

  @Test("A failed request can be retried")
  func failedRequestCanBeRetried() async throws {
    let apiClient = MockAPIClient()
    let loader = ResourceLoader(apiClient: apiClient)

    await apiClient.setShouldFail(true)

    do {
      _ = try await loader.loadProduct(id: 1)
      Issue.record("Expected request to throw")
    } catch {
      // Expected failure
    }

    await apiClient.setShouldFail(false)

    let product = try await loader.loadProduct(id: 1)

    #expect(product.id == 1)

    let callCount = await apiClient.fetchProductCalls
    #expect(callCount == 2)
  }
}
