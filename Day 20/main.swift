import AoC_Helpers
import SimpleParser
import Collections
import HandyOperators
import Darwin

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
	
	var cardinal: String {
		switch self {
		case .up:
			return "N"
		case .right:
			return "E"
		case .down:
			return "S"
		case .left:
			return "W"
		}
	}
}

enum Part: CustomStringConvertible {
	case single(Direction)
	case multiple([Path])
	
	var description: String {
		switch self {
		case .single(let direction):
			return direction.cardinal
		case .multiple(let paths):
			return "(" + paths.map(description(for:)).joined(separator: "|") + ")"
		}
	}
}

func description<S: Sequence>(for path: S) -> String where S.Element == Part {
	path.map(String.init).joined()
}

typealias Path = [Part]
typealias Subpath = Path.SubSequence

var parser = Parser(reading: input())
parser.consume("^")

func readDisjunction() -> [Path] {
	Array(sequence(state: ()) { _ in
		switch parser.next! {
		case ")":
			parser.consume(")")
			return nil
		case "|":
			parser.consume("|")
			fallthrough
		default:
			return readPath()
		}
	})
}

func readPath() -> Path {
	Array(sequence(state: ()) { _ in
		switch parser.next! {
		case "|", ")", "$":
			return nil
		default:
			return readPart()
		}
	})
}

func readPart() -> Part {
	switch parser.consumeNext() {
	case "(":
		return .multiple(readDisjunction())
	case let raw:
		return .single(Direction(rawCardinal: raw)!)
	}
}

let path = readPath()
parser.consume("$")
print("path parsed!")
print(description(for: path))

let start = Vector2.zero

struct Map {
	var connections: [Vector2: DirectionSet] = [:]
	
	mutating func addConnection(from position: Vector2, in direction: Direction) {
		connections[position, default: []].insert(.init(direction))
	}
	
	static func + (lhs: Self, rhs: Self) -> Self {
		.init(connections: lhs.connections.merging(rhs.connections) { $0.union($1) })
	}
}

func explore(_ path: Path) -> Map {
	var map = Map()
	func explore(_ path: Path, from startPositions: Set<Vector2>) -> Set<Vector2> {
		path.reduce(startPositions) { positions, part in
			switch part {
			case .single(let direction):
				return Set(positions.map { position in
					let next = position + direction.offset
					map.addConnection(from: position, in: direction)
					map.addConnection(from: next, in: direction.opposite)
					return next
				})
			case .multiple(let paths):
				return paths
					.map { explore($0, from: positions) }
					.reduce([]) { $0.union($1) }
			}
		}
	}
	let endPositions = explore(path, from: [start])
	print(endPositions.count, "unique end positions")
	return map
}

let map = explore(path)
let connections = map.connections
print(connections.count, "rooms identified")

var depths: [Vector2: Int] = [start: 0]
var toSearch: Deque<Vector2> = [start]
while let start = toSearch.popFirst() {
	let depth = depths[start]!
	for direction in Direction.allCases where connections[start]!.contains(.init(direction)) {
		let neighbor = start + direction.offset
		guard depths[neighbor] == nil else { continue }
		depths[neighbor] = depth + 1
		toSearch.append(neighbor)
	}
}

print("max depth:", depths.values.max()!)
print("depth >= 1000:", depths.values.count { $0 >= 1000 })
