//
//  Input.swift
//  Armadillo
//
//  Created by z on 6/16/19.
//

import Foundation

public enum ArrowKeys {
	case up
	case down
	case left
	case right

	fileprivate var value: [UInt8] {
		switch self {
		case .up:
			return [ 0x1b, 0x5b, 0x41 ]

		case .down:
			return [ 0x1b, 0x5b, 0x42 ]

		case .right:
			return [ 0x1b, 0x5b, 0x43 ]

		case .left:
			return [ 0x1b, 0x5b, 0x44 ]
		}
	}
}

public final class Input {
	public enum Event {
		case text(Data)
		case arrowKey(ArrowKeys)
	}

	public func read(until terminator: Data = Data(bytes: [ 0xA ] , count: 1)) -> Input.Event {
		var entered = Data()
		var ignoreNextTerminator = false
		while true {
			entered.append(FileHandle.standardInput.readData(ofLength: 1))

			if entered.count >= terminator.count && entered.suffix(terminator.count) == terminator {
				if ignoreNextTerminator {
					entered.removeLast(terminator.count)
					ignoreNextTerminator = false
					continue
				}

				let data = entered.subdata(in: entered.startIndex ..< entered.index(entered.endIndex, offsetBy: -terminator.count))
				return .text(data)
			}

			if entered.count >= 3 {
				switch Array<UInt8>(entered.suffix(3)) {
				case ArrowKeys.up.value:
					ignoreNextTerminator = true
					return .arrowKey(.up)
				case ArrowKeys.down.value:
					ignoreNextTerminator = true
					return .arrowKey(.down)
				case ArrowKeys.right.value:
					ignoreNextTerminator = true
					return .arrowKey(.right)
				case ArrowKeys.left.value:
					ignoreNextTerminator = true
					return .arrowKey(.left)
				default:
					break
				}
			}
		}

		fatalError()
	}
}
