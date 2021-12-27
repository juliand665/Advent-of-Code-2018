// Created by Julian Dunskus

import Foundation

final class Star {
	var position: Vector2
	var velocity: Vector2
	
	init(raw: Substring) {
		var parser = Parser(reading: raw)
		parser.consume(through: "<")
		position = Vector2(from: &parser)
		parser.consume(through: "<")
		velocity = Vector2(from: &parser)
	}
	
	func position(at time: Int) -> Vector2 {
		return position + velocity * time
	}
}

let stars = input().lines().map(Star.init)

func showStars(at time: Int) {
	print()
	print("stars at", time)
	
	let positions = stars.map { $0.position(at: time) }
	let minX = positions.map(^\.x).min()!
	let maxX = positions.map(^\.x).max()!
	let minY = positions.map(^\.y).min()!
	let maxY = positions.map(^\.y).max()!
	
	var bitmap = Array(repeating: Array(repeating: false, count: maxX - minX + 1), count: maxY - minY + 1)
	for position in positions {
		bitmap[position.y - minY][position.x - minX] = true
	}
	
	for rawLine in bitmap {
		print(String(rawLine.map { $0 ? "#" : "." }))
	}
}

let mins = stars.flatMap {
	[-$0.position.x / $0.velocity.x, -$0.position.y / $0.velocity.y]
}

let targetTime = mins.sum() / mins.count
print("min time:", targetTime)
(targetTime - 3...targetTime + 3).forEach(showStars)
