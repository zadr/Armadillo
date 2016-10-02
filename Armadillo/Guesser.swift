import Foundation

public struct REPL {
	public private(set) var binary: String
	public private(set) var args: [String]
	public private(set) var failureExitStatus: Int
	public private(set) var directoryName: String?
	public private(set) var checksForDirectory: Bool

	private static var knownREPLs: [KnownREPL] {
		return [ .mercurial, .subversion, .git ]
	}

	public static func repl(for name: String) -> REPL? {
		let matching = knownREPLs.filter {
			return $0.binary == name
		}

		guard let knownREPL = matching.first else {
			return REPL(binary: name, args: [], failureExitStatus: 0, directoryName: nil, checksForDirectory: false)
		}

		return REPL(binary: knownREPL.binary, args: knownREPL.args, failureExitStatus: knownREPL.failureExitStatus, directoryName: knownREPL.directoryName, checksForDirectory: knownREPL.checksForDirectory)
	}

	public static func repl(for directory: URL) -> REPL? {
		for p in knownREPLs {
			if p.checksForDirectory {
				let REPLDirectory = directory.appendingPathComponent(p.directoryName!)
				if FileManager().fileExists(atPath: REPLDirectory.absoluteString) {
					return REPL(binary: p.binary, args: p.args, failureExitStatus: p.failureExitStatus, directoryName: p.directoryName, checksForDirectory: p.checksForDirectory)
				}
			} else {
				let task = Process()
				task.launchPath = Process.which(p.binary)
				task.arguments = p.args

				let pipe = Pipe()
				task.standardOutput = pipe
				task.standardError = Pipe()

				task.launch()
				task.waitUntilExit()

				if Int(task.terminationStatus) != p.failureExitStatus {
					return REPL(binary: p.binary, args: p.args, failureExitStatus: p.failureExitStatus, directoryName: p.directoryName, checksForDirectory: p.checksForDirectory)
				}
			}
		}

		return nil
	}
}

fileprivate enum KnownREPL {
	case mercurial
	case subversion
	case git

	fileprivate var binary: String {
		switch self {
		case .mercurial: return "hg"
		case .subversion: return "svn"
		case .git: return "git"
		}
	}

	fileprivate var args: [String] {
		switch self {
		case .mercurial: return [ "status" ]
		case .subversion: return [ "status" ]
		case .git: return [ "status" ]
		}
	}

	fileprivate var failureExitStatus: Int {
		switch self {
		case .mercurial: return 255
		case .subversion: return 0
		case .git: return 128
		}
	}

	fileprivate var directoryName: String? {
		switch self {
		case .mercurial: return ".hg"
		case .subversion: return ".svn"
		case .git: return ".git"
		}
	}

	fileprivate var checksForDirectory: Bool {
		return self == .subversion
	}
}
