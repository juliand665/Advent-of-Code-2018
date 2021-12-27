// Created by Julian Dunskus

import Foundation

enum Track: Character {
	case topRightCurve = "/"
	case topLeftCurve = "\\"
	case vertical = "|"
	case horizontal = "-"
	case intersection = "+"
}

final class Cart: ReferenceHashable {
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
		return lhs.position < rhs.position
	}
}

var carts: Set<Cart> = []

let spaces: [[Track?]] = input().lines().enumerated().map { y, rawValue in
	rawValue.enumerated().map { x, rawValue in
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
