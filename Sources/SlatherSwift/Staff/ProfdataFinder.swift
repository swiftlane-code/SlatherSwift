//

import SwiftlaneCore

extension ProfdataFinder {
	enum Errors: Error {
		case noOneIn(AbsolutePath)
		case severalIn(AbsolutePath, [AbsolutePath])
	}
}

struct ProfdataFinder {
	private let fileManager: FSManaging
	private let requiredFileSuffix: String

	init(
		fileManager: FSManaging,
		requiredFileSuffix: String = "profdata"
	) {
		self.fileManager = fileManager
		self.requiredFileSuffix = requiredFileSuffix
	}

	func find(absDerivedDataDir: AbsolutePath) throws -> AbsolutePath {
		let files = try fileManager.find(absDerivedDataDir).filter { $0.hasSuffix(requiredFileSuffix) }

		guard !(files.count > 1) else {
			throw Errors.severalIn(absDerivedDataDir, files)
		}

		guard let file = files.first else {
			throw Errors.noOneIn(absDerivedDataDir)
		}

		return file
	}
}
