//

import Foundation

struct LineCondition {
	let number: UInt = 0 // XZ - it is always has this value in the Ruby version of Slather
	let type: String = "jump" // XZ - it is always has this value in the Ruby version of Slather
	let coverage: String
}

struct LineConditions {
	let conditionCoverage: String
	let conditions: [LineCondition]
}

struct Line {
	let number: Int
	let isBranch: Bool
	let hits: Int
	let conditions: LineConditions?
}

struct Characteristics {
	let lineRate: Double
	let branchRate: Double
	let complexity: Double = 0.0 // XZ - it is always has this value in the Ruby version of Slather
}

struct PackageClass {
	let name: String
	let filename: String
	let characteristics: Characteristics
	let lines: [Line]
}

struct Package {
	let name: String
	let characteristics: Characteristics
	let classes: [PackageClass]
}

struct RateInfo {
	let covered: Int
	let total: Int
	let rate: Double
}

struct LBRatesInfo {
	let lines: RateInfo
	let branches: RateInfo
}

struct CoberturaCoverage {
	let totalRateInfo: LBRatesInfo
	let complexity: Double = 0.0 // XZ - it is always has this value in the Ruby version of Slather
	let timestamp: TimeInterval
	let versionDescription: String
	let sources: [String]
	let packages: [Package]
}
