//

struct RubyVersionTotalRatesCalculator {
	func calculate(using packagesInfo: PackagesInfo) -> LBRatesInfo {
		let linesCovered = packagesInfo.coverageInfo.lines.covered
		let totalLines = packagesInfo.coverageInfo.lines.total
		let totalLineRate = packagesInfo.coverageInfo.lines.rate

		let branchesCovered = packagesInfo.coverageInfo.branches.covered
		let totalBranches = packagesInfo.coverageInfo.branches.total
		let totalBranchesRate = packagesInfo.coverageInfo.branches.rate

		return LBRatesInfo(
			lines: RateInfo(covered: linesCovered, total: totalLines, rate: totalLineRate),
			branches: RateInfo(covered: branchesCovered, total: totalBranches, rate: totalBranchesRate)
		)
	}
}
