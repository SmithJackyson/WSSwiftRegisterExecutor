// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "WSSwiftRegisterExecutor",
  platforms: [.macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v9), .macCatalyst(.v15)],
  products: [
    .library(
      name: "WSSwiftRegisterExecutor",
      targets: ["WSSwiftRegisterExecutor"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "604.0.0-latest"),
    .package(url: "https://github.com/SmithJackyson/WSExecutorCommon.git", from: "0.0.1"),
  ],
  targets: [
    .macro(
      name: "WSSwiftRegisterExecutorMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
        .product(name: "WSExecutorCommon", package: "WSExecutorCommon")
      ]
    ),
    
    .target(
      name: "WSSwiftRegisterExecutor",
      dependencies: [
        "WSSwiftRegisterExecutorMacros",
        .product(name: "WSExecutorCommon", package: "WSExecutorCommon")
      ],
      swiftSettings: [
        .enableUpcomingFeature("ApproachableConcurrency"),
      ],
    ),
    
    .executableTarget(
      name: "WSSwiftRegisterExecutorClient",
      dependencies: ["WSSwiftRegisterExecutor"],
      swiftSettings: [
        .enableUpcomingFeature("ApproachableConcurrency"),
      ],
    ),
    
    .testTarget(
      name: "WSSwiftRegisterExecutorTests",
      dependencies: [
        "WSSwiftRegisterExecutorMacros",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ],
      path: "WSSwiftRegisterExecutorTests",
      swiftSettings: [
        .enableUpcomingFeature("ApproachableConcurrency"),
      ],
    ),
  ]
)
