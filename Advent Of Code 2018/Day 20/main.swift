// Created by Julian Dunskus

import Foundation

extension Direction {
	init?(rawCardinal: Character) {
		switch rawCardinal {
		case "N": self = .up
		case "E": self = .right
		case "S": self = .down
		case "W": self = .left
		default: return nil
		}
	}
}

enum PathPart {
	case single([Direction])
	case multiple([Path])
}
typealias Path = [PathPart]

var parser = Parser(reading: input().dropFirst())

func read() -> (path: Path, isScopeDone: Bool) {
	var path = Path()
	var current: [Direction] = []
	while true {
		switch parser.consumeNext() {
		case "(":
			path.append(.single(current))
			current = []
			
			let options: [Path] = [] <- {
				while true {
					let option = read()
					$0.append(option.path)
					guard !option.isScopeDone else { return }
				}
			}
			path.append(.multiple(options))
		case "|":
			path.append(.single(current))
			current = []
			return (path, isScopeDone: false)
		case ")", "$":
			path.append(.single(current))
			current = []
			return (path, isScopeDone: true)
		case let raw:
			current.append(Direction(rawCardinal: raw)!)
		}
	}
}

struct DoorAvailability: OptionSet {
	
	static let horizontal = DoorAvailability(rawValue: 1 << 0)
	static let vertical = DoorAvailability(rawValue: 1 << 1)
	
	let rawValue: Int
}

let offset = Vector2(1000, 1000)
let size = Vector2(2000, 2000)
var doors: [[DoorAvailability]] = Array(repeating: Array(repeating: [], count: size.x), count: size.y)

struct Room {
	var position: Vector2
	
	subscript(_ direction: Direction) -> Bool {
		get {
			switch direction {
			case .up:
				return doors[position + offset].contains(.vertical)
			case .down:
				return doors[position + offset - .unitY].contains(.vertical)
			case .right:
				return doors[position + offset].contains(.horizontal)
			case .left:
				return doors[position + offset - .unitX].contains(.horizontal)
			}
		}
		nonmutating set {
			switch direction {
			case .up:
				doors[position + offset].insert(.vertical)
			case .down:
				doors[position + offset - .unitY].insert(.vertical)
			case .right:
				doors[position + offset].insert(.horizontal)
			case .left:
				doors[position + offset - .unitX].insert(.horizontal)
			}
		}
	}
}

func room(at pos: Vector2) -> Room {
	return Room(position: pos)
}

let (path, isDone) = read()
assert(isDone)

var exploredLength = 0
func explore<C>(_ path: C, startingFrom start: Vector2 = .zero) -> Set<Vector2> where C: Collection, C.Element == PathPart {
	defer {
		if path.count > exploredLength {
			exploredLength = path.count
			print(exploredLength)
		}
	}
	
	switch path.first {
	case nil:
		return [start]
	case .single(let steps)?:
		var position = start
		for direction in steps {
			let room = Room(position: position)
			room[direction] = true
			position = position + direction.offset
		}
		return Set(explore(path.dropFirst(), startingFrom: position))
	case .multiple(let options)?:
		let next = options.flatMap { explore($0, startingFrom: start) }
		return Set(next.flatMap { explore(path.dropFirst(), startingFrom: $0) })
	}
}

let endPositions = explore(path)
print(endPositions.count)
