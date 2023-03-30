//

import Foundation
import SwiftlaneCore

struct LLVMCovParser {
	func build(using json: String) throws -> CovResponse {
		let covJSONData = try json.data(using: .utf8)
			.unwrap(
				errorDescription: "Coverage stdout text can not be encoded in to data using .utf8 encoding"
			)
		let resp = try JSONDecoder().decode(CovResponse.self, from: covJSONData)
		return resp
	}
}
