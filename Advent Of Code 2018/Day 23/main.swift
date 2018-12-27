// Created by Julian Dunskus

import Foundation

struct Vector3 {
	var x, y, z: Int
}

extension Vector3 {
	func distance(to other: Vector3) -> Int {
		return abs(x - other.x) + abs(y - other.y) + abs(z - other.z)
	}
}

extension Vector3: Parseable {
	init(from parser: inout Parser) {
		x = parser.readInt()
		parser.consume(",")
		y = parser.readInt()
		parser.consume(",")
		z = parser.readInt()
	}
}

struct Nanobot {
	var position: Vector3
	var range: Int
}

extension Nanobot: Parseable {
	init(from parser: inout Parser) {
		parser.consume("pos=<")
		position = .init(from: &parser)
		parser.consume(">, r=")
		range = parser.readInt()
	}
}

let bots = input().lines().map(Nanobot.init)
let strongestBot = bots.max { $0.range < $1.range }!
let botsInRange = bots.count { $0.position.distance(to: strongestBot.position) <= strongestBot.range }
print(botsInRange)
