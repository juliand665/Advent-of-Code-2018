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
	
	func isValid(for region: RegionType) -> Bool {
		switch self {
		case .torch:
			return region != .wet
		case .climbingGear:
			return region != .narrow
		case .neither:
			return region != .rocky
		}
	}
}

let width = target.x + 50
let height = target.y + 50
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
print("risk level:", riskLevel)

let switchTime = 7

struct Investigation: Hashable {
	var tool: Tool
	var position: Vector2
}

let empty = Array(repeating: Array(repeating: Int.max, count: width), count: height)
var bestTimes: [[[Int]]] = Array(repeating: empty, count: Tool.allCases.count)

bestTimes[Tool.torch.rawValue][Vector2.zero] = 0
var toInvestigate = [Investigation(tool: .torch, position: .zero)][...]
while !toInvestigate.isEmpty {
	let investigation = toInvestigate.removeFirst()
	let time = bestTimes[investigation.tool.rawValue][investigation.position]
	let region = regions[investigation.position]
	
	for neighbor in investigation.position.neighbors {
		guard let previous = bestTimes[investigation.tool.rawValue].element(at: neighbor) else { continue }
		guard investigation.tool.isValid(for: regions[neighbor]) else { continue }
		
		if time + 1 < previous {
			bestTimes[investigation.tool.rawValue][neighbor] = time + 1
			toInvestigate.append(investigation <- { $0.position = neighbor })
		}
	}
	
	for tool in Tool.allCases where tool != investigation.tool && tool.isValid(for: region) {
		if time + 7 < bestTimes[tool.rawValue][investigation.position] {
			bestTimes[tool.rawValue][investigation.position] = time + 7
			toInvestigate.append(investigation <- { $0.tool = tool })
		}
	}
}

print("best time to reach target with torch:", bestTimes[Tool.torch.rawValue][target])
