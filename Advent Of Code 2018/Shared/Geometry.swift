// Created by Julian Dunskus

import Foundation

struct Vector2: Hashable {
	var x: Int
	var y: Int
	
	var absolute: Int {
		return abs(x) + abs(y)
	}
	
	var neighbors: [Vector2] {
		return Direction.allCases.map { self + $0.offset }
	}
	
	static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
		return lhs <- { $0 += rhs }
	}
	
	static func += (lhs: inout Vector2, rhs: Vector2) {
		lhs.x += rhs.x
		lhs.y += rhs.y
	}
	
	static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
		return lhs <- { $0 -= rhs }
	}
	
	static func -= (lhs: inout Vector2, rhs: Vector2) {
		lhs.x -= rhs.x
		lhs.y -= rhs.y
	}
	
	static func * (vec: Vector2, scale: Int) -> Vector2 {
		return vec <- { $0 *= scale }
	}
	
	static func * (scale: Int, vec: Vector2) -> Vector2 {
		return vec <- { $0 *= scale }
	}
	
	static func *= (vec: inout Vector2, scale: Int) {
		vec.x *= scale
		vec.y *= scale
	}
	
	func distance(to other: Vector2) -> Int {
		return (self - other).absolute
	}
}

extension Vector2: Comparable {
	static func < (lhs: Vector2, rhs: Vector2) -> Bool {
		return (lhs.y, lhs.x) < (rhs.y, rhs.x)
	}
}

extension Vector2: Parseable {
	init(from parser: inout Parser) {
		parser.consume(while: " ")
		x = parser.readInt()
		parser.consume(",")
		parser.consume(while: " ")
		y = parser.readInt()
	}
}

enum Direction: Character, CaseIterable {
	case up = "^"
	case right = ">"
	case down = "v"
	case left = "<"
	
	var offset: Vector2 {
		switch self {
		case .up:
			return Vector2(x: 0, y: -1)
		case .right:
			return Vector2(x: +1, y: 0)
		case .down:
			return Vector2(x: 0, y: +1)
		case .left:
			return Vector2(x: -1, y: 0)
		}
	}
	
	func rotated(by diff: Int) -> Direction {
		return Direction.allCases[(Direction.allCases.firstIndex(of: self)! + diff) & 0b11]
	}
}
