//
//  APIError.swift
//  ResourceLab
//
//  Concurrent Resource Loader example project.
//
import Foundation

enum APIError: Error {
  case invalidURL
  case invalidResponse
  case httpError(Int)
  case decodingError(Error)
}
