//

import Combine
import Foundation
import SwiftlaneCore

struct CoverageCommandRunner {
	private let profdataFinder: ProfdataFinder
	private let executableFinder: ExecutableFinder
	private let covMiner: LLVMCovMiner
	private let covResponsesParser: LLVMCovParser
	private let coberturaEncoder: CoberturaEncoder
	private let coberturaWriter: CoberturaWriting
	private let jsonReportWriter: JSONReportWriter
	private let jsonReportBuilder: JSONReportBuilder

	init(
		profdataFinder: ProfdataFinder,
		executableFinder: ExecutableFinder,
		covMiner: LLVMCovMiner,
		covResponsesParser: LLVMCovParser,
		coberturaEncoder: CoberturaEncoder,
		coberturaWriter: CoberturaWriting,
		jsonReportWriter: JSONReportWriter,
		jsonReportBuilder: JSONReportBuilder
	) {
		self.profdataFinder = profdataFinder
		self.executableFinder = executableFinder
		self.covMiner = covMiner
		self.covResponsesParser = covResponsesParser
		self.coberturaEncoder = coberturaEncoder
		self.coberturaWriter = coberturaWriter
		self.jsonReportWriter = jsonReportWriter
		self.jsonReportBuilder = jsonReportBuilder
	}

	private func utilNameAndVersion() -> String {
		guard
			let executablePath = Bundle.main.executablePath,
			let utilName = try? AbsolutePath(executablePath).lastComponent
		else {
			return UTILL_VERSION
		}
		return "\(utilName) \(UTILL_VERSION)"
	}

	func run(
		absDerivedDataDir: AbsolutePath,
		outDir: AbsolutePath,
		executablesNames: String,
		projectRootDir: AbsolutePath,
		rubyVersionCompatiabilityMode: Bool,
		coverageParsingTimeout: TimeInterval,
		coberturaXMLFileName: String,
		isFormatCoberturaXML: Bool,
		jsonReportFileName: String?
	) throws {
		let timeMeasure = TimeMeasurer(logger: DetailedLogger(logLevel: .verbose))
		let seedFull = timeMeasure.measure(description: "Full measure")

		let profdataFile = try profdataFinder.find(absDerivedDataDir: absDerivedDataDir)

		let executableFiles = try executableFinder.find(
			absDerivedDataDir: absDerivedDataDir,
			executablesNamesList: executablesNames
		)

		let responses: [CovResponse] = try Publishers.MergeMany(
			executableFiles.map { file -> AnyPublisher<CovResponse, Error> in
				performAsync(qos: .userInitiated) {
					let covJson = try covMiner.produce(profdataFile: profdataFile, executableFile: file, format: .json)
					return try covResponsesParser.build(using: covJson)
				}
			}
		).collect().await()

		// Original without sorted because ruby data sorted in executableFinder 👆
		let packagesNamesProducer = PackagesNamesProducer(sorter: { rubyVersionCompatiabilityMode ? $0 : $0.sorted() })

		let coberturaCoverageBuilder = CoberturaModelsBuilder(
			packagesNamesProducer: packagesNamesProducer,
			hitsCorrector: RubyVersionHitsCorrector(),
			totalRatesCalculator: TotalRatesCalculator(),
			segmentsAnalizer: SegmentsAnalyzer(),
			rubyVersionTotalRatesCalculator: RubyVersionTotalRatesCalculator(),
			artifactNamesCalculator: ArtifactsNamesCalculator(),
			rubyVersionPackagesSorter: RubyObjectsSorter(),
			rubyVersionCompatiabilityMode: rubyVersionCompatiabilityMode
		)

		let coberturaCoverage = try coberturaCoverageBuilder.build(
			responses: responses,
			derivedDataPath: absDerivedDataDir,
			projectRootDir: projectRootDir,
			timestamp: Date().timeIntervalSince1970,
			utilVersion: utilNameAndVersion(),
			coverageParsingTimeout: coverageParsingTimeout
		)

		let coberturaXML = coberturaEncoder.encode(cov: coberturaCoverage)
		try coberturaWriter.write(
			coberturaXML: coberturaXML,
			outDir: outDir,
			fileName: coberturaXMLFileName,
			isFormatXML: isFormatCoberturaXML
		)
		
		if let jsonReportFileName = jsonReportFileName {
			let jsonReport = try jsonReportBuilder.build(cobertura: coberturaCoverage)

			let jsonReportFilePath = outDir.appending(suffix: "/").appending(suffix: jsonReportFileName)
			try jsonReportWriter.write(report: jsonReport, into: jsonReportFilePath)
		}

		seedFull.finishTimeMeasuring()
	}
}
