//

import Combine
import Foundation
import SwiftlaneCore

struct CoberturaModelsBuilder {
	private let packagesNamesProducer: PackagesNamesProducing
	private let hitsCorrector: HitsCorrecting
	private let totalRatesCalculator: TotalRatesCalculator
	private let segmentsAnalizer: SegmentsAnalyzing
	private let rubyVersionTotalRatesCalculator: RubyVersionTotalRatesCalculator
	private let artifactNamesCalculator: ArtifactsNamesCalculator
	private let rubyVersionPackagesSorter: RubyObjectsSorter
	private let rubyVersionCompatiabilityMode: Bool

	public init(
		packagesNamesProducer: PackagesNamesProducing,
		hitsCorrector: HitsCorrecting,
		totalRatesCalculator: TotalRatesCalculator,
		segmentsAnalizer: SegmentsAnalyzing,
		rubyVersionTotalRatesCalculator: RubyVersionTotalRatesCalculator,
		artifactNamesCalculator: ArtifactsNamesCalculator,
		rubyVersionPackagesSorter: RubyObjectsSorter,
		rubyVersionCompatiabilityMode: Bool
	) {
		self.packagesNamesProducer = packagesNamesProducer
		self.hitsCorrector = hitsCorrector
		self.totalRatesCalculator = totalRatesCalculator
		self.segmentsAnalizer = segmentsAnalizer
		self.rubyVersionTotalRatesCalculator = rubyVersionTotalRatesCalculator
		self.artifactNamesCalculator = artifactNamesCalculator
		self.rubyVersionPackagesSorter = rubyVersionPackagesSorter
		self.rubyVersionCompatiabilityMode = rubyVersionCompatiabilityMode
	}

	func build(
		responses: [CovResponse],
		derivedDataPath: AbsolutePath,
		projectRootDir: AbsolutePath,
		timestamp: TimeInterval,
		utilVersion: String,
		coverageParsingTimeout: TimeInterval
	) throws -> CoberturaCoverage {
		let packagesInfo = try buildPackagesAsync(
			responses: responses,
			derivedDataPath: derivedDataPath,
			projectRootDir: projectRootDir,
			coverageParsingTimeout: coverageParsingTimeout
		)

		let totalRateInfo: LBRatesInfo

		if rubyVersionCompatiabilityMode {
			totalRateInfo = rubyVersionTotalRatesCalculator.calculate(using: packagesInfo)
		} else {
			totalRateInfo = totalRatesCalculator.calculate(responses)
		}

		let sourcePath = projectRootDir.string.deletingSuffix("/")

		let cov = CoberturaCoverage(
			totalRateInfo: totalRateInfo,
			timestamp: timestamp,
			versionDescription: utilVersion,
			sources: [sourcePath],
			packages: packagesInfo.packages
		)

		return cov
	}

	func buildPackagesAsync(
		responses: [CovResponse],
		derivedDataPath: AbsolutePath,
		projectRootDir: AbsolutePath,
		coverageParsingTimeout: TimeInterval
	) throws -> PackagesInfo {
		let packagesNames = try packagesNamesProducer.produce(for: responses, projectRootDir: projectRootDir)

		let filesForCalculate: [String: [CovFile]] = try responses.flatMap(\.data)
			.flatMap(\.files)
			.reduce(into: [:]) { dictionary, covFile in
				let packageName = try artifactNamesCalculator.calculatePackageName(covFile.filename, projectRootDir: projectRootDir)
				dictionary[packageName, default: []].append(covFile)
			}

		let chunksCount = (filesForCalculate.count / ProcessInfo.processInfo.activeProcessorCount) + 1
		let chunks = filesForCalculate.asArray.chunks(maxChunkSize: chunksCount)

		let publishersChunks = chunks.map { chunk in
			performAsync(qos: .userInitiated) {
				try chunk.map { try buildPackage(files: $0.value, name: $0.key, projectRootDir: projectRootDir) }
			}
		}

		let packagesInfo = try Publishers.MergeMany(publishersChunks)
			.collect()
			.await(timeout: coverageParsingTimeout)
			.flatMap { $0 }

		let packages = packagesInfo.map(\.package)

		let totalLinesCount = packagesInfo.summarize(\.coverageInfo.lines.total)
		let coveredLinesCount = packagesInfo.summarize(\.coverageInfo.lines.covered)
		let totalBranchesCount = packagesInfo.summarize(\.coverageInfo.branches.total)
		let coveredBranchesCount = packagesInfo.summarize(\.coverageInfo.branches.covered)

		var packagesForReport = packages
		if rubyVersionCompatiabilityMode {
			packagesForReport = rubyVersionPackagesSorter.sort(packages: packages, namesOrder: packagesNames)
		}

		let coverageInfo = LBCoverageInfo(
			lines: CoverageInfo(covered: coveredLinesCount, total: totalLinesCount),
			branches: CoverageInfo(covered: coveredBranchesCount, total: totalBranchesCount)
		)
		let info = PackagesInfo(
			packages: packagesForReport,
			coverageInfo: coverageInfo
		)

		return info
	}

	func buildPackage(
		files: [CovFile],
		name: String,
		projectRootDir: AbsolutePath
	) throws -> PackageInfo {
		let classesInfo = try buildPkgClasses(files: files, projectRootDir: projectRootDir)

		let characteristics = Characteristics(
			lineRate: classesInfo.coverageInfo.lines.rate,
			branchRate: classesInfo.coverageInfo.branches.rate
		)
		let package = Package(name: name, characteristics: characteristics, classes: classesInfo.classes)

		let info = PackageInfo(
			package: package,
			coverageInfo: classesInfo.coverageInfo
		)

		return info
	}

	func buildPkgClasses(files: [CovFile], projectRootDir: AbsolutePath) throws -> PackageClassesInfo {
		var classes: [PackageClass] = []

		var totalLinesCount = 0
		var coveredLinesCount = 0
		var totalBranchesCount = 0
		var coveredBranchesCount = 0

		try files.forEach {
			let name = try artifactNamesCalculator.calculateClassName(path: $0.filename)

			let relFilename = artifactNamesCalculator.calculatePkgClassFilename(
				path: $0.filename,
				projectRootDir: projectRootDir
			)

			let intermediateLineInfo = try buildLines(segments: $0.segments, filename: $0.filename)
			let coverageInfo = intermediateLineInfo.coverageInfo

			totalLinesCount += coverageInfo.lines.total
			coveredLinesCount += coverageInfo.lines.covered
			totalBranchesCount += coverageInfo.branches.total
			coveredBranchesCount += coverageInfo.branches.covered

			let characteristics = Characteristics(
				lineRate: coverageInfo.lines.rate,
				branchRate: coverageInfo.branches.rate
			)

			let pkgClass = PackageClass(
				name: name,
				filename: relFilename,
				characteristics: characteristics,
				lines: intermediateLineInfo.lines
			)

			classes.append(pkgClass)
		}

		let coverageInfo = LBCoverageInfo(
			lines: CoverageInfo(covered: coveredLinesCount, total: totalLinesCount),
			branches: CoverageInfo(covered: coveredBranchesCount, total: totalBranchesCount)
		)

		let packageClasses = PackageClassesInfo(
			classes: classes,
			coverageInfo: coverageInfo
		)

		return packageClasses
	}

	func buildLines(segments: [Segment], filename _: String) throws -> LinesInfo {
		var lines: [Line] = []

		guard let lastSegment = segments.last else {
			return LinesInfo(
				lines: [],
				coverageInfo: LBCoverageInfo(
					lines: CoverageInfo(covered: 0, total: 0),
					branches: CoverageInfo(covered: 0, total: 0)
				)
			)
		}

		var testableLinesCount = 0
		var testableBranchesCount = 0
		var testedBranchesCount = 0

		var curIdx = 0

		while curIdx < segments.count - 1 {
			let segment = segments[curIdx]

			let nextClosingSegment = segmentsAnalizer.nextClosingSegment(startIdx: curIdx, segments: segments)
			let nextSegment = nextClosingSegment.segment
			curIdx = nextClosingSegment.idx

			let segmentLine = segment.line
			let nextSegmentLine = nextSegment.line

			let lineNumbers = Array(segmentLine...nextSegmentLine)
			testableLinesCount += lineNumbers.count

			lineNumbers.forEach { lineNumber in
				guard let hits = segmentsAnalizer.lineHits(lineNumber: lineNumber, segments: segments) else {
					testableLinesCount -= 1
					testableBranchesCount += 1
					return
				}

				let linePresentation = segmentsAnalizer.linePresentationCount(lineNumber: lineNumber, segments: segments)

				var conditions: LineConditions?
				let isBranch = linePresentation.total > 0
				if isBranch {
					let percent = Int(linePresentation.tested.percentage(against: linePresentation.total))
					let conditionCoverage = "\(percent)% (\(linePresentation.tested)/\(linePresentation.total))"
					let coverage = "\(percent)%"

					testableBranchesCount += linePresentation.total
					testedBranchesCount += linePresentation.tested

					conditions = LineConditions(
						conditionCoverage: conditionCoverage,
						conditions: [LineCondition(coverage: coverage)]
					)
				}

				let line = Line(
					number: lineNumber,
					isBranch: isBranch,
					hits: rubyVersionCompatiabilityMode ? hitsCorrector.correct(hits) : hits,
					conditions: conditions
				)

				lines.append(line)
			}

			if nextSegment == lastSegment {
				break
			}

			curIdx += 1
		}

		let testedLinesCount = lines.lazy.filter { $0.hits > 0 }.count
		let counting = LBCoverageInfo(
			lines: CoverageInfo(covered: testedLinesCount, total: testableLinesCount),
			branches: CoverageInfo(covered: testedBranchesCount, total: testableBranchesCount)
		)

		let linesInfo = LinesInfo(lines: lines, coverageInfo: counting)

		return linesInfo
	}
}
