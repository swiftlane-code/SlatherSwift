//

import Foundation

enum CoberturaPatchCommand {
	case branchRate(UInt)
	case timestamp(String)
	case utilityVersion(String)
	case custom(String)
}

extension CoberturaPatchCommand: CustomStringConvertible {
	var description: String {
		switch self {
		case let .branchRate(size):
			return #"sed -i -E "s/\(branch-rate\=\"\)\([0-9]*\.[0-9]*\)\([0-9]\{\#(size)\}\)\(\"\)/\1\2IGNORED\4/g""#
		case let .timestamp(ignoreStub):
			return #"sed -i -E "s/\(timestamp\=\"\)\([0-9]*\)\(\"\)/\1\#(ignoreStub)\3/g""#
		case let .utilityVersion(ignoreStub):
			return #"sed -i -E "s/\(version\=\"\)\(.*\)\(\"\)/\1\#(ignoreStub)\3/g""#
		case let .custom(command):
			return command
		}
	}
}
