//

import Foundation
import SwiftlaneCore

struct FileBasedXMLFormatter {
	private let fileManager: FSManaging
	private let shell: ShellExecuting
	private let rootTmpDirPath: AbsolutePath
	private let instanceIdentifier: String

	init(
		fileManager: FSManaging,
		shell: ShellExecuting,
		rootTmpDirPath: AbsolutePath,
		instanceIdentifier: String = UUID().uuidString
	) {
		self.fileManager = fileManager
		self.shell = shell
		self.rootTmpDirPath = rootTmpDirPath

		self.instanceIdentifier = instanceIdentifier
	}

	// MARK: Public
	
	func format(_ xml: String) throws -> String {
		let subDirName = "\(type(of: self))".replacingOccurrences(of: ".", with: "/")
		let tmpDirPath = rootTmpDirPath.appending(suffix: "/\(subDirName)/\(instanceIdentifier)/")
		let initialFilePath = tmpDirPath.appending(suffix: "initial.xml")
		let formatedFilePath = tmpDirPath.appending(suffix: "formated.xml")

		try fileManager.mkdir(tmpDirPath)
		defer {
			do {
				try fileManager.delete(tmpDirPath)
			} catch {
				print("Deffer temporary directory \"\(tmpDirPath)\" failed with error: \(error.localizedDescription)")
			}
		}

		try fileManager.write(initialFilePath, text: xml)

		let formattingComand = "xmllint --format \"\(initialFilePath)\" > \"\(formatedFilePath)\""
		try shell.run(formattingComand, log: .commandOnly)

		let formatedXML = try fileManager.readText(formatedFilePath, log: false)
		return formatedXML
	}
}
