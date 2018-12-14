// Created by Julian Dunskus

import Foundation

let playerCount = 424
let turnCount = 71482 * 100 // ×100 for part 2

final class Marble {
	var value: Int
	
	lazy var prev = self
	lazy var next = self
	
	init(value: Int) {
		self.value = value
	}
	
	func insert(after other: Marble) {
		prev = other
		next = other.next
		prev.next = self
		next.prev = self
	}
	
	func remove() {
		prev.next = next
		next.prev = prev
		prev = self
		next = self
	}
}

var current = Marble(value: 0)
var scores = Array(repeating: 0, count: playerCount)
for (player, value) in zip((0..<playerCount).repeated(), 1...turnCount) {
	if value % 23 == 0 {
		scores[player] += value
		current = current.prev.prev.prev.prev.prev.prev // lol
		scores[player] += current.prev.value
		current.prev.remove()
	} else {
		let new = Marble(value: value)
		new.insert(after: current.next)
		current = new
	}
}

print(scores.max()!)
