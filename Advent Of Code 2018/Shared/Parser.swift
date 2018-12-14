// Created by Julian Dunskus

import Foundation

struct Parser {
	var input: Substring
	
	init<S>(reading string: S) where S: StringProtocol {
		input = Substring(string)
	}
	
	private static let numberCharacters = Set("+-0123456789")
	mutating func readInt() -> Int {
		let intPart = input.prefix(while: Parser.numberCharacters.contains)
		input = input[intPart.endIndex...]
		return Int(intPart)!
	}
	
	mutating func consume<S>(_ part: S) where S: StringProtocol {
		assert(input.hasPrefix(part))
		input.removeFirst(part.count)
	}
	
	mutating func consume(through separator: Character) {
		input = input.drop { $0 != separator }
		consume(String(separator))
	}
	
	mutating func consume(while separator: Character) {
		input = input.drop { $0 == separator }
	}
}
