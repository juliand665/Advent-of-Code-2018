// Created by Julian Dunskus

import Foundation

typealias Position = (x: Int, y: Int)

final class FuelGrid {
	let serialNumber: Int
	
	init(serialNumber: Int) {
		self.serialNumber = serialNumber
	}
	
	subscript(position: Position) -> Int {
		guard case 1...300 = position.x, case 1...300 = position.y else { return 0 }
		
		let rackID = position.x + 10
		let rawPower = (rackID * position.y + serialNumber) * rackID
		return (rawPower / 100) % 10 - 5
	}
	
	func powerForSquare(ofSize size: Int, at position: Position) -> Int {
		let powerLevels = (position.x..<position.x + size).lazy.flatMap { x in
			(position.y..<position.y + size).lazy.map { y in
				self[(x, y)]
			}
		}
		return powerLevels.sum()
	}
	
	func bestSquare(ofSize size: Int) -> (position: Position, power: Int) {
		return (1...(301 - size)).allCombinations()
			.map { ($0, powerForSquare(ofSize: size, at: $0)) }
			.max { $0.power < $1.power }!
	}
}

let grid = FuelGrid(serialNumber: 2694)
print(grid.bestSquare(ofSize: 3))

let bestSquare = (1...300)
	.lazy
	.map { (size: $0, square: grid.bestSquare(ofSize: $0)) <- { print($0) } }
	.max { $0.square.power < $1.square.power }!
print(bestSquare)
