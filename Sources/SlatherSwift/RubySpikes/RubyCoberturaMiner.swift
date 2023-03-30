//

import Foundation
import SwiftlaneCore

struct RubyCoberturaMiner {
	private let shell: ShellExecuting
	private let fileManager: FSManaging

	init(
		shell: ShellExecuting,
		fileManager: FSManaging
	) {
		self.shell = shell
		self.fileManager = fileManager
	}
	
	// MARK: Private

	private func buildCommand(
		projectDir: AbsolutePath,
		targetName: String?,
		outDir: AbsolutePath,
		isInJSONFormat: Bool
	) -> String {
		var command = "cd \"\(projectDir)\" && slather coverage --output-directory \"\(outDir)\""
		if let targetName = targetName {
			command += " --binary-basename \"\(targetName)\""
		}

		if isInJSONFormat {
			command += " --json"
		}

		return command
	}

	private func persistOutFile(
		outDir: AbsolutePath,
		originalFileName: String,
		outFileName: String
	) throws -> AbsolutePath {
		let originalFilePath = outDir.appending(suffix: "/\(originalFileName)")
		let expectedFilePath = outDir.appending(suffix: "/\(outFileName)")

		try fileManager.move(originalFilePath, newPath: expectedFilePath)

		return expectedFilePath
	}

	// MARK: Public

	@discardableResult
	func produceXML(
		projectDir: AbsolutePath,
		outDir: AbsolutePath,
		rubySlatherTimeout: TimeInterval,
		targetName: String? = nil,
		originalFileName: String = "cobertura.xml",
		outFileName: String = "expected.xml"
	) throws -> AbsolutePath {
		let command = buildCommand(
			projectDir: projectDir, targetName: targetName, outDir: outDir, isInJSONFormat: false
		)
		try shell.run(command, log: .commandOnly, executionTimeout: rubySlatherTimeout)

		return try persistOutFile(outDir: outDir, originalFileName: originalFileName, outFileName: outFileName)
	}

	@discardableResult
	func produceJSON(
		projectDir: AbsolutePath,
		outDir: AbsolutePath,
		rubySlatherTimeout: TimeInterval,
		targetName: String? = nil,
		/// report.json can't be changed because it's hardcoded inside Rubsy slather.
		originalFileName: String = "report.json",
		outFileName: String = "expected.json"
	) throws -> AbsolutePath {
		let command = buildCommand(
			projectDir: projectDir, targetName: targetName, outDir: outDir, isInJSONFormat: true
		)
		try shell.run(command, log: .commandOnly, executionTimeout: rubySlatherTimeout)

		return try persistOutFile(outDir: outDir, originalFileName: originalFileName, outFileName: outFileName)
	}
}
