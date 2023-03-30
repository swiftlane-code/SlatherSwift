//

import ArgumentParser
import Foundation
import SwiftlaneCore

struct CoverageCommand: ParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "coverage",
		abstract: "Computes coverage for the supplied project."
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

	@Flag(help: "Enables compatibility with Ruby version mode.")
	var rubyVersionCompatiabilityMode = false

	@Option(help: "Timeout for parsing raw code coverage data.")
	var coverageParsingTimeout: TimeInterval = 99

//	@Option(help: "Max size of packages that will be processed cuncurently.")
//	var maxPackagesProcessingChunkSize: Int = 50

	@Option(help: "Cobertura xml file name.")
	var coberturaXMLFileName: String = "cobertura.xml"

	@Flag(help: "Enables resulting cobertura XML formatting in to human readable format.")
	var formatCoberturaXML: Bool = false

	@Option(
		help: """
		JSON report file name. Output coverage results as simple JSON. Will not be generated if file name not defined.
		!!! IT's not equal with Ruby Slather report.json, but similar.
		"""
	)
	var jsonReportFileName: String?

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

		let filesSorter = rubyVersionCompatiabilityMode ? RubyObjectsSorter() : nil

		let executableFinder = ExecutableFinder(fileManager: fileManager, filesSorter: filesSorter)
		let covMiner = LLVMCovMiner(shell: shell)
		let covResponsesParser = LLVMCovParser()
		let coberturaWriter = CoberturaWriter(fileManager: fileManager, shell: shell)

		let jsonReportWriter = JSONReportWriter(fileManager: fileManager)

		let runner = CoverageCommandRunner(
			profdataFinder: profdataFinder,
			executableFinder: executableFinder,
			covMiner: covMiner,
			covResponsesParser: covResponsesParser,
			coberturaEncoder: CoberturaEncoder(),
			coberturaWriter: coberturaWriter,
			jsonReportWriter: jsonReportWriter,
			jsonReportBuilder: JSONReportBuilder()
		)

		try runner.run(
			absDerivedDataDir: absDerivedDataDir,
			outDir: absOutDir,
			executablesNames: executablesNames,
			projectRootDir: absProjectRootDir,
			rubyVersionCompatiabilityMode: rubyVersionCompatiabilityMode,
			coverageParsingTimeout: coverageParsingTimeout,
//			maxPackagesProcessingChunkSize: maxPackagesProcessingChunkSize,
			coberturaXMLFileName: coberturaXMLFileName,
			isFormatCoberturaXML: formatCoberturaXML,
			jsonReportFileName: jsonReportFileName
		)
	}
}
