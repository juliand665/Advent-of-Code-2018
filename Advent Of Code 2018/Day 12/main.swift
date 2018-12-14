// Created by Julian Dunskus

import Foundation

typealias Pots = [Pot]

extension Array where Element == Pot {
	init<S>(_ raw: S) where S: StringProtocol {
		self = raw.forceMap(Pot.init)
	}
}

extension Sequence where Element == Pot {
	var raw: String {
		return String(map(^\.rawValue))
	}
	
	var dense: Int {
		return reduce(0) { $0 << 1 | ($1 == .filled ? 1 : 0) }
	}
}

enum Pot: Character, Hashable {
	case filled = "#"
	case empty = "."
}

let lines = input().lines()
let rawInitialState = Pots(lines.first!.dropFirst(15))

let patterns: [Pot] = lines.dropFirst()
	.map { (Pots($0.prefix(5)).dense, Pot(rawValue: $0.last!)!) }
	.sorted { $0.0 < $1.0 }
	.map { $0.1 }

struct State {
	let leftPadding = 5
	var pots: Pots
	
	init(initialState: Pots, rightPadding: Int) {
		self.pots = repeatElement(.empty, count: leftPadding)
			+ initialState
			+ repeatElement(.empty, count: rightPadding)
	}
	
	func value() -> Int {
		return zip((-leftPadding)..., pots)
			.filter { $0.1 == .filled }
			.map { $0.0 }
			.sum()
	}
	
	mutating func applyPatterns() {
		let new = pots.enumerated()
			.dropFirst(2).dropLast(2)
			.map { patterns[pots[max(pots.startIndex, $0.offset - 2)...($0.offset + 2)].dense] }
		let pad = repeatElement(Pot.empty, count: 2)
		pots = pad + new + pad
	}
}

let initialState = State(initialState: rawInitialState, rightPadding: 125)
let states = sequence(first: initialState) { $0 <- { $0.applyPatterns() } }
let firstStates = Array(states.prefix(121))

for (offset, state) in firstStates.enumerated() {
	print(offset, state.pots.raw, state.value(), separator: "\t")
}

let generationCount = 50_000_000_000
let finalValue = firstStates.last!.value() + (firstStates.last!.value() - firstStates.dropLast().last!.value()) * (generationCount + 1 - firstStates.count)
print(finalValue)
