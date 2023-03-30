//

import ArgumentParser

struct RootCommand: ParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "SlatherSwift",
		abstract: "Generating tests coverage reports by Xcode projects. Representatived as cobertura.xml and json-report.",
		version: UTILL_VERSION,
		subcommands: [
			CoverageCommand.self,
			CompareCommand.self,
			CollectDebugInfoCommand.self,
		]
	)
}
