// Created by Julian Dunskus

import AoC_Helpers
import SimpleParser
import HandyOperators

struct Nanobot {
	var position: Vector3
	var range: Int
	
	var cuboid: Cuboid {
		.init(center: position, radius: range)
	}
	
	func rangeOverlaps(with other: Self) -> Bool {
		position.distance(to: other.position) <= range + other.range
	}
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

// i won't lie, this part was actual hell.
// ended up finding https://todd.ginsberg.com/post/advent-of-code/2018/day23/ (nice writeup)
// their implementation of the Bron-Kerbosch algorithm looked somewhat nonstandard though and i ended up mostly copying it (except for the X set, which they didn't even use)

let adjacency = bots.enumerated().map { index, bot in
	Set(bots.indices.filter { bot.rangeOverlaps(with: bots[$0]) }).subtracting([index])
}

func maximalCliques(
	considering unknown: Set<Int>,
	included: Set<Int> = []
) -> [Set<Int>] {
	if unknown.isEmpty {
		return [included]
	} else {
		// pivot on the vertex with the most neighbors
		let pivotNeighbors = unknown
			.lazy
			.map { adjacency[$0] }
			.max(on: \.count)!
		let toTry = unknown.subtracting(pivotNeighbors)
		return toTry.flatMap { candidate -> [Set<Int>] in
			let neighbors = adjacency[candidate]
			return maximalCliques(
				considering: unknown.intersection(neighbors),
				included: included.union([candidate])
			)
		}
	}
}

measureTime {
	let cliques = Set(maximalCliques(considering: Set(bots.indices)))
	print(cliques.count, "maximal cliques")
	let maxSize = cliques.map(\.count).max()!
	let biggestClique = cliques.onlyElement { $0.count == maxSize }!
	print("biggest clique covers", biggestClique.count, "scanners")
	// distance to closest position in overlap is maximum distance to closest position in each bot's range
	print(biggestClique.map { bots[$0] }.map { $0.position.absolute - $0.range }.max()!)
}
