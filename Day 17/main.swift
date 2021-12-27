// Created by Julian Dunskus

import Foundation

struct Component: Parseable {
	let xRange: ClosedRange<Int>
	let yRange: ClosedRange<Int>
	
	init(from parser: inout Parser) {
		let first = parser.next()!
		parser.consume(through: "=")
		let x = parser.readInt()
		parser.consume(through: "=")
		let y1 = parser.readInt()
		parser.consume("..")
		let y2 = parser.readInt()
		
		if first == "x" {
			xRange = x...x
			yRange = y1...y2
		} else {
			yRange = x...x
			xRange = y1...y2
		}
	}
}

enum Space: Character {
	case empty = " ", wall = "#", stationaryWater = "~", flowingWater = "|"
	
	var isWater: Bool {
		switch self {
		case .empty, .wall:
			return false
		case .stationaryWater, .flowingWater:
			return true
		}
	}
}

let components = input().lines().map(Component.init)

let minX = components.map { $0.xRange.lowerBound }.min()!
let maxX = components.map { $0.xRange.upperBound }.max()!
let width = maxX + 2

let minY = components.map { $0.yRange.lowerBound }.min()!
let maxY = components.map { $0.yRange.upperBound }.max()!
let height = maxY + 1

var grid = Array(repeating: Array(repeating: Space.empty, count: width), count: height) <- {
	for component in components {
		for x in component.xRange {
			for y in component.yRange {
				$0[y][x] = .wall
			}
		}
	}
}

//print(grid.map { String($0.dropFirst(minX - 1).map { $0.rawValue }) }.joined(separator: "\n"))

/// - returns: whether or not to spill out
func fill(from position: Vector2 = Vector2(500, minY)) -> Bool {
	guard position.y < height else { return false }
	
	switch grid[position] {
	case .wall, .stationaryWater:
		return true
	case .flowingWater:
		return false
	case .empty:
		let shouldSpill = fill(from: position <- { $0.y += 1 })
		if shouldSpill {
			var hasSpilled = false
			
			var leftmost = position.x
			var rightmost = position.x
			
			// left
			for x in (0..<position.x).reversed() {
				let pos = Vector2(x, position.y)
				guard grid[pos] == .empty else { break }
				
				leftmost = x
				guard fill(from: Vector2(x, position.y + 1)) else {
					hasSpilled = true
					break
				}
			}
			
			// right
			for x in position.x..<width {
				let pos = Vector2(x, position.y)
				guard grid[pos] == .empty else { break }
				
				rightmost = x
				guard fill(from: Vector2(x, position.y + 1)) else {
					hasSpilled = true
					break
				}
			}
			
			for x in leftmost...rightmost {
				grid[Vector2(x, position.y)] = hasSpilled ? .flowingWater : .stationaryWater
			}
			
			return !hasSpilled
		} else {
			grid[position] = .flowingWater
			return false
		}
	}
}

_ = fill()

print(grid.map { String($0.dropFirst(minX - 1).map { $0.rawValue }) }.joined(separator: "\n"))

let waterCount = grid.dropFirst(minY).lazy.map { $0.dropFirst(minX - 1).count { $0.isWater } }.reduce(0, +)
print("reachable tiles:", waterCount)

let stationaryWaterCount = grid.dropFirst(minY).lazy.map { $0.dropFirst(minX - 1).count { $0 == .stationaryWater } }.reduce(0, +)
print("filled tiles:", stationaryWaterCount)
