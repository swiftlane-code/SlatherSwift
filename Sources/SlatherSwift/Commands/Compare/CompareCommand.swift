//

import ArgumentParser
import Foundation
import SwiftlaneCore

struct CompareCommand: ParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "compare",
		abstract: "Compares two cobertura xmls."
	)

	enum CommandExitCode: Int32 {
		case coberturesNotEqual = 1
	}

	@Option(help: "The path of reference cobertura xml.")
	var expected: Path

	@Option(help: "The path of verifiable cobertura xml.")
	var gotten: Path

	@Option(
		help: "Trancates given number of digest at right side. Usefull for comparing with cobertura xml produced by Ruby version of Slather."
	)
	var branchRateAccuracyTrancationSize: UInt?

	@Flag(help: "Disables timestamp validation.")
	var ignoreTimestampValidation: Bool = false

	@Flag(help: "Disables version validation.")
	var ignoreVersionValidation: Bool = false

	@Flag(help: "Opens diff in FileMerge in case when files not equal.")
	var isOpenDiffOnFailure: Bool = false

	@Option(
		help: "Timeout for openning FileMerge. Some times in case of large diffs is is usefull to increase timeout for let FileMerge to process files."
	)
	var diffOpeningTimeout: TimeInterval = 1

	mutating func run() throws {
		let logger = DetailedLogger(logLevel: .verbose)

		let fileManager = FSManager(
			logger: logger,
			fileManager: FileManager.default
		)

		let sigIntHandler = SigIntHandler(logger: logger)
		let xcodeChecker = XcodeChecker()
		let shell = ShellExecutor(
			sigIntHandler: sigIntHandler,
			logger: logger,
			xcodeChecker: xcodeChecker,
			filesManager: fileManager
		)

		let currentWorkDir = try fileManager.pwd()
		let absExpectedPath = expected.makeAbsoluteIfIsnt(relativeTo: currentWorkDir)
		let absGottenPath = gotten.makeAbsoluteIfIsnt(relativeTo: currentWorkDir)

		let coberturaPatcher = CoberturaPatcher(shell: shell, fileManager: fileManager)
		let comparator = try CoberturesComparator(
			filesManager: fileManager,
			shell: shell,
			coberturaPatcher: coberturaPatcher,
			bundle: Bundle.module,
			tmpDir: nil
		)

		var branchRateAccuracy = BranchRateAccuracyReduce.disabled
		if let accuracySize = branchRateAccuracyTrancationSize {
			branchRateAccuracy = .enabled(accuracySize)
		}

		let isEqual = try comparator.isEqual(
			gottenPath: absGottenPath,
			expectedPath: absExpectedPath,
			branchRateAccuracy: branchRateAccuracy,
			ignoreTimestamp: ignoreTimestampValidation,
			ignoreUtilityVersion: ignoreVersionValidation,
			isOpenDiffOnFailure: isOpenDiffOnFailure,
			diffOpenTimeout: diffOpeningTimeout
		)

		guard !isEqual else {
			logger.success("Congrats - cobertures in files is equal!")
			return
		}

		logger.warn("Ups - cobertures in files is NOT equal!")
		type(of: self).exit(withError: ExitCode(.coberturesNotEqual))
	}
}

// Hack, because ParsableCommand have init
extension ExitCode {
	init(_ commandExitCode: CompareCommand.CommandExitCode) {
		self.init(commandExitCode.rawValue)
	}
}
