// Created by Julian Dunskus

import Foundation

struct Parser {
	var input: Substring
	
	init<S>(reading string: S) where S: StringProtocol {
		input = Substring(string)
	}
	
	func next() -> Character? {
		return input.first
	}
	
	private static let numberCharacters = Set("+-0123456789")
	mutating func readInt() -> Int {
		let intPart = input.prefix(while: Parser.numberCharacters.contains)
		input = input[intPart.endIndex...]
		return Int(intPart)!
	}
	
	mutating func tryConsume<S>(_ part: S) -> Bool where S: StringProtocol {
		if input.hasPrefix(part) {
			input.removeFirst(part.count)
			return true
		} else {
			return false
		}
	}
	
	mutating func consume<S>(_ part: S) where S: StringProtocol {
		assert(input.hasPrefix(part))
		input.removeFirst(part.count)
	}
	
	/// - returns: the consumed part, excluding the separator
	@discardableResult mutating func consume(through separator: Character) -> Substring {
		let index = input.firstIndex(of: separator)!
		defer { input = input[index...] }
		return input.prefix(upTo: index)
	}
	
	mutating func consume(while separator: Character) {
		input = input.drop { $0 == separator }
	}
}

protocol Parseable {
	init<S>(rawValue: S) where S: StringProtocol
	init(from parser: inout Parser)
}

extension Parseable {
	init<S>(rawValue: S) where S: StringProtocol {
		var parser = Parser(reading: rawValue)
		self.init(from: &parser)
	}
}

extension Array: Parseable where Element == Int {
	init(from parser: inout Parser) {
		self.init()
		repeat {
			parser.consume(while: " ")
			append(parser.readInt())
		} while parser.tryConsume(",")
	}
}
