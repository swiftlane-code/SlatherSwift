//

import ArgumentParser
import Foundation
import SwiftlaneCore

struct CollectDebugInfoCommand: ParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "collect-debug-info",
		abstract: "Collects debug information for coverage command."
	)

	@Option(help: "Path to Derived Data.")
	var derivedDataDir: Path

	@Option(help: "Path to directory where your Cobertura XML report will be written to.")
	var outputDirectory: Path

	@Option(help: "iOS Project root directory.")
	var projectRootDirectory: Path?

	@Option(
		help: "Comma separated list of executables names from Info tab of build scheme (with or without '.app', '.framework' extensions)."
	)
	var executablesNames: String

	@Option(help: "Timeout for generating Ruby version cobertura.xml.")
	var rubySlatherTimeout: TimeInterval = 99

	@Option(help: "Timestamp that should set in cobertura.xml. Usefull for future use in unit tests.")
	var coberturaXMLTimestamp: TimeInterval = Date().timeIntervalSince1970

	mutating func run() throws {
		let logger = DetailedLogger(logLevel: .verbose)

		let fileManager = FSManager(
			logger: logger,
			fileManager: FileManager.default
		)

		let curWorkDir = try fileManager.pwd()
		let curWorkDirAsPath = try Path(curWorkDir.string)

		let absDerivedDataDir = derivedDataDir.makeAbsoluteIfIsnt(relativeTo: curWorkDir)
		let absOutDir = outputDirectory.makeAbsoluteIfIsnt(relativeTo: curWorkDir)

		let absProjectRootDir = (projectRootDirectory ?? curWorkDirAsPath).makeAbsoluteIfIsnt(relativeTo: curWorkDir)

		let sigIntHandler = SigIntHandler(logger: logger)
		let xcodeChecker = XcodeChecker()
		let shell = ShellExecutor(
			sigIntHandler: sigIntHandler,
			logger: logger,
			xcodeChecker: xcodeChecker,
			filesManager: fileManager
		)

		let profdataFinder = ProfdataFinder(fileManager: fileManager)
		let executableFinder = ExecutableFinder(fileManager: fileManager, filesSorter: nil)
		let covMiner = LLVMCovMiner(shell: shell)

		let rubyCoberturaMiner = RubyCoberturaMiner(shell: shell, fileManager: fileManager)
		let rawCovDataWriter = RawLLVMCovDebugDataWriter(fileManager: fileManager)

		let coberturaPatcher = CoberturaPatcher(shell: shell, fileManager: fileManager)

		let profdataFile = try profdataFinder.find(absDerivedDataDir: absDerivedDataDir)

		let executableFiles = try executableFinder.find(
			absDerivedDataDir: absDerivedDataDir,
			executablesNamesList: executablesNames
		)

		let allTargetsDir = absOutDir.appending(suffix: "/\(StubSubpath.all)/")
		let indiTargetsDir = absOutDir.appending(suffix: "/\(StubSubpath.individually)/")

		try [allTargetsDir, indiTargetsDir].forEach {
			try fileManager.delete($0)
		}

		var coberturaFilesPaths: [AbsolutePath] = []

		try executableFiles.forEach { executableFile in
			let targetName = executableFile.lastComponent.string

			let covJson = try covMiner.produce(profdataFile: profdataFile, executableFile: executableFile, format: .json)
			let covLcov = try covMiner.produce(profdataFile: profdataFile, executableFile: executableFile, format: .lcov)

			let indiTargetDirPath = indiTargetsDir.appending(suffix: "/\(targetName)/")

			try rawCovDataWriter.write(
				covJson: covJson, covLcov: covLcov, targetName: targetName, allTargetsDir: allTargetsDir,
				indiTargetsDir: indiTargetsDir,
				indiTargetDirPath: indiTargetDirPath
			)

			let coberturaXMLFilePath = try rubyCoberturaMiner.produceXML(
				projectDir: absProjectRootDir,
				outDir: indiTargetDirPath,
				rubySlatherTimeout: rubySlatherTimeout,
				targetName: targetName
			)

			coberturaFilesPaths.append(coberturaXMLFilePath)

			try rubyCoberturaMiner.produceJSON(
				projectDir: absProjectRootDir,
				outDir: indiTargetDirPath,
				rubySlatherTimeout: rubySlatherTimeout,
				targetName: targetName
			)
		}

		let coberturaXMLFilePath = try rubyCoberturaMiner.produceXML(
			projectDir: absProjectRootDir,
			outDir: allTargetsDir,
			rubySlatherTimeout: rubySlatherTimeout
		)

		try rubyCoberturaMiner.produceJSON(
			projectDir: absProjectRootDir,
			outDir: allTargetsDir,
			rubySlatherTimeout: rubySlatherTimeout
		)

		coberturaFilesPaths.append(coberturaXMLFilePath)

		let timestampString = String(Int(coberturaXMLTimestamp))

		try coberturaFilesPaths.forEach {
			try coberturaPatcher.patch(
				filePath: $0,
				commands: [.timestamp(timestampString)],
				dropOriginalsBackups: true
			)
		}
	}
}
