#if os(Linux) || os(FreeBSD)
import Glibc
#else
import Foundation
#endif

public protocol Defaults {
	func register(defaults registrationDictionary: [String : Any])

	func object(forKey defaultName: String) -> Any?
	func set(_ value: Any?, forKey defaultName: String)

	func integer(forKey defaultName: String) -> Int
	func float(forKey defaultName: String) -> Float
	func double(forKey defaultName: String) -> Double
	func bool(forKey defaultName: String) -> Bool

	func set(_ value: Int, forKey defaultName: String)
	func set(_ value: Float, forKey defaultName: String)
	func set(_ value: Double, forKey defaultName: String)
	func set(_ value: Bool, forKey defaultName: String)

	func removeObject(forKey defaultName: String)

	static var provider: Defaults { get }
}

#if os(Linux) || os(FreeBSD)
public final class POSIXUserDefaults: Defaults {
	private let settingsProvider = POSIXUserDefaults()

	public static func defaultsProvider() -> Defaults { return settingsProvider }

	public func objectForKey(defaultName: String) -> AnyObject? { /* todo */ }
	public func integerForKey(defaultName: String) -> Int { /* todo */ }
	public func floatForKey(defaultName: String) -> Float { /* todo */ }
	public func doubleForKey(defaultName: String) -> Double { /* todo */ }
	public func boolForKey(defaultName: String) -> Bool { /* todo */ }

	public func setObject(value: AnyObject?, forKey defaultName: String) { /* todo */ }
	public func setInteger(value: Int, forKey defaultName: String) { /* todo */ }
	public func setFloat(value: Float, forKey defaultName: String) { /* todo */ }
	public func setDouble(value: Double, forKey defaultName: String) { /* todo */ }
	public func setBool(value: Bool, forKey defaultName: String) { /* todo */ }

	public func removeObjectForKey(defaultName: String) { /* todo */ }
}
#else
extension UserDefaults: Defaults {
	public static var provider: Defaults {
		return UserDefaults.standard
	}
}
#endif
