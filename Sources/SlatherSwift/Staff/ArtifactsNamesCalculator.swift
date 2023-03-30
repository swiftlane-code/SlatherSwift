//

import Foundation
import SwiftlaneCore

struct ArtifactsNamesCalculator {
	enum Errors: Error {
		case unpackagedFileName(String)
	}

	// MARK: Public
	
	func calculateClassName(path: String) throws -> String {
		return try AbsolutePath(path).lastComponent.deletingExtension.string
	}

	func calculatePkgClassFilename(path: String, projectRootDir: AbsolutePath) -> String {
		return path.deletingPrefix(projectRootDir.string).deletingPrefix("/")
	}

	func calculatePackageName(_ fileName: String, projectRootDir: AbsolutePath) throws -> String {
		guard
			let escapedFileName = fileName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
			let url = URL(string: escapedFileName)
		else {
			throw Errors.unpackagedFileName(fileName)
		}

		let standardizedRootDirPath = projectRootDir.string.deletingSuffix("/")

		return url.pathComponents
			.dropLast().joined(separator: "/")
			.deletingPrefix("/\(standardizedRootDirPath)/")
			.replacingOccurrences(of: "/", with: ".")
	}
}
