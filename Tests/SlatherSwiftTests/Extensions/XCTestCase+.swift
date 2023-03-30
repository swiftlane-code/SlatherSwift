//

import XCTest

extension XCTestCase {
	func skipIfLongRunningTestsDisabled() throws {
		if !ProcessInfo.processInfo.arguments.contains(.SMEnableLongRunningTests) {
			throw XCTSkip(
				"Warning: Long running tests disabled because of \"\(LaunchArgument.SMEnableLongRunningTests)\" disabled."
			)
		}
	}
}
