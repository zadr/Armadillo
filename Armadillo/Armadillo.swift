import Foundation

public final class Armadillo {
	func run(_ argParser: ArgumentProvider) {
		let fileManager = FileManager()
		let path: String = argParser.value(forArgument: "path") as? String ?? fileManager.currentDirectoryPath
		let url = URL(fileURLWithPath: path)
		fileManager.changeCurrentDirectoryPath(path)

		guard let repl: REPL = {
			if let name = argParser.value(forArgument: "cmd") as? String {
				return REPL.repl(for: name)
			}

			return REPL.repl(for: url)
		}() else { exit(1) }

		var history = [String]()
		var historyIndex: Array<String>.Index? = nil

		guard let cmdPath = Process.which(repl.binary) else { return }
		let workingDir = url.lastPathComponent
		let input = Input()

		while true {
			FileHandle.standardOutput.write("\(workingDir) % \(repl.binary) ".data(using: .utf8)!)

			let commandSuffix: String?

			switch input.read() {
			case .text(let data):
				if data.isEmpty {
					commandSuffix = history.last
				} else {
					commandSuffix = String(bytes: data, encoding: .utf8)
					history.append(commandSuffix!)
				}
				break
			case .arrowKey(let arrowKey):
				switch arrowKey {
				case .up:
					if !history.isEmpty {
						if historyIndex == nil {
							historyIndex = history.endIndex
						} else if historyIndex != history.startIndex {
							historyIndex = history.index(before: historyIndex!)
						} else {
							historyIndex = nil
						}
					}

					if let index = historyIndex {
						commandSuffix = history[history.index(before: index)]
					} else {
						commandSuffix = nil
					}
				case .down:
					if !history.isEmpty {
						if historyIndex == nil {
							// nothing to do
						} else if historyIndex != history.endIndex {
							historyIndex = history.index(after: historyIndex!)
						} else {
							historyIndex = nil
						}
					}

					if let index = historyIndex {
						commandSuffix = history[history.index(after: index)]
					} else {
						commandSuffix = nil
					}
				default:
					commandSuffix = nil
					break
				}
				break
			}

			historyIndex = nil

			guard let suffix = commandSuffix else {
				continue
			}

			guard let command = Command(raw: cmdPath + " " + suffix) else {
				continue
			}

			let status = command.run()

			if let err = status.standardError, !err.isEmpty {
				print(err)
			} else if let out = status.standardOutput , !out.isEmpty {
				print(out)
			}
		}
	}
}
