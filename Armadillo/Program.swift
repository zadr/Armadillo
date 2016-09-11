import Foundation

public final class Program<D: Defaults> {
	func run(argParser: ArgumentProvider) {
		let fileManager = NSFileManager()
		let path: String = argParser.value(forArgument: "path") as? String ?? fileManager.currentDirectoryPath
		let url = NSURL(fileURLWithPath: path)
		fileManager.changeCurrentDirectoryPath(path)

		guard let repl: REPL = {
			if let name = argParser.value(forArgument: "cmd") as? String {
				return REPL.repl(for: name)
			}

			return REPL.repl(for: url)
		}() else { exit(1) }

		let history: [History] = [
			Disk<D>(resourceURL: url),
			Memory()
		]

		guard let cmdPath = NSTask.which(repl.binary) else { return }
		guard let workingDir = url.lastPathComponent else { return }

		while true {
			print("\(workingDir) % \(repl.binary) ", terminator: "")

			guard let command = Command(raw: cmdPath + " " + {
				// todo: stop using readLine() and move to something like `libedit`
				// which gives us support for handling arrow key events
				if let input = readLine() where !input.characters.isEmpty {
					history.forEach {
						$0.push(input)
					}

					return input
				} else if let input = history.last?.peekLastCommand() {
					return input
				} else { return "" }
			}()) else { continue }

			let status = command.run()

			if let err = status.standardError where !err.isEmpty {
				print(err)
			} else if let out = status.standardOutput where !out.isEmpty {
				print(out)
			}
		}
	}
}
