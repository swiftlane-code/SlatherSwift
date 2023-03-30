//

struct CoberturaEncoder {
	private let xmlHeader = """
	<?xml version="1.0"?>
	<!DOCTYPE coverage SYSTEM "http://cobertura.sourceforge.net/xml/coverage-04.dtd">
	"""

	// MARK: Private

	private func c(_ value: Double) -> String {
		return String(format: "%.16f", value)
	}

	private func ts(_ value: Double) -> String {
		return String(format: "%.f", value)
	}

	private func describerCoverage(cov: CoberturaCoverage) -> String {
		var text =
			#"<coverage line-rate="\#(c(cov.totalRateInfo.lines.rate))" branch-rate="\#(c(cov.totalRateInfo.branches.rate))" lines-covered="\#(cov.totalRateInfo.lines.covered)" lines-valid="\#(cov.totalRateInfo.lines.total)" branches-covered="\#(cov.totalRateInfo.branches.covered)" branches-valid="\#(cov.totalRateInfo.branches.total)" complexity="\#(cov.complexity)" timestamp="\#(ts(cov.timestamp))" version="\#(cov.versionDescription)">"#

		text += "\(describeSources(sources: cov.sources))"
		text += "\(descPackages(packages: cov.packages))"
		text += "</coverage>"

		return text
	}

	private func describeSources(sources: [String]) -> String {
		var desc = "<sources>"
		desc += sources.flatMap { "<source>\($0)</source>" }
		desc += "</sources>"

		return desc
	}

	private func descPackages(packages: [Package]) -> String {
		var desc = "<packages>"
		desc += packages.flatMap { descPackage(package: $0) }
		desc += "</packages>"

		return desc
	}

	private func descPackage(package pkg: Package) -> String {
		var desc = ""
		desc += """
		<package name="\(pkg.name.replacingOccurrences(of: "&", with: "&amp;"))"
		line-rate="\(c(pkg.characteristics.lineRate))"
		branch-rate="\(c(pkg.characteristics.branchRate))"
		complexity="\(pkg.characteristics.complexity)">
		"""
		desc += descClasses(classes: pkg.classes)
		desc += "</package>"

		return desc
	}

	private func descClasses(classes: [PackageClass]) -> String {
		var desc = "<classes>"
		desc += classes.flatMap { descPkgClass($0) }
		desc += "</classes>"

		return desc
	}

	private func descPkgClass(_ pkgClass: PackageClass) -> String {
		var desc = """
		<class name="\(pkgClass.name)"
		filename="\(pkgClass.filename.replacingOccurrences(of: "&", with: "&amp;"))"
		line-rate="\(c(pkgClass.characteristics.lineRate))"
		branch-rate="\(c(pkgClass.characteristics.branchRate))"
		complexity="\(pkgClass.characteristics.complexity)">
		"""

		desc += "<methods></methods>"
		desc += descLines(pkgClass.lines)
		desc += "</class>"

		return desc
	}

	private func descLines(_ lines: [Line]) -> String {
		var desc = "<lines>"
		desc += lines.flatMap { descLine($0) }
		desc += "</lines>"

		return desc
	}

	private func descLine(_ line: Line) -> String {
		var desc = """
		<line number="\(line.number)" branch="\(line.isBranch)" hits="\(line.hits)"
		"""
		if let conditions = line.conditions {
			desc += """
			 condition-coverage="\(conditions.conditionCoverage)">
			"""
			desc += descConditions(conditions)
		} else {
			desc += ">"
		}

		desc += "</line>"

		return desc
	}

	private func descConditions(_ conditions: LineConditions) -> String {
		var desc = "<conditions>"
		desc += conditions.conditions.flatMap { descCondition($0) }
		desc += "</conditions>"

		return desc
	}

	private func descCondition(_ condition: LineCondition) -> String {
		let desc = """
		<condition number="\(condition.number)" type="\(condition.type)" coverage="\(condition.coverage)"/>
		"""
		return desc
	}

	// MARK: Public

	func encode(cov: CoberturaCoverage) -> String {
		var xml = xmlHeader
		xml += "\(describerCoverage(cov: cov))"

		return xml
	}
}
