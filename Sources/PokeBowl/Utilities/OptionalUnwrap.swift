//
//  OptionalUnwrap.swift
//
//  Created by Simon Bromberg on 2023-12-24.
//

public struct NilError: Error {
  public let file: String
  public let line: UInt
  public let column: UInt
  public let function: String

  public init(
    file: String = #fileID,
    line: UInt = #line,
    column: UInt = #column,
    function: String = #function
  ) {
    self.file = file
    self.line = line
    self.column = column
    self.function = function
  }
}

public extension Optional {
  func unwrap(
    file: String = #fileID,
    line: UInt = #line,
    column: UInt = #column,
    function: String = #function
  ) throws -> Wrapped {
    try unwrap(
      or: NilError(
        file: file,
        line: line,
        column: column,
        function: function
      )
    )
  }

  func unwrap(or error: @autoclosure () -> Error) throws -> Wrapped {
    switch self {
    case let .some(w): return w
    case .none: throw error()
    }
  }

  @discardableResult
  func unwrap<U>(_ transform: (Wrapped) throws -> U) rethrows -> U? {
    try map(transform)
  }
}
