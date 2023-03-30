//

import Foundation

extension Array where Element == String {
	func contains(_ argument: LaunchArgument) -> Bool {
		return contains(argument.rawValue)
	}
}
