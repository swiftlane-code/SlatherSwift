//

import Foundation
import SwiftlaneCore

struct LLVMCovMiner {
	enum CovFormat {
		case json
		case lcov
	}

	private let shell: ShellExecuting

	init(shell: ShellExecuting) {
		self.shell = shell
	}

	// MARK: Public
	
	func produce(
		profdataFile: AbsolutePath,
		executableFile: AbsolutePath,
		format: CovFormat
	) throws -> String {
		var command = "xcrun llvm-cov export -instr-profile "
		command += " \"\(profdataFile)\" \"\(executableFile)\" "
		command += (format == .lcov) ? " -format lcov " : ""

		let res = try shell.run(command, log: .commandOnly)

		let covStdoutText = try res.stdoutText.unwrap(
			errorDescription: "Coverage stdout text of command \"\(command)\" is empty"
		)

		return covStdoutText
	}
}
