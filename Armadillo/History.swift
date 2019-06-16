import Foundation

private let HistoryKeyPrefix = "com.nombytes.armadillo.history"
public enum Preferences {
	public enum Location {
		case disk
		case memory

		var keyName: String {
			switch self {
			case .disk: return HistoryKeyPrefix + ".disk"
			case .memory: return HistoryKeyPrefix + ".memory"
			}
		}
	}

	public enum History {
		case commands(Preferences.Location, URL)
		case persists(Preferences.Location, URL)
		case limit(Preferences.Location, URL)

		var keyName: String {
			switch self {
			case .commands(let location, let resourceURL):
				let encoded = resourceURL.absoluteString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) ?? ""
				return location.keyName + ".commands." + encoded
			case .persists(let location, let resourceURL):
				let encoded = resourceURL.absoluteString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) ?? ""
				return location.keyName + ".persists." + encoded
			case .limit(let location, let resourceURL):
				let encoded = resourceURL.absoluteString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) ?? ""
				return location.keyName + ".limit." + encoded
			}
		}

		var defaultValue: AnyObject {
			switch self {
			case .commands(_, _): return [String]() as AnyObject
			case .persists(_, _): return true as AnyObject
			case .limit(_, _): return Int.max as AnyObject
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
	func push(_ command: String)
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

	public func push(_ command: String) {
		var history = self.history
		if history.count + 1 == limit {
			history.removeFirst()
		}

		history.append(command)

		self.history = history
	}
}

open class Memory: History {
	open lazy var history = [String]()
	open lazy var limit: Int = Preferences.History.limit(.memory, Bundle.main.bundleURL).defaultValue as! Int
	open lazy var persists: Bool = Preferences.History.persists(.memory, Bundle.main.bundleURL).defaultValue as! Bool
}

open class Disk<D: Defaults>: History {
	let resourceURL: URL

	init(resourceURL: URL) {
		self.resourceURL = resourceURL
	}

	open var history: [String] {
		get {
			let command = Preferences.History.commands(.disk, resourceURL)
			D.provider.register(defaults: [command.keyName: command.defaultValue])
			return D.provider.object(forKey: command.keyName) as! [String]
		} set {
			guard persists else { return }

			let command = Preferences.History.commands(.disk, resourceURL)
			D.provider.set(newValue, forKey: command.keyName)
		}
	}

	open var limit: Int {
		get {
			let command = Preferences.History.limit(.disk, resourceURL)
			D.provider.register(defaults: [command.keyName: command.defaultValue])
			return D.provider.integer(forKey: command.keyName)
		} set {
			let command = Preferences.History.limit(.disk, resourceURL)
			D.provider.set(newValue, forKey: command.keyName)
		}
	}

	open var persists: Bool {
		get {
			let command = Preferences.History.persists(.disk, resourceURL)
			D.provider.register(defaults: [command.keyName: command.defaultValue])
			return D.provider.bool(forKey: command.keyName)
		} set {
			let command = Preferences.History.persists(.disk, resourceURL)
			D.provider.set(newValue, forKey: command.keyName)

			if !newValue {
				D.provider.removeObject(forKey: command.keyName)
			}
		}
	}
}
