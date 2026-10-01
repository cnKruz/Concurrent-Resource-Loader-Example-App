//
//  ProductView.swift
//  ResourceLab
//
//  Concurrent Resource Loader example project.
//

import SwiftUI
import Observation

struct ProductView: View {

  @State private var viewModel: ProductViewModel
  @State private var productID = "1"

  @FocusState private var isProductIDFocused: Bool

  init(resourceLoader: ResourceLoader) {
        _viewModel = State(
          initialValue: ProductViewModel(resourceLoader: resourceLoader)
        )
  }

    var body: some View {
      NavigationStack {
        Form {
          inputSection

          resultSection

          actionsSection
        }
      }
      .navigationTitle("Concurrent Resource Loader")
      .scrollDismissesKeyboard(.interactively)
    }

  private var inputSection: some View {
    Section("Product") {
      TextField("Product Id", text: $productID)
        .keyboardType(.numberPad)
        .focused($isProductIDFocused)
        .toolbar {
          ToolbarItemGroup(placement: .keyboard) {
            Spacer()

            Button("Done") {
              isProductIDFocused = false
            }
          }
        }

      Button("Load Product") {
        guard let id = Int(productID) else {
          return
        }

        isProductIDFocused = false

        Task {
          await viewModel.loadProduct(id: id)
        }
      }
    }
  }

  private var actionsSection: some View {
    Section("Concurrency Demo") {
      Button("Load Same Product 5x") {
        guard let id = Int(productID) else {
          return
        }

        Task {
          await viewModel.loadSameProduct5Times(id: id)
        }
      }

      Button("Clear Cache", role: .destructive) {
        Task {
          await viewModel.clearCache()
        }
      }
    }
  }

  @ViewBuilder
  private var resultSection: some View {
    Section("Result") {
      switch viewModel.viewState {
      case .idle:
        Text("Enter a product ID and load a product.")
          .foregroundStyle(.secondary)
      case .loading:
        HStack {
          ProgressView()
          Text("Loading...")
        }
      case .loaded(let product):
        productContent(product)
      case .failed(let message):
        ContentUnavailableView("Unable to Load Product",
                               image: "exclamationmark.triangle",
                               description: Text(message))

      }

    }
  }

  @ViewBuilder
  private func productContent(_ product: Product) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(product.title)
        .font(.headline)

      Text(product.category.capitalized)
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Text(product.price, format: .currency(code: "MXN"))
        .font(.title3)
        .bold()

      Text(product.description)
        .font(.body)
    }
  }

}

#Preview {
    let apiClient = MockAPIClient()
    let resourceLoader = ResourceLoader(apiClient: apiClient)

    ProductView(resourceLoader: resourceLoader)
}
