//

import SwiftlaneCore

protocol PackagesNamesProducing {
	func produce(for responses: [CovResponse], projectRootDir: AbsolutePath) throws -> [String]
}

final class PackagesNamesProducer {
	private let nameCalculator: PackageNameCalculator
	private let sorter: ([String]) -> [String]

	init(
		nameCalculator: PackageNameCalculator = PackageNameCalculator(),
		sorter: @escaping ([String]) -> [String] = { $0 }
	) {
		self.nameCalculator = nameCalculator
		self.sorter = sorter
	}
}

// MARK: - PackagesNamesProducing

extension PackagesNamesProducer: PackagesNamesProducing {
	func produce(for responses: [CovResponse], projectRootDir: AbsolutePath) throws -> [String] {
		let result = try responses.flatMap(\.data).flatMap(\.files).map {
			try nameCalculator.calculate(
				try AbsolutePath($0.filename),
				projectRootDir: projectRootDir
			)
		}
		.removingDuplicates

		return sorter(result)
	}
}
