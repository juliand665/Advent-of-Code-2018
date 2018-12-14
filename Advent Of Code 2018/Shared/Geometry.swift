// Created by Julian Dunskus

import Foundation

struct Vector2: Hashable {
	var x: Int
	var y: Int
	
	static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
		return lhs <- { $0 += rhs }
	}
	
	static func += (lhs: inout Vector2, rhs: Vector2) {
		lhs.x += rhs.x
		lhs.y += rhs.y
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
}

extension Vector2 {
	init(from parser: inout Parser) {
		parser.consume(while: " ")
		x = parser.readInt()
		parser.consume(",")
		parser.consume(while: " ")
		y = parser.readInt()
	}
}
