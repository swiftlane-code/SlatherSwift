//

import Foundation

protocol HitsCorrecting {
	func correct(_ initial: Int) -> Int
}

struct RubyVersionHitsCorrector {}

// MARK: - HitsCorrecting

extension RubyVersionHitsCorrector: HitsCorrecting {
	/// Magic from original Ruby Slather
	func correct(_ initial: Int) -> Int {
		var initial = initial
		guard initial > 999 else {
			return initial
		}

		if initial > 9999 {
			initial = Int(initial / 100) * 100
		}

		let firstLowered = Double(initial) / 10
		let firstTrancated = Double(Int(firstLowered))
		let firstDiff = Int(round((firstLowered - firstTrancated) * 10))

		let slowered = Double(initial) / 100
		let strancated = Double(Int(slowered))
		let sDiff = Int(round((slowered - strancated) * 100))

		var roundImp = floor
		if firstDiff > 9, sDiff >= 10 {
			roundImp = round
		}

		let corrected = roundImp(Double(initial) / 10) * 10
		return Int(corrected)
	}
}
