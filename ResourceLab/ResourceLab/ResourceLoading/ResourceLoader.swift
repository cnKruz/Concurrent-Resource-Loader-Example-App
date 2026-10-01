//
//  ResourceLoader.swift
//  ResourceLab
//
//  Concurrent Resource Loader example project.
//

actor ResourceLoader {
  private let apiClient: APIClientProtocol
  private var productCache: [ Int: Product] = [:]
  private var productsResponseCache: [ProductsRequestKey: ProductsResponse] = [:]

  private var productTasks: [Int: Task<Product, Error> ] = [:]
  private var productsResponseTasks: [ProductsRequestKey: Task<ProductsResponse, Error>] = [:]

  init(apiClient: APIClientProtocol) {
    self.apiClient = apiClient
  }

  func loadProduct(id:Int) async throws -> Product {
    // check if product is cached
    if let product = productCache[id] {
      return product
    }
    // check if there is a task in progress
    if let runningTask = productTasks[id] {
      return try await runningTask.value
    }
    // not cached or not running task, create a task and sotore it when done
    let task = Task {
      try await apiClient.fetchProduct(id: id)
    }

    productTasks[id] = task

    defer {
      // remove from running task
      productTasks[id] = nil
    }

    let product = try await task.value

    productCache[id] = product

    return product
  }

  func loadProducts(limit: Int?, skip: Int?) async throws -> ProductsResponse{

    let key = ProductsRequestKey(
      limit: limit,
      skip: skip
    )

    if let response = productsResponseCache[key] {
      return response
    }

    if let runningTask = productsResponseTasks[key] {
      return try await runningTask.value
    }

    let task = Task {
      try await apiClient.fetchProducts(
        limit: limit,
        skip: skip
      )
    }

    productsResponseTasks[key] = task

    defer {
      productsResponseTasks[key] = nil
    }

    let response = try await task.value

    productsResponseCache[key] = response

    return response
  }

  func clearCache() {
    productCache.removeAll()
    productsResponseCache.removeAll()
  }

 // MARK: Helpers

  private struct ProductsRequestKey: Hashable {
    let limit: Int?
    let skip: Int?
  }

}
