import Foundation

public struct Command {
	private let command: String
	private let args: [String]

	public init?(raw: String) {
		var components = raw.components(separatedBy: " ")
		guard !components.isEmpty else {
			return nil
		}

		command = components.removeFirst()

		var inString = false
		var startingString = false
		var remainingComponents = [String]()
		for component in components {
			startingString = false

			var appendingComponent = component
			if appendingComponent.hasPrefix("\"") {
				if !inString {
					startingString = true
				}

				inString = true

				appendingComponent.replaceSubrange((appendingComponent.startIndex ... appendingComponent.startIndex), with: "")
			}

			var endingString = false
			if appendingComponent.hasSuffix("\"") {
				inString = false
				endingString = true

				appendingComponent.replaceSubrange((appendingComponent.characters.index(before: appendingComponent.endIndex) ..< appendingComponent.endIndex), with: "")
			}

			if (inString || endingString) && !startingString {
				appendingComponent = remainingComponents.removeLast() + " " + appendingComponent
			}

			remainingComponents.append(appendingComponent)
		}

		args = remainingComponents
	}

	public func run() -> (standardOutput: String?, standardError: String?, exitCode: Int) {
		// todo: fix piping tasks along, e.g.: `git diff HEAD | mate` should work
		let task = Process()
		task.launchPath = command
		task.arguments = args

		let standardOutputPipe = Pipe()
		task.standardOutput = standardOutputPipe

		let standardErrorPipe = Pipe()
		task.standardError = standardErrorPipe

		task.launch()
		task.waitUntilExit()

		let standardOutput = String(data: standardOutputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)
		let standardError = String(data: standardErrorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)
		let exitCode = Int(task.terminationStatus)

		return (standardOutput: standardOutput, standardError: standardError, exitCode: exitCode)
	}
}
