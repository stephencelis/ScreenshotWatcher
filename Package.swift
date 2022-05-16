// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "Serial",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(name: "Serial", targets: ["Serial"]),
  ],
  dependencies: [
  ],
  targets: [
    .systemLibrary(name: "_CAsyncSequenceValidationSupport"),
    .target(name: "Serial"),
    .testTarget(
      name: "SerialTests",
      dependencies: ["Serial", "_CAsyncSequenceValidationSupport"],
      swiftSettings: [
        .unsafeFlags([
          "-Xfrontend", "-disable-availability-checking"
        ])
      ]
    ),
  ]
)
