// Created by Julian Dunskus

import Foundation

let isOnPart2 = true

final class Unit: ReferenceHashable {
	let team: Team
	var position: Vector2
	var hp = 200
	let attackPower: Int
	
	var isAlive: Bool {
		return hp > 0
	}
	
	init(team: Team, at position: Vector2) {
		self.team = team
		self.position = position
		if isOnPart2 {
			self.attackPower = team == .elves ? 13 : 3
		} else {
			self.attackPower = 3
		}
	}
	
	func distance(to other: Unit) -> Int {
		return position.distance(to: other.position)
	}
}

enum Team: Character, Hashable {
	case goblins = "G"
	case elves = "E"
}

extension Unit: Comparable {
	static func == (lhs: Unit, rhs: Unit) -> Bool {
		return lhs.position == rhs.position
	}
	
	static func < (lhs: Unit, rhs: Unit) -> Bool {
		return lhs.position < rhs.position
	}
}

var units: Set<Unit> = []

enum Space {
	case floor
	case wall
}

let spaces: [[Space]] = input().lines().enumerated().map { y, rawValue in
	rawValue.enumerated().map { x, rawValue in
		switch rawValue {
		case "#":
			return .wall
		case ".":
			return .floor
		default:
			let team = Team(rawValue: rawValue)!
			units.insert(Unit(team: team, at: Vector2(x: x, y: y)))
			return .floor
		}
	}
}

func makePathfindingGrid(for team: Team) -> [[Int]] {
	var grid = Array(repeating: Array(repeating: Int.max, count: spaces.first!.count), count: spaces.count)
	
	let enemyPositions = units.filter { $0.team != team }.map(^\.position)
	enemyPositions.forEach { grid[$0] = 0 }
	
	var toConsider = Set(enemyPositions.flatMap(^\.neighbors))
	
	while let center = toConsider.first {
		toConsider.removeFirst()
		guard spaces[center] == .floor, !units.map(^\.position).contains(center) else { continue }
		
		let neighbors = center.neighbors
		let newValue = neighbors.map { grid[$0] }.min()! + 1
		if newValue < grid[center] {
			grid[center] = newValue
			toConsider.formUnion(neighbors)
		}
	}
	
	return grid
}

extension Unit {
	func attack(_ other: Unit) {
		other.hp -= attackPower
		if !other.isAlive {
			units.remove(other)
		}
	}
	
	func adjacentEnemies() -> Set<Unit> {
		return units.filter { $0.isAlive && $0.team != team && distance(to: $0) == 1 }
	}
	
	func makeTurn() -> Bool {
		guard isAlive else { return true }
		guard units.contains(where: { $0.team != team }) else { return false }
		
		if adjacentEnemies().isEmpty {
			// move
			let grid = makePathfindingGrid(for: team)
			let target = position.neighbors.min { (grid[$0], $0) < (grid[$1], $1) }!
			if grid[target] < Int.max {
				position = target
			}
		}
		
		let target = adjacentEnemies().min { ($0.hp, $0.position) < ($1.hp, $1.position) }
		if let target = target {
			attack(target)
			if isOnPart2, !target.isAlive, target.team == .elves {
				fatalError("an elf died!")
			}
		}
		
		return true
	}
}

func runBattle() -> Int {
	for round in 0... {
		print("round", round, "| remaining total hp:", units.map(^\.hp).sum())
		
		/* debugging output:
		print(units.sorted().map { "\($0.team.rawValue)(\($0.hp))" })
		var grid: [[Character]] = spaces.map { $0.map { $0 == .wall ? "#" : "." } }
		for unit in units {
			grid[unit.position] = unit.team.rawValue
		}
		print(grid.map(String.init(_:)).joined(separator: "\n"))
		print()
		*/
		
		for unit in units.sorted() {
			let shouldContinue = unit.makeTurn()
			guard shouldContinue else { return round }
		}
	}
	fatalError()
}

let roundCount = runBattle()
let remainingHP = units.map(^\.hp).sum()
print(roundCount, "*", remainingHP, "=", roundCount * remainingHP)
