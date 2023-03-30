//

import Foundation
import SwiftlaneCore

struct RubyObjectsSorter {
	func sort(filePaths: [AbsolutePath], orderedTargetNames: [String]) -> [AbsolutePath] {
		let namesIndices = orderedTargetNames.enumerated().reduce(into: [String: Int]()) { dict, args in
			let (idx, targetName) = args
			dict[targetName] = idx
		}
		
		func firstIndex(filePath: AbsolutePath) -> Int {
			namesIndices[filePath.lastComponent.string] ?? 0
		}

		return filePaths.sorted { firstIndex(filePath: $0) < firstIndex(filePath: $1) }
	}

	func sort(packages: [Package], namesOrder: [String]) -> [Package] {
		let namesIndices = namesOrder.enumerated().reduce(into: [String: Int]()) { dict, args in
			let (idx, packageName) = args
			dict[packageName] = idx
		}
		
		func firstIndex(package: Package) -> Int {
			namesIndices[package.name] ?? 0
		}

		return packages.sorted { firstIndex(package: $0) < firstIndex(package: $1) }
	}
}
