import Foundation

extension NSTask {
	public static func which(cmd: String) -> String? {
		let task = NSTask()
		task.launchPath = "/usr/bin/which"
		task.arguments = [ cmd ]

		let pipe = NSPipe()
		task.standardOutput = pipe

		task.launch()
		task.waitUntilExit()

		let repl = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)!
		return repl.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
	}
}
