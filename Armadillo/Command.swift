import Foundation

public struct Command {
	private let command: String
	private let args: [String]

	public init?(raw: String) {
		var components = raw.componentsSeparatedByString(" ")
		guard !components.isEmpty else {
			return nil
		}

		command = components.removeFirst()

		var inString = false
		var remainingComponents = [String]()
		for component in components {
			var appendingComponent = component

			if appendingComponent.hasPrefix("\"") {
				inString = true

				appendingComponent.replaceRange((appendingComponent.startIndex ... appendingComponent.startIndex), with: "")
			}

			if appendingComponent.hasSuffix("\"") {
				inString = false

				appendingComponent.replaceRange((appendingComponent.endIndex.predecessor() ..< appendingComponent.endIndex), with: "")
			}

			if inString {
				appendingComponent = remainingComponents.removeLast() + " " + appendingComponent
			}

			remainingComponents.append(appendingComponent)
		}

		args = remainingComponents ?? []
	}

	public func run() -> (standardOutput: String?, standardError: String?, exitCode: Int) {
		// todo: fix piping tasks along, e.g.: `git diff HEAD | mate` should work
		let task = NSTask()
		task.launchPath = command
		task.arguments = args

		let standardOutputPipe = NSPipe()
		task.standardOutput = standardOutputPipe

		let standardErrorPipe = NSPipe()
		task.standardError = standardErrorPipe

		task.launch()
		task.waitUntilExit()

		let standardOutput = String(data: standardOutputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
		let standardError = String(data: standardErrorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
		let exitCode = Int(task.terminationStatus)

		return (standardOutput: standardOutput, standardError: standardError, exitCode: exitCode)
	}
}
