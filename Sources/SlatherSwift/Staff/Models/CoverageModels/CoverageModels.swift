//

import Foundation

struct CovFile: Decodable {
	let filename: String
	let segments: [Segment]
	let summary: FileSummary
}

struct LinesSummary: Decodable {
	let count: Int
	let covered: Int
	let percent: Double
}

struct RegionsSummary: Decodable {
	let count: Int
	let covered: Int
	let notcovered: Int
	let percent: Double
}

struct FileSummary: Decodable {
	let lines: LinesSummary
	let regions: RegionsSummary
}

struct CovItem: Decodable {
	let files: [CovFile]
	let totals: FileSummary
}

struct CovResponse: Decodable {
	let data: [CovItem]
	let type: String
	let version: String
}
