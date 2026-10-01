//
//  MockAPIClient.swift
//  ResourceLab
//
//  Concurrent Resource Loader example project.
//

actor MockAPIClient: APIClientProtocol {

  enum MockError: Error {
    case forcedFailure
  }

  private(set) var fetchProductCalls = 0
  private(set) var fetchProductResponseCalls = 0

  var delay: Duration = .zero
  private var shouldFail = false

  func fetchProduct(id: Int) async throws -> Product {

    fetchProductCalls += 1

    if delay > .zero {
      try await Task.sleep(for: delay)
    }

    if shouldFail {
      throw MockError.forcedFailure
    }

    return Product(
      id: id,
      title: "Preview Product",
      description: "The Essence Mascara Lash Princess is a popular mascara known for its volumizing and lengthening effects. Achieve dramatic lashes with this long-lasting and cruelty-free formula.",
      category: "beauty",
      price: 99.99
      // whatever other required properties your Product has
    )
  }
  
  func fetchProducts(
    limit: Int?,
    skip: Int?
  ) async throws -> ProductsResponse {

    fetchProductResponseCalls += 1

    if delay > .zero {
      try await Task.sleep(for: delay)
    }

    if shouldFail {
      throw MockError.forcedFailure
    }

    return ProductsResponse(
      products: [
        Product(
          id: 1,
          title: "Product One",
          description: "The Essence Mascara Lash Princess is a popular mascara known for its volumizing and lengthening effects. Achieve dramatic lashes with this long-lasting and cruelty-free formula.",
          category: "beauty",
          price: 49.99
        ),
        Product(
          id: 2,
          title: "Product Two",
          description: "The Essence Mascara Lash Princess is a popular mascara known for its volumizing and lengthening effects. Achieve dramatic lashes with this long-lasting and cruelty-free formula.",
          category: "beauty",
          price: 79.99
        )
      ],
      total: 2,
      skip: 0,
      limit: 10
    )
  }

  // MARK: Helpers
  func setDelay(_ delay: Duration) {
    self.delay = delay
  }

  func setShouldFail(_ shouldFail: Bool) {
    self.shouldFail = shouldFail
  }
}
