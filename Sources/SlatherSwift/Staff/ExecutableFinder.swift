//

import SwiftlaneCore

extension ExecutableFinder {
	enum Errors: Error {
		case noOneIn(AbsolutePath)
		case invalidExecutableName(String)
	}
}

struct ExecutableFinder {
	private let fileManager: FSManaging
	private let filesSorter: RubyObjectsSorter?

	init(
		fileManager: FSManaging,
		filesSorter: RubyObjectsSorter?
	) {
		self.fileManager = fileManager
		self.filesSorter = filesSorter
	}

	func find(absDerivedDataDir: AbsolutePath, executablesNamesList: String) throws -> [AbsolutePath] {
		let executablesNames = try prepareExecutableNames(executablesNamesList)

		let searchingPathSuffixes: [String] = executablesNames.map { executableName in
			let executableNameWithoutExtension = executableName.split(separator: ".")
				.dropLast()
				.joined(separator: ".")

			return "\(executableName)/\(executableNameWithoutExtension)"
		}

		let files = try fileManager.find(absDerivedDataDir).filter { path in
			path.string.contains("/Build/Products/") &&
				!path.string.contains(".xctest/") &&
				!path.string.contains(".app/Frameworks/") &&
				searchingPathSuffixes.contains(where: { path.hasSuffix($0) })
		}

		guard !files.isEmpty else {
			throw Errors.noOneIn(absDerivedDataDir)
		}

		guard let sorter = filesSorter else {
			return files
		}

		return sorter.sort(
			filePaths: files,
			orderedTargetNames: calculateExecutablesNames(executablesNamesList)
		)
	}

	func calculateExecutablesNames(_ executablesNames: String) -> [String] {
		return executablesNames.components(separatedBy: ",")
	}

	func prepareExecutableNames(_ rawExecutablesNames: String) throws -> [String] {
		let executablesNames = calculateExecutablesNames(rawExecutablesNames)
		let names: [String] = try executablesNames.map { curExecutableName in
			let trimmed = curExecutableName.trimmingCharacters(in: .whitespacesAndNewlines)

			guard trimmed == curExecutableName else {
				throw Errors.invalidExecutableName("\"\(curExecutableName)\"")
			}

			guard !trimmed.isEmpty else {
				throw Errors.invalidExecutableName("\"\(curExecutableName)\"")
			}

			let allExtensions = ["app", "framework"]
			guard
				let executableExtension = curExecutableName.split(separator: ".").last,
				!allExtensions.contains(String(executableExtension))
			else {
				return [String(curExecutableName)]
			}

			return allExtensions.map { "\(curExecutableName).\($0)" }
		}.reduce([], +)

		return names
	}
}
