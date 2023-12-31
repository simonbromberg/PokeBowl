// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "PokeBowl",
  platforms: [.iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "PokeBowl",
      targets: ["PokeBowl"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/simonbromberg/AsyncMap.git", from: "0.0.1"),
    .package(url: "https://github.com/simonbromberg/MatchingGame.git", from: "0.0.1"),
    .package(url: "https://github.com/simonbromberg/OptionalUnwrap.git", from: "0.0.1"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "PokeBowl",
      dependencies: [
        .product(name: "AsyncMap", package: "AsyncMap"),
        .product(name: "MatchingGame", package: "MatchingGame"),
        .product(name: "OptionalUnwrap", package: "OptionalUnwrap"),
      ]
    ),
    .testTarget(
      name: "PokeBowlTests",
      dependencies: ["PokeBowl"]
    ),
  ]
)
