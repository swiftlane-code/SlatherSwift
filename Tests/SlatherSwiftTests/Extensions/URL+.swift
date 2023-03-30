//

import Foundation

extension URL {
	func absoluteStringWithoutScheme() -> String {
		guard let scheme = scheme else {
			return absoluteString
		}

		return absoluteString.deletingPrefix("\(scheme)://")
	}
}
