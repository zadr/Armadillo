#if os(Linux) || os(FreeBSD)
import Glibc
#else
import Foundation
#endif

public protocol ArgumentValue {}

extension String: ArgumentValue {}
extension Int: ArgumentValue {}
extension Double: ArgumentValue {}
extension Bool: ArgumentValue {}

public protocol ArgumentProvider {
	func value(forArgument name: String) -> ArgumentValue?
}

#if os(Linux) || os(FreeBSD)
public final class POSIXArgumentParser: ArgumentProvider {
	public func value(forArgument name: String) -> ArgumentValue? {
		return nil // todo; getopt_long?
	}
}
#else
public let argumentProvider = UserDefaults.standard

extension UserDefaults: ArgumentProvider {
	public func value(forArgument name: String) -> ArgumentValue? {
		let value = object(forKey: name)
		switch value {
		case let value as String: return value
		case let value as Int: return value
		case let value as Double: return value
		case let value as Bool: return value
		default: return nil
		}
	}
}
#endif
