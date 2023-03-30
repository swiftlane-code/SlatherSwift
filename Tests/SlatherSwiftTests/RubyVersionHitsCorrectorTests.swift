//

import Foundation
@testable import SlatherSwift
import XCTest

final class RubyVersionHitsCorrectorTests: XCTestCase {
	var corrector: HitsCorrecting!

	override func setUp() {
		super.setUp()

		corrector = RubyVersionHitsCorrector()
	}

	func testCorrect() {
		// given
		let cases = [
			0: 0,
			5: 5,
			11: 11,
			123: 123,
			999: 999,
			1000: 1000,
			1001: 1000,
			3608: 3600,
			4019: 4010,
			9628: 9620,
			1909: 1900,
			15015: 15000,
		]

		for (given, expected) in cases {
			// when
			let gotten = corrector.correct(given)

			// then
			XCTAssertEqual(gotten, expected)
		}
	}
}
