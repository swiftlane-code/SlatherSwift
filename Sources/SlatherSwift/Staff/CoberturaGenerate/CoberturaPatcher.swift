//

import Foundation
import SwiftlaneCore

struct CoberturaPatcher {
	private let shell: ShellExecuting
	private let fileManager: FSManaging

	private let originalBackupSuffix: String = "-E"

	init(
		shell: ShellExecuting,
		fileManager: FSManaging
	) {
		self.shell = shell
		self.fileManager = fileManager
	}

	func patch(filePath: AbsolutePath, commands: [CoberturaPatchCommand], dropOriginalsBackups: Bool) throws {
		try commands.forEach { command in
			try shell.run("\(command) \(filePath)", log: .commandOnly)

			guard !dropOriginalsBackups else {
				let originalBackupFilePath = filePath.appending(suffix: originalBackupSuffix)
				try fileManager.delete(originalBackupFilePath)
				return
			}
		}
	}
}
