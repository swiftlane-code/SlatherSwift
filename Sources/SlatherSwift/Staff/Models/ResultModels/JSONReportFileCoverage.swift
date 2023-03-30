//

import Foundation
import SwiftlaneCore

struct JSONReportFileCoverage {
	let file: RelativePath
	let coverage: [Int?]
}

extension JSONReportFileCoverage: Codable {}

extension JSONReportFileCoverage: Equatable {}

extension JSONReportFileCoverage: Hashable {}
