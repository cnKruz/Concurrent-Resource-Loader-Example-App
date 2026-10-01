//
//  AppConfiguration.swift
//  ResourceLab
//
//  Concurrent Resource Loader example project.
//
import Foundation

struct AppConfiguration {
  let apiBaseURL: URL

  static func load(
    bundle: Bundle = .main
  ) throws -> AppConfiguration {

    guard let scheme = bundle.object(
      forInfoDictionaryKey: "API_SCHEME"
    ) as? String else {
      throw ConfigurationError.missingAPIScheme
    }

    guard let host = bundle.object(
      forInfoDictionaryKey: "API_HOST"
    ) as? String else {
      throw ConfigurationError.missingAPIHost
    }

    var components = URLComponents()
    components.scheme = scheme
    components.host = host

    guard let baseURL = components.url else {
      throw ConfigurationError.invalidBaseURL
    }

    return AppConfiguration(
      apiBaseURL: baseURL
    )
  }
}
