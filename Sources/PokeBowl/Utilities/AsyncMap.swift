//
//  AsyncMap.swift
//
//
//  Created by Simon Bromberg on 2023-12-24.
//

public extension Optional {
  func map<T>(
    transform: (Wrapped) async throws -> T
  ) async rethrows -> T? {
    guard case let .some(value) = self else {
      return nil
    }
    return try await transform(value)
  }
}

public extension Sequence {
  func map<T>(
    _ transform: (Element) async throws -> T
  ) async rethrows -> [T] {
    var values = [T]()

    for element in self {
      try await values.append(transform(element))
    }

    return values
  }

  func compactMap<T>(
    _ transform: (Element) async throws -> T?
  ) async rethrows -> [T] {
    var values = [T]()

    for element in self {
      if let transformed = try await transform(element) {
        values.append(transformed)
      }
    }

    return values
  }

  func forEach(
    _ operation: (Element) async throws -> Void
  ) async rethrows {
    for element in self {
      try await operation(element)
    }
  }
}
