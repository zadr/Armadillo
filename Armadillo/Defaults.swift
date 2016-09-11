#if os(Linux) || os(FreeBSD)
import Glibc
#else
import Foundation
#endif

public protocol Defaults {
	func registerDefaults(registrationDictionary: [String : AnyObject])

	func objectForKey(defaultName: String) -> AnyObject?
	func integerForKey(defaultName: String) -> Int
	func floatForKey(defaultName: String) -> Float
	func doubleForKey(defaultName: String) -> Double
	func boolForKey(defaultName: String) -> Bool

	func setObject(value: AnyObject?, forKey defaultName: String)
	func setInteger(value: Int, forKey defaultName: String)
	func setFloat(value: Float, forKey defaultName: String)
	func setDouble(value: Double, forKey defaultName: String)
	func setBool(value: Bool, forKey defaultName: String)

	func removeObjectForKey(defaultName: String)

	static func defaultsProvider() -> Defaults
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
extension NSUserDefaults: Defaults {
	public static func defaultsProvider() -> Defaults {
		return NSUserDefaults.standardUserDefaults()
	}
}
#endif
