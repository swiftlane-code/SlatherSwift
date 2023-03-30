//

import Foundation
import SwiftlaneCore

protocol CoberturaWriting {
	func write(coberturaXML: String, outDir: AbsolutePath, fileName: String, isFormatXML: Bool) throws
}

struct CoberturaWriter {
	private let fileManager: FSManaging
	private let shell: ShellExecuting

	init(
		fileManager: FSManaging,
		shell: ShellExecuting
	) {
		self.fileManager = fileManager
		self.shell = shell
	}
}

// MARK: - CoberturaWriting

extension CoberturaWriter: CoberturaWriting {
	func write(coberturaXML: String, outDir: AbsolutePath, fileName: String, isFormatXML: Bool) throws {
		let outFilePath = outDir.appending(suffix: "/").appending(suffix: fileName)

		guard isFormatXML else {
			try fileManager.write(outFilePath, text: coberturaXML)
			return
		}

		let unformatedFileName = "unformated.\(fileName)"
		let unformatedFilePath = outDir.appending(suffix: "/").appending(suffix: unformatedFileName)

		defer {
			try! fileManager.delete(unformatedFilePath)
		}

		try fileManager.write(unformatedFilePath, text: coberturaXML)
		try shell.run("xmllint --format -o \(outFilePath) \(unformatedFilePath)", log: .silent)
	}
}
