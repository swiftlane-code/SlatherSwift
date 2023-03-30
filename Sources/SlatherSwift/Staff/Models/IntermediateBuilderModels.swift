//

import SwiftlaneCore

struct LineInfo: Equatable {
	let tested: Int
	let total: Int
}

struct CoverageInfo {
	let covered: Int
	let total: Int

	var rate: Double { covered.rate(against: total) }
}

struct LBCoverageInfo {
	let lines: CoverageInfo
	let branches: CoverageInfo
}

struct LinesInfo {
	let lines: [Line]
	let coverageInfo: LBCoverageInfo
}

struct PackageClassesInfo {
	let classes: [PackageClass]
	let coverageInfo: LBCoverageInfo
}

struct PackageInfo {
	let package: Package
	let coverageInfo: LBCoverageInfo
}

struct PackagesInfo {
	let packages: [Package]
	let coverageInfo: LBCoverageInfo
}
