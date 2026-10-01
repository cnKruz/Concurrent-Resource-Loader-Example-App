//
//  ConfigurationError.swift
//  ResourceLab
//
//  Concurrent Resource Loader example project.
//

enum ConfigurationError: Error {
  case missingAPIScheme
  case missingAPIHost
  case invalidBaseURL
}
