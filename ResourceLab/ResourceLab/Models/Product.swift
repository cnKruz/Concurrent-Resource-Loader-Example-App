//
//  Product.swift
//  ResourceLab
//
//  Concurrent Resource Loader example project.
//

import Foundation

struct ProductsResponse: Codable, Sendable {
  let products: [Product]
  let total: Int
  let skip: Int
  let limit: Int
}

struct Product: Codable, Identifiable, Sendable {
  let id: Int
  let title: String
  let description: String
  let category: String
  let price: Double
}
