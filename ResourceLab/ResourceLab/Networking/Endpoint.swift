//
//  Endpoint.swift
//  ResourceLab
//
//  Concurrent Resource Loader example project.
//
import Foundation

struct Endpoint {
  let path: String
  let queryItems: [URLQueryItem]
}

extension Endpoint {

  static func product(id: Int) -> Endpoint {
    Endpoint(
      path: "/products/\(id)",
      queryItems: []
    )
  }

  static func products(limit: Int?, skip: Int?) -> Endpoint {

    var queryItems: [URLQueryItem] = []

    if let limit {
      queryItems.append(
        URLQueryItem(
          name: "limit",
          value: "\(limit)"
        )
      )
    }

    if let skip {
      queryItems.append(
        URLQueryItem(
          name: "skip",
          value: "\(skip)"
        )
      )
    }

    return Endpoint(
      path: "/products",
      queryItems: queryItems
    )
  }
}
