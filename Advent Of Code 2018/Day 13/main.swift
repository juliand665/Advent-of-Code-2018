// Created by Julian Dunskus

import Foundation

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

enum Track: Character {
	case topRightCurve = "/"
	case topLeftCurve = "\\"
	case vertical = "|"
	case horizontal = "-"
	case intersection = "+"
}

final class Cart {
	var position: Vector2
	var direction: Direction
	var nextIntersectionChoice = -1
	
	init?(rawValue: Character, at position: Vector2) {
		guard let direction = Direction(rawValue: rawValue) else { return nil }
		self.direction = direction
		self.position = position
	}
	
	func traverse(_ track: Track) {
		switch track {
		case .topRightCurve:
			switch direction {
			case .up: direction = .right
			case .right: direction = .up
			case .down: direction = .left
			case .left: direction = .down
			}
		case .topLeftCurve:
			switch direction {
			case .up: direction = .left
			case .left: direction = .up
			case .down: direction = .right
			case .right: direction = .down
			}
		case .vertical, .horizontal:
			break
		case .intersection:
			defer { nextIntersectionChoice = (nextIntersectionChoice + 2) % 3 - 1 }
			direction = direction.rotated(by: nextIntersectionChoice)
		}
		position += direction.offset
	}
}

extension Cart: Comparable {
	static func == (lhs: Cart, rhs: Cart) -> Bool {
		return lhs.position == rhs.position
	}
	
	static func < (lhs: Cart, rhs: Cart) -> Bool {
		return (lhs.position.y, lhs.position.x) < (rhs.position.y, rhs.position.x)
	}
}

extension Cart: Hashable {
	func hash(into hasher: inout Hasher) {
		withUnsafePointer(to: self) {
			hasher.combine(bytes: UnsafeRawBufferPointer(start: $0, count: MemoryLayout<Cart>.size))
		}
	}
}

var carts: Set<Cart> = []

let spaces: [[Track?]] = input().lines().enumerated().map { y, rawValue in
	return rawValue.enumerated().map { x, rawValue in
		if let track = Track(rawValue: rawValue) {
			return track
		} else if let cart = Cart(rawValue: rawValue, at: Vector2(x: x, y: y)) {
			carts.insert(cart)
			switch cart.direction {
			case .up, .down:
				return .vertical
			case .left, .right:
				return .horizontal
			}
		} else {
			assert(rawValue == " ")
			return nil
		}
	}
}

while carts.count > 1 {
	for cart in carts.sorted() {
		cart.traverse(spaces[cart.position]!)
		if let other = carts.first(where: { $0 !== cart && $0.position == cart.position }) {
			print("crash at", cart.position)
			carts.remove(cart)
			carts.remove(other)
		}
	}
}
print("final cart:", carts.first!.position)
