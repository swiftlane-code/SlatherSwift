//

import SwiftlaneCore

struct TotalRatesCalculator {
	// MARK: Private

	private func calculateCoveredLines(_ responses: [CovResponse]) -> Int {
		responses.lazy
			.flatMap(\.data)
			.summarize(\.totals.lines.covered)
	}

	private func calculateTotalLines(_ responses: [CovResponse]) -> Int {
		responses.lazy
			.flatMap(\.data)
			.summarize(\.totals.lines.count)
	}

	private func calculateCoveredRegions(_ responses: [CovResponse]) -> Int {
		responses.lazy
			.flatMap(\.data)
			.summarize(\.totals.regions.covered)
	}
	
	private func calculateTotalRegions(_ responses: [CovResponse]) -> Int {
		responses.lazy
			.flatMap(\.data)
			.summarize(\.totals.regions.count)
	}

	// MARK: Public

	func calculate(_ responses: [CovResponse]) -> LBRatesInfo {
		let linesCovered = calculateCoveredLines(responses)
		let totalLines = calculateTotalLines(responses)
		let totalLineRate = linesCovered.rate(against: totalLines)

		let branchesCovered = calculateCoveredRegions(responses)
		let totalBranches = calculateTotalRegions(responses)
		let totalBranchesRate = branchesCovered.rate(against: totalBranches)

		return LBRatesInfo(
			lines: RateInfo(covered: linesCovered, total: totalLines, rate: totalLineRate),
			branches: RateInfo(covered: branchesCovered, total: totalBranches, rate: totalBranchesRate)
		)
	}
}
