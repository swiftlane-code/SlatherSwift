//

import Foundation
import SwiftlaneCore

struct LcovCovParser {
	private let fileManager: FSManaging

	private let filePathPrefix: String = "SF:"
	private let lineHitsPrefix: String = "DA:"
	private let lineHitsSeparator: String = ","

	init(fileManager: FSManaging) {
		self.fileManager = fileManager
	}

	func parse(filePath: AbsolutePath) throws -> [LimitedLcovCov] {
		let text = try fileManager.readText(filePath, log: false)
		let lines = text.components(separatedBy: .newlines)

		var filesLcovs: [LimitedLcovCov] = []
		var lastFilePath: AbsolutePath?
		var lineHits: [UInt: UInt] = [:]

		try lines.forEach {
			guard !$0.hasPrefix(filePathPrefix) else {
				if let safeLastFilePath = lastFilePath {
					filesLcovs.append(
						LimitedLcovCov(
							filePath: safeLastFilePath,
							lineHits: lineHits
						)
					)

					lineHits = [:]
				}

				lastFilePath = try AbsolutePath($0.deletingPrefix(filePathPrefix))

				return
			}

			guard !$0.hasPrefix(lineHitsPrefix) else {
				let lineWithoutPrefix = $0.deletingPrefix(lineHitsPrefix)
				let lineComponents = lineWithoutPrefix.components(separatedBy: lineHitsSeparator)

				let wrongLineFormatMsg = "Line with hits \"\($0)\" has unexpected format"

				let curLineNumber = try UInt(
					lineComponents.first.unwrap(errorDescription: wrongLineFormatMsg)
				).unwrap(errorDescription: wrongLineFormatMsg)

				let curLineHits = try UInt(
					lineComponents.last.unwrap(errorDescription: wrongLineFormatMsg)
				).unwrap(errorDescription: wrongLineFormatMsg)

				lineHits[curLineNumber] = curLineHits
				return
			}
		}

		if let safeLastFilePath = lastFilePath {
			filesLcovs.append(
				LimitedLcovCov(
					filePath: safeLastFilePath,
					lineHits: lineHits
				)
			)
		}

		return filesLcovs
	}
}
