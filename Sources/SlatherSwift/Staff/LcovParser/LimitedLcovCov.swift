//

import Foundation
import SwiftlaneCore

// Limited becase contains only info about file path and hits per line
struct LimitedLcovCov {
	let filePath: AbsolutePath
	let lineHits: [UInt: UInt]
}

extension LimitedLcovCov: Hashable {}
