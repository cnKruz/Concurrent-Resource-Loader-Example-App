//
//  ContentView.swift
//  ResourceLab
//
//  Concurrent Resource Loader example project.
//

import SwiftUI
import Observation

@MainActor
struct ContentView: View {

  //let apiClient: APIClientProtocol
  private let resourceLoader: ResourceLoader

  @State private var output = "No request made yet."
  @State private var isLoading = false

  init(resourceLoader: ResourceLoader) {
    self.resourceLoader = resourceLoader
  }

  var body: some View {
    ProductView(resourceLoader: resourceLoader)
  }

}

private extension ContentView {

  func fetchProduct() async {
    isLoading = true
    defer { isLoading = false }

    do {
      let product = try await resourceLoader.loadProduct(
        id: 1
      )

      output = """
            Product:
            ID: \(product.id)
            Title: \(product.title)
            Descriptiom: \(product.description)
            Price: \(product.price)
            """

    } catch {
      output = "Error: \(error)"
    }
  }

  func fetchProducts() async {
    isLoading = true
    defer { isLoading = false }

    do {
      let response = try await resourceLoader.loadProducts(
        limit: 10,
        skip: 0
      )

      output = response.products
        .map { product in
          "\(product.id) - \(product.title)"
        }
        .joined(separator: "\n")

    } catch {
      output = "Error: \(error)"
    }
  }
}


#Preview {
  ContentView(  resourceLoader:
                ResourceLoader( apiClient: MockAPIClient())
  )
}
