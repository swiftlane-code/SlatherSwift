//

import Foundation
@testable import SlatherSwift
import XCTest

struct TestSegmentsModel: Decodable {
	let segments: [Segment]
}

final class SegmentsAnalyzerTests: XCTestCase {
	var segmentsAnalyzer: SegmentsAnalyzer!

	override func setUp() {
		super.setUp()

		segmentsAnalyzer = SegmentsAnalyzer()
	}

	func testLinePresentationCountVarOne() throws {
		// given
		let json = """
		{ "segments": [
		[
				  17,
				  50,
				  0,
				  true,
				  true,
				  false
				],
				[
				  17,
				  75,
				  0,
				  true,
				  false,
				  false
				]
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let info = segmentsAnalyzer.linePresentationCount(lineNumber: 17, segments: segments)

		// then
		let expected = LineInfo(tested: 0, total: 2)

		XCTAssertEqual(info, expected)
	}

	func testLinePresentationCountVarTwo() throws {
		// given
		let json = """
		{ "segments": [
		[
		  25,
		  67,
		  0,
		  true,
		  true,
		  false
		],
		[
		  25,
		  104,
		  1,
		  true,
		  false,
		  false
		]
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let info = segmentsAnalyzer.linePresentationCount(lineNumber: 25, segments: segments)

		// then
		let expected = LineInfo(tested: 1, total: 2)

		XCTAssertEqual(info, expected)
	}

	func testLinePresentationCountVarThree() throws {
		// given
		let json = """
		{ "segments": [
					[
					  50,
					  49,
					  0,
					  true,
					  true,
					  false
					],
					[
					  50,
					  64,
					  3,
					  true,
					  false,
					  false
					],
					[
					  50,
					  67,
					  3,
					  true,
					  true,
					  false
					],
					[
					  50,
					  103,
					  1,
					  true,
					  true,
					  false
					],
					[
					  50,
					  118,
					  3,
					  true,
					  false,
					  false
					]
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let info = segmentsAnalyzer.linePresentationCount(lineNumber: 50, segments: segments)

		// then
		let expected = LineInfo(tested: 4, total: 5)

		XCTAssertEqual(info, expected)
	}

	func testLinePresentationCountVarFour() throws {
		// given
		let json = """
		{ "segments": [
					[
					  13,
					  44,
					  0,
					  true,
					  true,
					  false
					]
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let info = segmentsAnalyzer.linePresentationCount(lineNumber: 13, segments: segments)

		// then
		let expected = LineInfo(tested: 0, total: 1)

		XCTAssertEqual(info, expected)
	}

	func testLinePresentationCountVarFive() throws {
		// given
		let json = """
		{ "segments": [
					[
					  9,
					  65,
					  2,
					  true,
					  true,
					  false
					],
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let info = segmentsAnalyzer.linePresentationCount(lineNumber: 9, segments: segments)

		// then
		let expected = LineInfo(tested: 1, total: 1)

		XCTAssertEqual(info, expected)
	}

	func testLinePresentationCountVarSix() throws {
		// given
		let json = """
		{ "segments": [
					[
					  33,
					  33,
					  14,
					  true,
					  true,
					  false
					],
					[
					  33,
					  54,
					  0,
					  false,
					  false,
					  false
					],
					[
					  34,
					  39,
					  14,
					  true,
					  true,
					  false
					],
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let info = segmentsAnalyzer.linePresentationCount(lineNumber: 33, segments: segments)

		// then
		let expected = LineInfo(tested: 1, total: 1)

		XCTAssertEqual(info, expected)
	}

	func testLinePresentationCountVarSeven() throws {
		// given
		let json = """
		{ "segments": [
				   [
					  31,
					  13,
					  0,
					  true,
					  true,
					  false
					],
					[
					  31,
					  14,
					  0,
					  false,
					  true,
					  false
					],
					[
					  31,
					  14,
					  0,
					  true,
					  false,
					  false
					],
					[
					  36,
					  6,
					  0,
					  false,
					  false,
					  false
					]

		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let info = segmentsAnalyzer.linePresentationCount(lineNumber: 31, segments: segments)

		// then
		let expected = LineInfo(tested: 0, total: 2)

		XCTAssertEqual(info, expected)
	}

	func testLinePresentationCountVarEight() throws {
		// given
		let json = """
		{ "segments": [
								[
									22,
									49,
									0,
									true,
									true,
									false
								],
								[
									24,
									14,
									0,
									true,
									true,
									false
								],
								[
									24,
									20,
									0,
									true,
									true,
									false
								],
								[
									26,
									14,
									0,
									false,
									true,
									false
								],
								[
									26,
									14,
									0,
									true,
									false,
									false
								],
								[
									28,
									6,
									0,
									false,
									false,
									false
								]

		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let info = segmentsAnalyzer.linePresentationCount(lineNumber: 26, segments: segments)

		// then
		let expected = LineInfo(tested: 0, total: 1)

		XCTAssertEqual(info, expected)
	}

	// MARK: - lineHits

	func testGetLineHitsVarOne() throws {
		// given
		let json = """
		{ "segments": [
				  [
					  68,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  70,
					  76,
					  5,
					  true,
					  true,
					  false
					],
					[
					  75,
					  30,
					  1,
					  true,
					  true,
					  false
					],
					[
					  75,
					  56,
					  5,
					  true,
					  false,
					  false
					],
					[
					  78,
					  6,
					  0,
					  false,
					  false,
					  false
					],
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let hits = segmentsAnalyzer.lineHits(lineNumber: 70, segments: segments)

		// then
		let expected = 5

		XCTAssertEqual(hits, expected)
	}

	func testGetLineHitsVarTwo() throws {
		// given
		let json = """
		{ "segments": [
					[
					  85,
					  45,
					  1,
					  true,
					  true,
					  false
					],
					[
					  90,
					  10,
					  2,
					  true,
					  true,
					  false
					],
					[
					  90,
					  16,
					  1,
					  true,
					  true,
					  false
					],
					[
					  93,
					  10,
					  2,
					  true,
					  true,
					  false
					],
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let hits = segmentsAnalyzer.lineHits(lineNumber: 90, segments: segments)

		// then
		XCTAssertEqual(hits, 2)
	}

	func testGetLineHitsVarThree() throws {
		// given
		let json = """
		{ "segments": [
					[
					  13,
					  44,
					  0,
					  true,
					  true,
					  false
					],
					[
					  17,
					  50,
					  0,
					  true,
					  true,
					  false
					],
					[
					  17,
					  75,
					  0,
					  true,
					  false,
					  false
					],
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let hits = segmentsAnalyzer.lineHits(lineNumber: 17, segments: segments)

		// then
		XCTAssertEqual(hits, 0)
	}

	func testGetLineHitsVarFour() throws {
		// given
		let json = """
		{ "segments": [
					[
					  25,
					  104,
					  1,
					  true,
					  false,
					  false
					],
					[
					  26,
					  63,
					  1,
					  true,
					  true,
					  false
					],
					[
					  26,
					  80,
					  1,
					  true,
					  false,
					  false
					],
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let hits = segmentsAnalyzer.lineHits(lineNumber: 26, segments: segments)

		// then
		XCTAssertEqual(hits, 1)
	}

	func testGetLineHitsVarFive() throws {
		// given
		let json = """
		{ "segments": [
					[
					  24,
					  9,
					  0,
					  true,
					  true,
					  false
					],
					[
					  25,
					  31,
					  5,
					  true,
					  false,
					  false
					],
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let hits = segmentsAnalyzer.lineHits(lineNumber: 25, segments: segments)

		// then
		XCTAssertEqual(hits, 0)
	}

	func testGetLineHitsVarSix() throws {
		// given
		let json = """
		{ "segments": [
				   [
					  133,
					  7,
					  28,
					  true,
					  true,
					  false
					],
					[
					  159,
					  72,
					  11,
					  true,
					  true,
					  false
					],
					[
					  161,
					  54,
					  0,
					  true,
					  true,
					  false
					],
					[
					  161,
					  55,
					  11,
					  true,
					  false,
					  false
					],
					[
					  162,
					  60,
					  0,
					  true,
					  true,
					  false
					],
					[
					  162,
					  61,
					  11,
					  true,
					  false,
					  false
					],
					[
					  163,
					  10,
					  28,
					  true,
					  true,
					  false
					],
					[
					  163,
					  16,
					  17,
					  true,
					  true,
					  false
					],
					[
					  167,
					  10,
					  28,
					  true,
					  true,
					  false
					],]
		}
		"""

		let segments = try decode(json: json)

		// when
		let hits = segmentsAnalyzer.lineHits(lineNumber: 164, segments: segments)

		// then
		XCTAssertEqual(hits, 17)
	}

	func testGetLineHitsVarSeven() throws {
		// given
		let json = """
		{ "segments": [
					[
					  34,
					  7,
					  3,
					  true,
					  true,
					  false
					],
					[
					  45,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  47,
					  35,
					  3,
					  true,
					  true,
					  false
					],
					[
					  49,
					  63,
					  1,
					  true,
					  true,
					  false
					],
					[
					  49,
					  82,
					  3,
					  true,
					  false,
					  false
					],
					[
					  50,
					  49,
					  0,
					  true,
					  true,
					  false
					],
					[
					  50,
					  64,
					  3,
					  true,
					  false,
					  false
					],
					[
					  50,
					  67,
					  3,
					  true,
					  true,
					  false
					],
					[
					  50,
					  103,
					  1,
					  true,
					  true,
					  false
					],
					[
					  50,
					  118,
					  3,
					  true,
					  false,
					  false
					],
					[
					  60,
					  6,
					  0,
					  false,
					  false,
					  false
					],

		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let hits = segmentsAnalyzer.lineHits(lineNumber: 50, segments: segments)

		// then
		XCTAssertEqual(hits, 3)
	}

	func testGetLineHitsVarEight() throws {
		// given
		let json = """
		{ "segments": [
				   [
					  112,
					  36,
					  2,
					  true,
					  true,
					  false
					],
					[
					  115,
					  47,
					  1,
					  true,
					  true,
					  false
					],
					[
					  118,
					  22,
					  2,
					  true,
					  true,
					  false
					],
					[
					  119,
					  18,
					  2,
					  true,
					  false,
					  false
					],
					[
					  120,
					  31,
					  1,
					  true,
					  true,
					  false
					],
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let hits = segmentsAnalyzer.lineHits(lineNumber: 118, segments: segments)

		// then
		XCTAssertEqual(hits, 2)
	}

	func testGetLineHitsVarNine() throws {
		// given
		let json = """
		{ "segments": [
				  [
					  24,
					  7,
					  15,
					  true,
					  true,
					  false
					],
					[
					  28,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  34,
					  69,
					  2,
					  true,
					  true,
					  false
					],
					[
					  38,
					  9,
					  1,
					  true,
					  true,
					  false
					],
					[
					  39,
					  84,
					  2,
					  true,
					  false,
					  false
					],
					[
					  40,
					  9,
					  1,
					  true,
					  true,
					  false
					],
					[
					  41,
					  98,
					  2,
					  true,
					  false,
					  false
					],
					[
					  42,
					  10,
					  2,
					  true,
					  true,
					  false
					],
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let hits = segmentsAnalyzer.lineHits(lineNumber: 38, segments: segments)

		// then
		XCTAssertEqual(hits, 2)
	}

	func testGetLineHitsVarTen() throws {
		// given
		let json = """
		{ "segments": [
				  [
					  24,
					  7,
					  15,
					  true,
					  true,
					  false
					],
					[
					  28,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  34,
					  69,
					  2,
					  true,
					  true,
					  false
					],
					[
					  38,
					  9,
					  1,
					  true,
					  true,
					  false
					],
					[
					  39,
					  84,
					  2,
					  true,
					  false,
					  false
					],
					[
					  40,
					  9,
					  1,
					  true,
					  true,
					  false
					],
					[
					  41,
					  98,
					  2,
					  true,
					  false,
					  false
					],
					[
					  42,
					  10,
					  2,
					  true,
					  true,
					  false
					],
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let hits = segmentsAnalyzer.lineHits(lineNumber: 40, segments: segments)

		// then
		XCTAssertEqual(hits, 2)
	}

	func testGetLineHitsVarEleven() throws {
		// given
		let json = """
		{ "segments": [
				   [
					  24,
					  7,
					  15,
					  true,
					  true,
					  false
					],
					[
					  28,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  34,
					  69,
					  2,
					  true,
					  true,
					  false
					],
					[
					  38,
					  9,
					  1,
					  true,
					  true,
					  false
					],
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let hits = segmentsAnalyzer.lineHits(lineNumber: 34, segments: segments)

		// then
		XCTAssertEqual(hits, 2)
	}

	func testGetLineHitsVarTwelve() throws {
		// given
		let json = """
		{ "segments": [
				   [
					  91,
					  14,
					  4,
					  true,
					  false,
					  false
					],
					[
					  93,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  95,
					  48,
					  4,
					  true,
					  true,
					  false
					],
					[
					  96,
					  64,
					  2,
					  true,
					  true,
					  false
					],
					[
					  96,
					  108,
					  4,
					  true,
					  false,
					  false
					],
					[
					  98,
					  14,
					  2,
					  true,
					  true,
					  false
					],
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let hits = segmentsAnalyzer.lineHits(lineNumber: 96, segments: segments)

		// then
		XCTAssertEqual(hits, 4)
	}

	func testGetLineHitsVarThirteen() throws {
		// given
		let json = """
		{ "segments": [
					[
					  57,
					  54,
					  1,
					  true,
					  true,
					  false
					],
					[
					  59,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  61,
					  90,
					  1,
					  true,
					  true,
					  false
					],
					[
					  64,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  70,
					  7,
					  1,
					  true,
					  true,
					  false
					],
		]
		}
		"""

		let segments = try decode(json: json)

		let testCases = [
			61: 1,
			62: 1,
			63: 1,
			64: 1,
		]

		for (lineNumber, expectedHits) in testCases {
			// when
			let hits = segmentsAnalyzer.lineHits(lineNumber: lineNumber, segments: segments)
			// then
			XCTAssertEqual(
				hits,
				expectedHits,
				"Hits for line \(lineNumber) should be \(expectedHits), got \(String(describing: hits))"
			)
		}
	}

	func testGetLineHitsVarFourteen() throws {
		// given
		let json = """
		{ "segments": [
					[
					  24,
					  7,
					  15,
					  true,
					  true,
					  false
					],
					[
					  28,
					  6,
					  0,
					  false,
					  false,
					  false
					],
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let hits = segmentsAnalyzer.lineHits(lineNumber: 28, segments: segments)
		// then
		XCTAssertEqual(hits, 15)
	}

	func testGetLineHitsVarFiveteen() throws {
		// given
		let json = """
		{ "segments": [
				  [
					  24,
					  7,
					  15,
					  true,
					  true,
					  false
					],
					[
					  28,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  34,
					  69,
					  2,
					  true,
					  true,
					  false
					],
					[
					  38,
					  9,
					  1,
					  true,
					  true,
					  false
					],
					[
					  39,
					  84,
					  2,
					  true,
					  false,
					  false
					],
					[
					  40,
					  9,
					  1,
					  true,
					  true,
					  false
					],
		]
		}
		"""

		let segments = try decode(json: json)

		// when
		let hits = segmentsAnalyzer.lineHits(lineNumber: 38, segments: segments)
		// then
		XCTAssertEqual(hits, 2)
	}

	func testGetLineHitsVarSixteen() throws {
		// given
		let json = """
		{ "segments": [
					[
					  24,
					  7,
					  15,
					  true,
					  true,
					  false
					],
					[
					  28,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  34,
					  69,
					  2,
					  true,
					  true,
					  false
					],
					[
					  38,
					  9,
					  1,
					  true,
					  true,
					  false
					],
					[
					  39,
					  84,
					  2,
					  true,
					  false,
					  false
					],
					[
					  40,
					  9,
					  1,
					  true,
					  true,
					  false
					],
					[
					  41,
					  98,
					  2,
					  true,
					  false,
					  false
					],
					[
					  42,
					  10,
					  2,
					  true,
					  true,
					  false
					],
					[
					  43,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  53,
					  53,
					  1,
					  true,
					  true,
					  false
					],
					[
					  55,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  57,
					  54,
					  1,
					  true,
					  true,
					  false
					],
					[
					  59,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  61,
					  90,
					  1,
					  true,
					  true,
					  false
					],
					[
					  64,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  70,
					  7,
					  1,
					  true,
					  true,
					  false
					],
					[
					  72,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  78,
					  103,
					  3,
					  true,
					  true,
					  false
					],
					[
					  80,
					  9,
					  1,
					  true,
					  true,
					  false
					],
					[
					  82,
					  43,
					  3,
					  true,
					  false,
					  false
					],
					[
					  84,
					  9,
					  1,
					  true,
					  true,
					  false
					],
					[
					  85,
					  87,
					  3,
					  true,
					  false,
					  false
					],
					[
					  87,
					  9,
					  1,
					  true,
					  true,
					  false
					],
					[
					  88,
					  52,
					  3,
					  true,
					  false,
					  false
					],
					[
					  89,
					  10,
					  3,
					  true,
					  true,
					  false
					],
					[
					  90,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  96,
					  56,
					  1,
					  true,
					  true,
					  false
					],
					[
					  98,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  100,
					  55,
					  1,
					  true,
					  true,
					  false
					],
					[
					  102,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  104,
					  101,
					  1,
					  true,
					  true,
					  false
					],
					[
					  106,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  108,
					  54,
					  1,
					  true,
					  true,
					  false
					],
					[
					  111,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  117,
					  60,
					  1,
					  true,
					  true,
					  false
					],
					[
					  120,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  122,
					  59,
					  1,
					  true,
					  true,
					  false
					],
					[
					  124,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  130,
					  104,
					  2,
					  true,
					  true,
					  false
					],
					[
					  135,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  137,
					  83,
					  1,
					  true,
					  true,
					  false
					],
					[
					  141,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  147,
					  7,
					  1,
					  true,
					  true,
					  false
					],
					[
					  155,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  157,
					  74,
					  1,
					  true,
					  true,
					  false
					],
					[
					  163,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  165,
					  26,
					  4,
					  true,
					  true,
					  false
					],
					[
					  168,
					  38,
					  0,
					  true,
					  true,
					  false
					],
					[
					  170,
					  10,
					  4,
					  true,
					  true,
					  false
					],
					[
					  170,
					  16,
					  4,
					  true,
					  true,
					  false
					],
					[
					  172,
					  10,
					  4,
					  true,
					  true,
					  false
					],
					[
					  174,
					  50,
					  4,
					  true,
					  true,
					  false
					],
					[
					  176,
					  10,
					  4,
					  true,
					  false,
					  false
					],
					[
					  177,
					  6,
					  0,
					  false,
					  false,
					  false
					]
		]
		}
		"""

		let segments = try decode(json: json)

		let testCases = [
			24: 15,
			25: 15,
			26: 15,
			27: 15,
			28: 15,
			34: 2,
			35: 2,
			36: 2,
			37: 2,
			38: 2,
			39: 1,
			40: 2,
			41: 1,
			42: 2,
			43: 2,
			53: 1,
			54: 1,
			55: 1,
			57: 1,
			58: 1,
			59: 1,
			61: 1,
			62: 1,
			63: 1,
			64: 1,
			70: 1,
			71: 1,
			72: 1,
			78: 3,
			79: 3,
			80: 3,
			81: 1,
			82: 1,
			83: 3,
			84: 3,
			85: 1,
			86: 3,
			87: 3,
			88: 1,
			89: 3,
			90: 3,
			96: 1,
			97: 1,
			98: 1,
			100: 1,
			101: 1,
			102: 1,
			104: 1,
			105: 1,
			106: 1,
			108: 1,
			109: 1,
			110: 1,
			111: 1,
			117: 1,
			118: 1,
			119: 1,
			120: 1,
			122: 1,
			123: 1,
			124: 1,
			130: 2,
			131: 2,
			132: 2,
			133: 2,
			134: 2,
			135: 2,
			137: 1,
			138: 1,
			139: 1,
			140: 1,
			141: 1,
			147: 1,
			148: 1,
			149: 1,
			150: 1,
			151: 1,
			152: 1,
			153: 1,
			154: 1,
			155: 1,
			157: 1,
			158: 1,
			159: 1,
			160: 1,
			161: 1,
			162: 1,
			163: 1,
			165: 4,
			166: 4,
			167: 4,
			168: 4,
			169: 0,
			170: 4,
			171: 4,
			172: 4,
			173: 4,
			174: 4,
			175: 4,
			176: 4,
			177: 4,
		]

		for (lineNumber, expectedHits) in testCases {
			// when
			let hits = segmentsAnalyzer.lineHits(lineNumber: lineNumber, segments: segments)
			// then
			XCTAssertEqual(
				hits,
				expectedHits,
				"Hits for line \(lineNumber) should be \(expectedHits), got \(String(describing: hits))"
			)
		}
	}

	func testGetLineHitsVarSeventeen() throws {
		// given
		let json = """
		{ "segments": [
								[
									18,
									92,
									0,
									true,
									true,
									false
								],
								[
									19,
									15,
									0,
									true,
									true,
									false
								],
								[
									20,
									16,
									0,
									true,
									true,
									false
								],
								[
									20,
									33,
									0,
									true,
									false,
									false
								],
								[
									20,
									34,
									0,
									true,
									true,
									false
								],
								[
									22,
									14,
									0,
									true,
									true,
									false
								],
								[
									22,
									20,
									0,
									true,
									true,
									false
								],
								[
									22,
									23,
									0,
									true,
									true,
									false
								],
								[
									22,
									48,
									0,
									true,
									false,
									false
								],
								[
									22,
									49,
									0,
									true,
									true,
									false
								],
								[
									24,
									14,
									0,
									true,
									true,
									false
								],
								[
									24,
									20,
									0,
									true,
									true,
									false
								],
								[
									26,
									14,
									0,
									false,
									true,
									false
								],
								[
									26,
									14,
									0,
									true,
									false,
									false
								],
								[
									28,
									6,
									0,
									false,
									false,
									false
								]
		]
		}
		"""

		let segments = try decode(json: json)

		let testCases: [Int: Int?] = [
			18: 0,
			19: 0,
			20: 0,
			21: 0,
			22: 0,
			23: 0,
			24: 0,
			25: 0,
			26: nil,
			27: 0,
			28: 0,
		]

		for (lineNumber, expectedHits) in testCases {
			// when
			let hits = segmentsAnalyzer.lineHits(lineNumber: lineNumber, segments: segments)
			// then
			XCTAssertEqual(
				hits,
				expectedHits,
				"Hits for line \(lineNumber) should be \(String(describing: expectedHits)), got \(String(describing: hits))"
			)
		}
	}

	// MARK: - isClosing

	func testGetSegmentIsNotClosing() throws {
		// given
		let json = """
		{ "segments": [
					[
					  70,
					  76,
					  5,
					  true,
					  true,
					  false
					],
		]
		}
		"""
		let segment = try decode(json: json).first!

		// when
		let isClosing = segmentsAnalyzer.isClosing(segment)

		// then
		let expected = false
		XCTAssertEqual(isClosing, expected)
	}

	func testGetSegmentIsClosing() throws {
		// given
		let json = """
		{ "segments": [
					[
					  68,
					  6,
					  0,
					  false,
					  false,
					  false
					],
		]
		}
		"""
		let segment = try decode(json: json).first!

		// when
		let isClosing = segmentsAnalyzer.isClosing(segment)

		// then
		let expected = true
		XCTAssertEqual(isClosing, expected)
	}

	// MARK: - nextClosingSegment

	func testGetNextClosingSegmentVarOne() throws {
		// given
		let json = """
		{ "segments": [
					[
					  9,
					  65,
					  2,
					  true,
					  true,
					  false
					],
					[
					  11,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  13,
					  44,
					  0,
					  true,
					  true,
					  false
					],
		]
		}
		"""
		let segments = try decode(json: json)

		// when
		let nextClosingSegment = segmentsAnalyzer.nextClosingSegment(startIdx: 0, segments: segments)

		// then
		let expectedSegment = Segment(
			line: 11,
			column: 6,
			hits: 0,
			hasCount: false,
			isRegionEntry: false,
			isGapRegion: false
		)
		let expected = NextSegment(idx: 1, segment: expectedSegment)

		XCTAssertEqual(nextClosingSegment, expected)
	}

	func testGetNextClosingSegmentVarTwo() throws {
		// given
		let json = """
		{ "segments": [
					[
					  9,
					  65,
					  2,
					  true,
					  true,
					  false
					],
					[
					  11,
					  6,
					  0,
					  false,
					  false,
					  false
					],
					[
					  13,
					  44,
					  0,
					  true,
					  true,
					  false
					],
					[
					  17,
					  50,
					  0,
					  true,
					  true,
					  false
					],
					[
					  17,
					  75,
					  0,
					  true,
					  false,
					  false
					],
					[
					  18,
					  6,
					  0,
					  false,
					  false,
					  false
					],
		]
		}
		"""
		let segments = try decode(json: json)

		// when
		let nextClosingSegment = segmentsAnalyzer.nextClosingSegment(startIdx: 2, segments: segments)

		// then
		let expectedSegment = Segment(
			line: 18,
			column: 6,
			hits: 0,
			hasCount: false,
			isRegionEntry: false,
			isGapRegion: false
		)
		let expected = NextSegment(idx: 5, segment: expectedSegment)

		XCTAssertEqual(nextClosingSegment, expected)
	}

	func testGetNextClosingSegmentVarThree() throws {
		// given
		let json = """
		{ "segments": [
				   [
					  11,
					  41,
					  2,
					  true,
					  true,
					  false
					],
					[
					  12,
					  29,
					  8,
					  true,
					  true,
					  false
					],
					[
					  12,
					  44,
					  2,
					  true,
					  false,
					  false
					],
					[
					  13,
					  6,
					  0,
					  false,
					  false,
					  false
					]

		]
		}
		"""
		let segments = try decode(json: json)

		// when
		let nextClosingSegment = segmentsAnalyzer.nextClosingSegment(startIdx: 0, segments: segments)

		// then
		let expectedSegment = Segment(
			line: 13,
			column: 6,
			hits: 0,
			hasCount: false,
			isRegionEntry: false,
			isGapRegion: false
		)
		let expected = NextSegment(idx: 3, segment: expectedSegment)

		XCTAssertEqual(nextClosingSegment, expected)
	}

	func testGetNextClosingSegmentVarFour() throws {
		// given
		let json = """
		{ "segments": [
				   [
					  3,
					  63,
					  0,
					  true,
					  true,
					  false
					],
					[
					  3,
					  65,
					  0,
					  false,
					  false,
					  false
					],
					[
					  3,
					  124,
					  5,
					  true,
					  true,
					  false
					],
					[
					  5,
					  2,
					  0,
					  false,
					  false,
					  false
					],
					[
					  9,
					  44,
					  0,
					  true,
					  true,
					  false
					],
		]
		}
		"""
		let segments = try decode(json: json)

		// when
		let nextClosingSegment = segmentsAnalyzer.nextClosingSegment(startIdx: 0, segments: segments)

		// then
		let expectedSegment = Segment(
			line: 5,
			column: 2,
			hits: 0,
			hasCount: false,
			isRegionEntry: false,
			isGapRegion: false
		)
		let expected = NextSegment(idx: 3, segment: expectedSegment)

		XCTAssertEqual(nextClosingSegment, expected)
	}
}

extension SegmentsAnalyzerTests {
	func decode(json: String) throws -> [Segment] {
		let jsonData = json.data(using: .utf8)!
		let info = try JSONDecoder().decode(TestSegmentsModel.self, from: jsonData)

		return info.segments
	}
}
