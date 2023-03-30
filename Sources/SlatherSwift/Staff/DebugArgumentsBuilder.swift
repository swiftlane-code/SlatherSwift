//

import Foundation

#if DEBUG
	enum DebugArgumentsBuilder {
		static func buildCoverageCommand() -> [String] {
			var result = [DebugArgumentNames.coverage.rawValue]
			result.append(contentsOf: buildDefaultSet())
			return result
		}

		static func buildDefaultSet() -> [String] {
			build(for: [
				.derivedDataDir: "your-derrived-data",
				.outputDir: "/Users/user/Desktop/",
				.projectRootDir: "/Users/user/Desktop/",
				.executablesNames: "TargetsNamesByComma",
				.rubyVersionCompatiabilityMode: nil, // bool option
			])
		}

		// MARK: Private

		private static func build(for arguments: [DebugArgumentNames: String?]) -> [String] {
			var result: [String] = []
			arguments.forEach {
				result.append($0.key.rawValue)
				if let value = $0.value {
					result.append(" " + value)
				}
			}
			return result
		}
	}

	enum DebugArgumentNames: String, Hashable {
		// Commands
		case coverage = "coverage"
		case compare = "compare"
		case collectDebugInfo = "collect-debug-info"

		// Command params
		case coberturaXMLTimestamp = "--cobertura-xml-timestamp"
		case derivedDataDir = "--derived-data-dir"
		case outputDir = "--output-directory"
		case projectRootDir = "--project-root-directory"
		case executablesNames = "--executables-names"
		case rubyVersionCompatiabilityMode = "--ruby-version-compatiability-mode" // bool
		case formatCoberturaXML = "--format-cobertura-xml" // bool
		case coberturaXmlFileName = "--cobertura-xml-file-name"
		case jsonReportFileName = "--json-report-file-name"
		case expected = "--expected"
		case gotten = "--gotten"
		case isOpenDiffOnFailure = "--is-open-diff-on-failure" // bool
		case diffOpeningTimeout = "--diff-opening-timeout"
		case branchRateAccuracyTrancationSize = "--branch-rate-accuracy-trancation-size"
		case ignoreVersionValidation = "--ignore-version-validation"
		case ignoreTimestampValidation = "--ignore-timestamp-validation"
	}
#endif
