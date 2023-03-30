//

import Foundation
@testable import SlatherSwift
import SwiftlaneCore
import XCTest

final class ArtifactsNamesCalculatorTests: XCTestCase {
	var calculator: ArtifactsNamesCalculator!

	override func setUp() {
		super.setUp()

		calculator = ArtifactsNamesCalculator()
	}

	// MARK: Package Name Calculation

	func testWithOrWithoutProjectRootDirTrailingSlaches() throws {
		// given
		let projectRootDirsPaths = [
			"/Users/nevermind/Projects/the-app",
			"/Users/nevermind/Projects/the-app/",
		]

		let filePath =
			"/Users/nevermind/Projects/the-app/Name/Main/Helpers/EnvironmentDataService/EnvironmentDataService.swift"

		try projectRootDirsPaths.forEach {
			let projectRootDir = try AbsolutePath($0)

			// when
			let packageName = try calculator.calculatePackageName(filePath, projectRootDir: projectRootDir)

			// than
			let expectedPackageName = "Name.Main.Helpers.EnvironmentDataService"
			XCTAssertEqual(
				packageName, expectedPackageName,
				"Package name for project dir path \"\($0)\" is incorrect"
			)
		}
	}
}
