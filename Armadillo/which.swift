import Foundation

extension Process {
	public static func which(_ cmd: String) -> String? {
		let task = Process()
		task.launchPath = "/usr/bin/which"
		task.arguments = [ cmd ]

		let pipe = Pipe()
		task.standardOutput = pipe

		task.launch()
		task.waitUntilExit()

		let repl = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)!
		return repl.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}
}
