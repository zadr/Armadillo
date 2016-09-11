import Foundation

private let HistoryKeyPrefix = "com.nombytes.armadillo.history"
public enum Preferences {
	public enum Location {
		case disk
		case memory

		var keyName: String {
			switch self {
			case disk: return HistoryKeyPrefix + ".disk"
			case memory: return HistoryKeyPrefix + ".memory"
			}
		}
	}

	public enum History {
		case commands(Preferences.Location, NSURL)
		case persists(Preferences.Location, NSURL)
		case limit(Preferences.Location, NSURL)

		var keyName: String {
			switch self {
			case .commands(let location, let resourceURL):
				let encoded = resourceURL.absoluteString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet()) ?? ""
				return location.keyName + ".commands." + encoded
			case .persists(let location, let resourceURL):
				let encoded = resourceURL.absoluteString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet()) ?? ""
				return location.keyName + ".persists." + encoded
			case .limit(let location, let resourceURL):
				let encoded = resourceURL.absoluteString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet()) ?? ""
				return location.keyName + ".limit." + encoded
			}
		}

		var defaultValue: AnyObject {
			switch self {
			case .commands(_, _): return [String]()
			case .persists(_, _): return true
			case .limit(_, _): return Int.max
			}
		}
	}
}

public protocol History: class {
	var history: [String] { get set }
	var limit: Int { get set }
	var persists: Bool { get set }

	func peekLastCommand() -> String?
	func popLastCommand() -> String?
	func push(command: String)
}

extension History {
	public func peekLastCommand() -> String? {
		return self.history.last
	}

	public func popLastCommand() -> String? {
		var history = self.history
		let element = history.popLast()
		self.history = history
		return element
	}

	public func push(command: String) {
		var history = self.history
		if history.count + 1 == limit {
			history.removeFirst()
		}

		history.append(command)

		self.history = history
	}
}

public class Memory: History {
	public lazy var history = [String]()
	public lazy var limit: Int = Preferences.History.limit(.memory, NSBundle.mainBundle().bundleURL).defaultValue as! Int
	public lazy var persists: Bool = Preferences.History.persists(.memory, NSBundle.mainBundle().bundleURL).defaultValue as! Bool
}

public class Disk<D: Defaults>: History {
	public let resourceURL: NSURL

	init(resourceURL: NSURL) {
		self.resourceURL = resourceURL
	}

	public var history: [String] {
		get {
			let command = Preferences.History.commands(.disk, resourceURL)
			D.defaultsProvider().registerDefaults([command.keyName: command.defaultValue])
			return D.defaultsProvider().objectForKey(command.keyName) as! [String]
		} set {
			guard persists else { return }

			let command = Preferences.History.commands(.disk, resourceURL)
			D.defaultsProvider().setObject(newValue, forKey: command.keyName)
		}
	}

	public var limit: Int {
		get {
			let command = Preferences.History.limit(.disk, resourceURL)
			D.defaultsProvider().registerDefaults([command.keyName: command.defaultValue])
			return D.defaultsProvider().integerForKey(command.keyName)
		} set {
			let command = Preferences.History.limit(.disk, resourceURL)
			D.defaultsProvider().setInteger(newValue, forKey: command.keyName)
		}
	}

	public var persists: Bool {
		get {
			let command = Preferences.History.persists(.disk, resourceURL)
			D.defaultsProvider().registerDefaults([command.keyName: command.defaultValue])
			return D.defaultsProvider().boolForKey(command.keyName)
		} set {
			let command = Preferences.History.persists(.disk, resourceURL)
			D.defaultsProvider().setBool(newValue, forKey: command.keyName)

			if !newValue {
				D.defaultsProvider().removeObjectForKey(command.keyName)
			}
		}
	}
}
