// Created by Julian Dunskus

import Foundation

enum Acre: Character {
	case open = "."
	case wooded = "|"
	case lumberyard = "#"
}

var acres = input().lines().map { $0.forceMap(Acre.init) }
let width = acres.first!.count
let height = acres.count

func step() {
	acres = acres.enumerated().map { y, line in
		line.enumerated().map { x, acre in
			let position = Vector2(x, y)
			let neighbors = position.applyingOffsets(.distance1or2).compactMap(acres.element(at:))
			switch acre {
			case .open:
				guard neighbors.count(of: .wooded) < 3 else { return .wooded }
			case .wooded:
				guard neighbors.count(of: .lumberyard) < 3 else { return .lumberyard }
			case .lumberyard:
				guard neighbors.contains(.wooded), neighbors.contains(.lumberyard) else { return .open }
			}
			return acre
		}
	}
}

func resourceValue() -> Int {
	let woodedCount = acres.joined().count(of: .wooded)
	let lumberyardCount = acres.joined().count(of: .lumberyard)
	return woodedCount * lumberyardCount
}

var values: [(hash: Int, resourceValue: Int)] = [(acres.hashValue, resourceValue())]
let repetitionStart: Int = {
	while true {
		step()
		let hash = acres.hashValue
		if let start = values.firstIndex(where: { $0.hash == hash }) {
			return start
		} else {
			values.append((hash, resourceValue()))
		}
	}
}()

print("value after 10 minutes:", values[10])

let period = values.count - repetitionStart
let stepCount = 1_000_000_000
let finalValue = values[repetitionStart + (stepCount - repetitionStart) % period]

print("value after \(stepCount) minutes:", finalValue)
