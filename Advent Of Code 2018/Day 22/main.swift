// Created by Julian Dunskus

import Foundation

let depth = 3198
let target = Vector2(12, 757)

enum RegionType: Int, CaseIterable {
	case rocky = 0
	case wet = 1
	case narrow = 2
	
	init(erosionLevel: Int) {
		self.init(rawValue: erosionLevel % 3)!
	}
}

extension RegionType: CustomStringConvertible {
	var description: String {
		switch self {
		case .rocky:
			return "."
		case .wet:
			return "="
		case .narrow:
			return "|"
		}
	}
}

enum Tool: Int, CaseIterable {
	case torch
	case climbingGear
	case neither
}

let width = target.x + 3
let height = target.y + 3
var erosionLevels = Array(repeating: Array(repeating: 0, count: width), count: height)

func geologicIndex(at pos: Vector2) -> Int {
	if pos == Vector2(0, 0) || pos == target {
		return 0
	} else if pos.x == 0 {
		return pos.y * 48271
	} else if pos.y == 0 {
		return pos.x * 16807
	} else {
		return erosionLevels[pos <- { $0.x -= 1 }] * erosionLevels[pos <- { $0.y -= 1 }]
	}
}

func erosionLevel(at pos: Vector2) -> Int {
	return (geologicIndex(at: pos) + depth) % 20183
}

let positions = (0..<height).lazy.flatMap { y in (0..<width).map { x in Vector2(x, y) } }
for pos in positions {
	erosionLevels[pos] = erosionLevel(at: pos)
}

let regions = erosionLevels.map { $0.map(RegionType.init) }
//print(regions.map { $0.map(^\.description).joined() }.joined(separator: "\n"))

let riskLevel = regions.joined().map(^\.rawValue).sum()
print(riskLevel)

let switchTime = 7


