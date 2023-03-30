//

import Foundation
import SwiftlaneCore

protocol CoberturesComparing {
	func isEqual(
		gottenPath: AbsolutePath,
		expectedPath: AbsolutePath,
		branchRateAccuracy: BranchRateAccuracyReduce,
		ignoreTimestamp: Bool,
		ignoreUtilityVersion: Bool,
		isOpenDiffOnFailure: Bool,
		diffOpenTimeout: TimeInterval
	) throws -> Bool

	func isEqual(
		gotten: String,
		expected: String,
		branchRateAccuracy: BranchRateAccuracyReduce,
		ignoreTimestamp: Bool,
		ignoreUtilityVersion: Bool,
		isOpenDiffOnFailure: Bool,
		diffOpenTimeout: TimeInterval
	) throws -> Bool
}

extension CoberturesComparing {
	func isEqual(
		gottenPath: AbsolutePath,
		expectedPath: AbsolutePath,
		branchRateAccuracy: BranchRateAccuracyReduce,
		ignoreTimestamp: Bool,
		ignoreUtilityVersion: Bool,
		isOpenDiffOnFailure: Bool,
		diffOpenTimeout: TimeInterval
	) throws -> Bool {
		return try isEqual(
			gottenPath: gottenPath,
			expectedPath: expectedPath,
			branchRateAccuracy: branchRateAccuracy,
			ignoreTimestamp: ignoreTimestamp,
			ignoreUtilityVersion: ignoreUtilityVersion,
			isOpenDiffOnFailure: isOpenDiffOnFailure,
			diffOpenTimeout: diffOpenTimeout
		)
	}

	func isEqual(
		gotten: String,
		expected: String,
		branchRateAccuracy: BranchRateAccuracyReduce,
		ignoreTimestamp: Bool,
		ignoreUtilityVersion: Bool,
		isOpenDiffOnFailure: Bool,
		diffOpenTimeout: TimeInterval
	) throws -> Bool {
		return try isEqual(
			gotten: gotten,
			expected: expected,
			branchRateAccuracy: branchRateAccuracy,
			ignoreTimestamp: ignoreTimestamp,
			ignoreUtilityVersion: ignoreUtilityVersion,
			isOpenDiffOnFailure: isOpenDiffOnFailure,
			diffOpenTimeout: diffOpenTimeout
		)
	}
}

// MARK: - CoberturesComparator

final class CoberturesComparator {
	private enum Constants {
		static let ignoredStub = "IGNORED"
	}
	
	private let filesManager: FSManaging
	private let shell: ShellExecuting
	private let coberturaPatcher: CoberturaPatcher
	private let instanceTmpDir: AbsolutePath

	init(
		filesManager: FSManaging,
		shell: ShellExecuting,
		coberturaPatcher: CoberturaPatcher,
		bundle: Bundle,
		tmpDir: AbsolutePath?
	) throws {
		self.filesManager = filesManager
		self.shell = shell
		self.coberturaPatcher = coberturaPatcher

		let objectName = String(describing: Self.self)
		let bundlePath = bundle.bundlePath

		let utilName = try AbsolutePath(bundlePath).lastComponent.string
			.split(separator: ".")
			.first.unwrap()
			.split(separator: "_")
			.last.unwrap()

		let instanceIdentifier = UUID().uuidString

		let rootTmpDir = try tmpDir ?? AbsolutePath("/tmp/")
		instanceTmpDir = rootTmpDir.appending(suffix: "\(utilName)/\(objectName)/\(instanceIdentifier)/")
	}

	func buildTmpXMLFilePath(
		for fileName: TmpTestFileName,
		additionalSubFolders: [String]? = nil
	) throws -> AbsolutePath {
		let additionalSubFoldersSubPath = additionalSubFolders?.joined(separator: "/") ?? ""

		return instanceTmpDir.appending(suffix: "/\(additionalSubFoldersSubPath)/\(fileName).xml")
	}
}

// MARK: - CoberturesComparing

extension CoberturesComparator: CoberturesComparing {
	func isEqual(
		gottenPath: AbsolutePath,
		expectedPath: AbsolutePath,
		branchRateAccuracy: BranchRateAccuracyReduce,
		ignoreTimestamp: Bool,
		ignoreUtilityVersion: Bool,
		isOpenDiffOnFailure: Bool,
		diffOpenTimeout: TimeInterval
	) throws -> Bool {
		let gottenXML = try filesManager.readText(gottenPath, log: false)
		let expectedXML = try filesManager.readText(expectedPath, log: false)

		return try isEqual(
			gotten: gottenXML,
			expected: expectedXML,
			branchRateAccuracy: branchRateAccuracy,
			ignoreTimestamp: ignoreTimestamp,
			ignoreUtilityVersion: ignoreUtilityVersion,
			isOpenDiffOnFailure: isOpenDiffOnFailure,
			diffOpenTimeout: diffOpenTimeout
		)
	}

	func isEqual(
		gotten: String,
		expected: String,
		branchRateAccuracy: BranchRateAccuracyReduce,
		ignoreTimestamp: Bool,
		ignoreUtilityVersion: Bool,
		isOpenDiffOnFailure: Bool,
		diffOpenTimeout: TimeInterval
	) throws -> Bool {
		var gotten = gotten
		var expected = expected

		var processingCommands: [CoberturaPatchCommand] = []

		switch branchRateAccuracy {
		case let .enabled(accuracySize):
			processingCommands.append(.branchRate(accuracySize))
		case .disabled:
			break
		}

		if ignoreTimestamp {
			processingCommands.append(.timestamp(Constants.ignoredStub))
		}

		if ignoreUtilityVersion {
			processingCommands.append(.utilityVersion(Constants.ignoredStub))
		}

		if !processingCommands.isEmpty {
			let accuracySubFolderName = "ReduceAccuracyProcessing"

			let gottenPath = try buildTmpXMLFilePath(for: .gotten, additionalSubFolders: [accuracySubFolderName])
			let expectedPath = try buildTmpXMLFilePath(for: .expected, additionalSubFolders: [accuracySubFolderName])

			try filesManager.write(gottenPath, text: gotten)
			try filesManager.write(expectedPath, text: expected)

			try [gottenPath, expectedPath].forEach {
				try coberturaPatcher.patch(filePath: $0, commands: processingCommands, dropOriginalsBackups: true)
			}

			gotten = try filesManager.readText(gottenPath, log: false)
			expected = try filesManager.readText(expectedPath, log: false)

			try filesManager.delete(gottenPath)
			try filesManager.delete(expectedPath)
		}

		guard gotten != expected else {
			return true
		}

		let gottenPath = try buildTmpXMLFilePath(for: .gotten)
		try filesManager.write(gottenPath, text: gotten)

		let expectedPath = try buildTmpXMLFilePath(for: .expected)
		try filesManager.write(expectedPath, text: expected)

		guard isOpenDiffOnFailure else {
			// Deletting resulting files only in diff oppening does not needed.
			try filesManager.delete(gottenPath)
			try filesManager.delete(expectedPath)

			return false
		}
		let opendiffCommand = "opendiff \"\(expectedPath)\" \"\(gottenPath)\""

		do {
			// Launching FileMerge with 1 sec timeout because its enough for it.
			try shell.run(opendiffCommand, log: .silent, executionTimeout: diffOpenTimeout)
		} catch {
			guard case ShError.executionTimedOut = error else {
				throw error
			}
		}

		try filesManager.delete(instanceTmpDir)

		return false
	}
}
