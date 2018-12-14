// Created by Julian Dunskus

import Foundation

struct Point: Hashable {
	var x: Int
	var y: Int
	
	func distance(to other: Point) -> Int {
		return abs(x - other.x) + abs(y - other.y)
	}
}

extension Point {
	init<S>(raw: S) where S: StringProtocol {
		var parser = Parser(reading: raw)
		x = parser.readInt()
		parser.consume(", ")
		y = parser.readInt()
	}
}

let points = input().lines().map(Point.init)
print("parsed")

let maxX = points.map(^\.x).max()!
let maxY = points.map(^\.y).max()!
print("maxes")

let positions = (0...maxX).flatMap { x in
	(0...maxY).map { y in
		Point(x: x, y: y)
	}
}
print("positions")

let pointDistances: [(position: Point, distances: [Int])] = positions.map { pos in
	(pos, points.map { $0.distance(to: pos) })
}
print("distances")

let closestPoints: [(position: Point, closestPoint: Int?)] = pointDistances.map { pos, distances in
	let min = distances.min()!
	if distances.count(of: min) == 1 {
		return (pos, distances.firstIndex(of: min)!)
	} else {
		return (pos, nil)
	}
}
print("closest")

var areaSizes = Dictionary(grouping: closestPoints.compactMap { $0.closestPoint }, by: { $0 })
	.mapValues(^\.count)
print("sizes")

closestPoints
	.filter { $0.position.x == 0 || $0.position.x == maxX || $0.position.y == 0 || $0.position.y == maxY }
	.compactMap { $0.closestPoint }
	.forEach { areaSizes.removeValue(forKey: $0) }
print("filtered")

print(areaSizes.max { $0.value < $1.value }!)

let centralAreaSize = pointDistances
	.count { $0.distances.sum() < 10_000 }
print(centralAreaSize)
