//

import Foundation
import SwiftlaneCore

extension Segment {
	enum Errors: Error {
		case incorrectValueType([AnyDecodableValue], Int)
	}
}

struct Segment {
	let line: Int
	let column: Int
	let hits: Int
	let hasCount: Bool
	let isRegionEntry: Bool
	let isGapRegion: Bool
}

extension Segment: Equatable {}

extension Segment: Decodable {
	init(from decoder: Decoder) throws {
		let atomicValues = try decoder
			.singleValueContainer()
			.decode([AnyDecodableValue].self)

		line = try atomicValues.int(at: 0)
		column = try atomicValues.int(at: 1)
		hits = try atomicValues.int(at: 2)
		hasCount = try atomicValues.bool(at: 3)
		isRegionEntry = try atomicValues.bool(at: 4)
		isGapRegion = try atomicValues.bool(at: 5)
	}
}

private extension Array where Element == AnyDecodableValue {
	func int(at idx: Int) throws -> Int {
		guard case let .int(value) = self[safe: idx] else {
			throw Segment.Errors.incorrectValueType(self, idx)
		}

		return value
	}

	func bool(at idx: Int) throws -> Bool {
		guard case let .bool(value) = self[safe: idx] else {
			throw Segment.Errors.incorrectValueType(self, idx)
		}

		return value
	}
}
