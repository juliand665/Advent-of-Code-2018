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
print("bots in range:", botsInRange)

// MARK: -

struct Endpoint {
	var position: Int
	var kind: Kind
	
	enum Kind {
		case lower, upper
	}
}

func rangeEndpoints(in component: (Nanobot) -> Int) -> [Endpoint] {
	[]
		+ bots.map { Endpoint(position: component($0) - $0.range, kind: .lower) }
		+ bots.map { Endpoint(position: component($0) + $0.range, kind: .upper) }
}

struct Overlap {
	var range: ClosedRange<Int>
	var count: Int
	
	func distance(to point: Int) -> Int {
		if range.contains(point) {
			return 0
		} else {
			return min(
				abs(point - range.lowerBound),
				abs(point - range.upperBound)
			)
		}
	}
}

func sortedOverlaps(in component: (Nanobot) -> Int) -> [Overlap] {
	let endpoints = rangeEndpoints(in: component).sorted(on: ^\.position)
	
	var overlaps: [Overlap] = []
	var level = 0
	for (start, end) in zip(endpoints, endpoints.dropFirst()) {
		switch start.kind {
		case .lower:
			level += 1
		case .upper:
			level -= 1
		}
		
		overlaps.append(Overlap(range: start.position...end.position, count: level))
	}
	assert(level == 1)
	
	return overlaps
		.sorted { $0.count }
		.reversed() // best first
}

func distanceToClosestPosition(in overlaps: [Overlap]) -> Int {
	return overlaps
		.map { $0.distance(to: 0) }
		.min()!
}

// this componentwise approach doesn't work because distance to a nanobot (and thus whether or not you're in range) depends on all 3 dimensions…
let components = [\Nanobot.position.x, \.position.y, \.position.z]
let overlapsByComponent = components
	.map(^)
	.map(sortedOverlaps(in:))

let targetCount = overlapsByComponent
	.map { $0.first!.count }
	.min()!

print("best possible count:", targetCount)

let distance = overlapsByComponent
	.map({ $0
		.filter { $0.count >= targetCount }
		.map { $0.distance(to: 0) }
		.min()!
	})
	.reduce(0, +)
print("distance to closest optimal point:", distance)
