//
//  ProductViewModel.swift
//  ResourceLab
//
//  Concurrent Resource Loader example project.
//
import Observation
import SwiftUI

@MainActor
@Observable
final class ProductViewModel {

  enum ViewState {
    case idle
    case loading
    case loaded(Product)
    case failed(String)
  }

  private(set) var viewState: ViewState = .idle
  private var resourceLoader: ResourceLoader

  var products: [Product] = []
  var isLoading = false
  var error: Error?

  init(resourceLoader: ResourceLoader ) {
    self.resourceLoader = resourceLoader
  }

  func loadProduct(id:Int) async {
    viewState = .loading

    do {
      let product = try await resourceLoader.loadProduct(id: id)
      viewState = .loaded(product)
    } catch {
      viewState = .failed("\(error.localizedDescription)")
    }

  }

  func loadSameProduct5Times(id: Int) async {
    viewState = .loading

    do {

      let products = try await withThrowingTaskGroup( of: Product.self) { group in
        for _ in 0..<5 {
          group.addTask {
            try await self.resourceLoader.loadProduct(id: id)
          }
        }

        var products:[Product] = []

        for try await product in group {
          products.append(product)
        }

        return products
      }

      if let product = products.first {
        viewState = .loaded(product)
      }

    } catch {
      viewState = .failed("\(error.localizedDescription)")
    }

  }
  
  func clearCache() async {
    viewState = .loading

    defer{
      viewState = .idle
    }

    await resourceLoader.clearCache()
  }

}
