//

import Foundation
import SwiftlaneCore

struct JSONReportWriter {
	private let fileManager: FSManaging

	init(fileManager: FSManaging) {
		self.fileManager = fileManager
	}

	func write(report: [JSONReportFileCoverage], into file: AbsolutePath) throws {
		let encoder = JSONEncoder()
		let jsonData = try encoder.encode(report)

		try fileManager.write(file, data: jsonData)
	}
}
