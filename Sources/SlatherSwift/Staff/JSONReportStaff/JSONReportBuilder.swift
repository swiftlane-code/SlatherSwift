//

import Foundation
import SwiftlaneCore

protocol JSONReportBuilding {
	func build(cobertura: CoberturaCoverage) throws -> [JSONReportFileCoverage]
}

struct JSONReportBuilder {}

// MARK: - JSONReportBuilding

extension JSONReportBuilder: JSONReportBuilding {
	func build(cobertura: CoberturaCoverage) throws -> [JSONReportFileCoverage] {
		let reportModel = try cobertura.packages.flatMap(\.classes).map { pkgClass -> JSONReportFileCoverage in
			let path = try RelativePath(pkgClass.filename)

			let lines = pkgClass.lines
			let lastCoverageLineIdx = try lines.last.unwrap().number

			// Index of a line = it's number - 1
			let linesCoverage: [Int?] = Array(1...lastCoverageLineIdx + 1).map { lineNumber in
				lines.lazy.first(where: { $0.number == lineNumber })?.hits
			}

			return JSONReportFileCoverage(file: path, coverage: linesCoverage)
		}
		return reportModel
	}
}
