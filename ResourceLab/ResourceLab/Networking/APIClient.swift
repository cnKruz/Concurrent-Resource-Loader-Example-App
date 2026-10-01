//
//  APIClient.swift
//  ResourceLab
//
//  Concurrent Resource Loader example project.
//
import Foundation

protocol APIClientProtocol: Sendable {
  func fetchProduct(id: Int) async throws -> Product
  func fetchProducts(limit: Int?, skip:Int?) async throws -> ProductsResponse
}

final class APIClient: APIClientProtocol {
  private let baseURL: URL
  private let session: URLSession

  init(baseURL: URL, session: URLSession = .shared) {
    self.baseURL = baseURL
    self.session = session
  }

  func fetchProduct(id: Int) async throws -> Product {

    // 1. Construct endpoint
    let productEndpoint = Endpoint.product(id: id)
    let requestUrl = try url(for: productEndpoint)

    // 2. Perform URLSession request
    let (data, response) = try await session.data(from: requestUrl)

    // 3. Validate response
    guard let httpResponse = response as? HTTPURLResponse,
          (200..<300).contains(httpResponse.statusCode) else {
      throw URLError(.badServerResponse)
    }

    // 4. Decode Product
    let result = try JSONDecoder().decode(
      Product.self,
      from: data
    )

    // 5. Return Product
    return result
  }

  func fetchProducts(limit: Int?, skip:Int?) async throws -> ProductsResponse {
    // 1. Construct endpoint

    let productsEndpoint = Endpoint.products(limit: limit, skip: skip)
    let requestUrl = try url(for: productsEndpoint)

    // 2. Perform URLSession request
    let (data, response) = try await session.data(from: requestUrl)
    // 3. Validate response
    guard let httpResponse = response as? HTTPURLResponse,
          (200..<300).contains(httpResponse.statusCode) else {
      throw URLError(.badServerResponse)
    }
    // 4. Decode Products
    let result = try JSONDecoder().decode(
      ProductsResponse.self,
      from: data
    )
    // 5. Return Product
    return result
  }

  // MARK: Helpers
  private func url(for endpoint: Endpoint) throws -> URL {
    guard var components = URLComponents(
      url: baseURL,
      resolvingAgainstBaseURL: false
    ) else {
      throw APIError.invalidURL
    }

    components.path = endpoint.path

    if !endpoint.queryItems.isEmpty {
      components.queryItems = endpoint.queryItems
    }

    guard let url = components.url else {
      throw APIError.invalidURL
    }

    return url
  }
}
