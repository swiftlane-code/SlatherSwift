//

import Foundation

enum StubSubpath: String, CustomStringConvertible {
	case all = "All"
	case individually = "Individually"

	var description: String {
		return rawValue.uppercasedFirst
	}
}
