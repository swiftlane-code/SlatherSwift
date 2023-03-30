//

import Foundation
import SwiftlaneCore

struct PackageNameCalculator {
	enum Errors: Error {
		case unpackagedFileName(String)
	}

	func calculate(_ filePath: AbsolutePath, projectRootDir: AbsolutePath) throws -> String {
		let relativePath = try filePath
			.deletingExtension
			.relative(to: projectRootDir)
			.string

		return relativePath
			.deletingLastPathComponent
			.replacingOccurrences(of: "/", with: ".")
	}
}
