// swift-tools-version:5.6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "SlatherSwift",
	platforms: [.macOS(.v12)],
	products: [
		.executable(name: "SlatherSwift", targets: ["SlatherSwift"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser", "1.1.4"..<"1.2.0"), // 1.2.0 Bugs (default value for @Flag)
		.package(url: "https://github.com/swiftlane-code/SwiftlaneCore.git", from: "0.9.0"),
	],
	targets: [
		.executableTarget(
			name: "SlatherSwift",
			dependencies: [
				.product(name: "SwiftlaneCore", package: "SwiftlaneCore"),
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			],
			resources: [.copy("Meta")]
		),
		.testTarget(
			name: "SlatherSwiftTests",
			dependencies: [
				"SlatherSwift",
				.product(name: "SwiftlaneUnitTestTools", package: "SwiftlaneCore"),
			],
			resources: [
				.copy("Stubs"),
			]
		),
	]
)
