//
//  ResourceLabApp.swift
//  ResourceLab
//
//  Concurrent Resource Loader example project.
//

import SwiftUI
import CoreData

@main
struct ResourceLabApp: App {

    private let configuration: AppConfiguration
    private let resourceLoader: ResourceLoader
    let persistenceController = PersistenceController.shared

    init() {
      do {
        let configuration = try AppConfiguration.load()

        self.configuration = configuration
        let apiClient = APIClient(
          baseURL: configuration.apiBaseURL
        )
        self.resourceLoader = ResourceLoader(apiClient: apiClient)

      } catch {
        fatalError(
          "Failed to load application configuration: \(error)"
        )
      }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(resourceLoader: resourceLoader)
                //.environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
