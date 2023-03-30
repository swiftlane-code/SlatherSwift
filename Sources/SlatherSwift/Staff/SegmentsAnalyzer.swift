//

import Foundation

protocol SegmentsAnalyzing {
	func linePresentationCount(lineNumber: Int, segments: [Segment]) -> LineInfo
	func nextClosingSegment(startIdx: Int, segments: [Segment]) -> NextSegment
	func isClosing(_ segment: Segment) -> Bool
	func isStartOfRegion(_ segment: Segment) -> Bool
	func lineHits(lineNumber: Int, segments: [Segment]) -> Int?
}

struct SegmentsAnalyzer {}

// MARK: - SegmentsAnalyzing

extension SegmentsAnalyzer: SegmentsAnalyzing {
	func linePresentationCount(lineNumber: Int, segments: [Segment]) -> LineInfo {
		let lineSegments = segments.filter { $0.line == lineNumber && !isClosing($0) }

		let totalCount = lineSegments.lazy.filter(\.hasCount).count
		let hitsCount = lineSegments.lazy.filter { $0.hits > 0 }.count

		return LineInfo(tested: hitsCount, total: totalCount)
	}

	func nextClosingSegment(startIdx: Int, segments: [Segment]) -> NextSegment {
		var idx = startIdx

		while true {
			idx += 1
			guard isClosing(segments[idx]) else { continue }

			let nextStartingIndex = idx + 1
			if segments.indices.contains(nextStartingIndex) {
				let startingSegmentLineNumber = segments[startIdx].line
				let nextSegmentLineNumber = segments[nextStartingIndex].line

				if nextSegmentLineNumber == startingSegmentLineNumber { continue }
			}
			return NextSegment(idx: idx, segment: segments[idx])
		}
	}

	func isClosing(_ segment: Segment) -> Bool {
		return !segment.hasCount && !segment.isRegionEntry && !segment.isGapRegion
	}

	func isStartOfRegion(_ segment: Segment) -> Bool {
		return !segment.isGapRegion && segment.hasCount && segment.isRegionEntry
	}

	// Inspired by original implementation
	// https://github.com/llvm/llvm-project/blob/d2a8a3af5e64a6dcfbe463311091d9e6b4d9c102/llvm/lib/ProfileData/Coverage/CoverageMapping.cpp#L808
	func lineHits(lineNumber: Int, segments: [Segment]) -> Int? {
		let pureLineSegments = segments.filter { $0.line == lineNumber }
		let lineSegments = pureLineSegments.filter { isStartOfRegion($0) }
		let minRegionCount = lineSegments.prefix(2).count

		let previousLinesSegments = segments.last(where: { $0.line < lineNumber })
		let previousSegmentHits = previousLinesSegments?.hits ?? 0

		guard !lineSegments.isEmpty else {
			let startOfSkippedRegion = !pureLineSegments.isEmpty
				&& !pureLineSegments.first!.hasCount
				&& pureLineSegments.first!.isRegionEntry

			// Check for isMapped in original code LLVM
			if !startOfSkippedRegion, (previousLinesSegments?.hasCount ?? false) || minRegionCount > 0 {
				return previousSegmentHits
			}

			return nil
		}

		let maxLineSegmentsHits = lineSegments.map(\.hits).max() ?? 0
		let count = max(previousSegmentHits, maxLineSegmentsHits)

		return count
	}
}
