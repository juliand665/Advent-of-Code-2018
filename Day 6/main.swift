// Created by Julian Dunskus

import Foundation

let points = input().lines().map(Vector2.init)
print("parsed")

let maxX = points.map(^\.x).max()!
let maxY = points.map(^\.y).max()!
print("maxes")

let positions = (0...maxX).flatMap { x in
	(0...maxY).map { y in
		Vector2(x: x, y: y)
	}
}
print("positions")

let pointDistances: [(position: Vector2, distances: [Int])] = positions.map { pos in
	(pos, points.map { $0.distance(to: pos) })
}
print("distances")

let closestPoints: [(position: Vector2, closestPoint: Int?)] = pointDistances.map { pos, distances in
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
