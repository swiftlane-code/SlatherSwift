//

private func main() {
	var args = Array(CommandLine.arguments.dropFirst())

	#if DEBUG
		args.append(contentsOf: DebugArgumentsBuilder.buildCoverageCommand())
	#endif

	RootCommand.main(args)
}

main()
