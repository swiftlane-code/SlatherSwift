//

import Foundation
import SwiftlaneCore

struct RawLLVMCovDebugDataWriter {
	private let fileManager: FSManaging
	private let llvmCovPrefix: String
	private let lcovSuffix: String
	private let jsonExt: String
	private let lcovExt: String

	init(
		fileManager: FSManaging,
		llvmCovPrefix: String = "llvm-cov",
		lcovSuffix: String = "lcov",
		jsonExt: String = "json",
		lcovExt: String = "txt"
	) {
		self.fileManager = fileManager
		self.llvmCovPrefix = llvmCovPrefix
		self.lcovSuffix = lcovSuffix
		self.jsonExt = jsonExt
		self.lcovExt = lcovExt
	}

	// MARK: Public
	
	func write(
		covJson: String,
		covLcov: String,
		targetName: String,
		allTargetsDir: AbsolutePath,
		indiTargetsDir _: AbsolutePath,
		indiTargetDirPath: AbsolutePath
	) throws {
		let covFilePath = allTargetsDir.appending(suffix: "/\(llvmCovPrefix)-\(targetName).\(jsonExt)")
		try fileManager.write(covFilePath, text: covJson)

		let lcovFilePath = allTargetsDir.appending(suffix: "/\(llvmCovPrefix)-\(targetName)-\(lcovSuffix).\(lcovExt)")
		try fileManager.write(lcovFilePath, text: covLcov)

		let indiCovFilePath = indiTargetDirPath.appending(suffix: "/\(llvmCovPrefix).\(jsonExt)")
		try fileManager.write(indiCovFilePath, text: covJson)

		let indiLcovFilePath = indiTargetDirPath.appending(suffix: "/\(llvmCovPrefix)-\(lcovSuffix).\(lcovExt)")
		try fileManager.write(indiLcovFilePath, text: covLcov)
	}
}
