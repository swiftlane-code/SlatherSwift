//

import Foundation
@testable import SlatherSwift
import SwiftlaneCore
import XCTest

final class PackageNameCalculatorTests: XCTestCase {
	var calculator: PackageNameCalculator!

	override func setUp() {
		super.setUp()

		calculator = PackageNameCalculator()
	}

	func testNamesCalculationForRootDirPathWithEndingSlash() throws {
		// given
		let projectRootDir = try AbsolutePath("/Users/nevermind/Projects/app/")
		let filePath = try AbsolutePath(
			"/Users/nevermind/Projects/app/Name/Main/AnalyticsParametersManager/AnalyticParametersManager.swift"
		)

		// when
		let gottenPkgName = try calculator.calculate(filePath, projectRootDir: projectRootDir)

		// then
		let expectedPkgName = "Name.Main.AnalyticsParametersManager"
		XCTAssertEqual(gottenPkgName, expectedPkgName)
	}

	func testNamesCalculationForRootDirPathWithouEndingSlash() throws {
		// given
		let projectRootDir = try AbsolutePath("/Users/nevermind/Projects/app")
		let filePath = try AbsolutePath(
			"/Users/nevermind/Projects/app/Name/Main/AnalyticsParametersManager/AnalyticParametersManager.swift"
		)

		// when
		let gottenPkgName = try calculator.calculate(filePath, projectRootDir: projectRootDir)

		// then
		let expectedPkgName = "Name.Main.AnalyticsParametersManager"
		XCTAssertEqual(gottenPkgName, expectedPkgName)
	}
}
