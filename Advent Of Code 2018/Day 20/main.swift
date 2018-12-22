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

let (path, isDone) = read()
assert(isDone)

func follow<C>(_ path: C) -> [[Direction]] where C: Collection, C.Element == PathPart {
	switch path.first {
	case nil:
		return [[]]
	case .single(let steps)?:
		return follow(path.dropFirst()).map { steps + $0 }
	case .multiple(let options)?:
		let next = follow(path.dropFirst())
		return options.flatMap(follow).flatMap { option in next.map { option + $0 } }
	}
}

let allPaths = follow(path)
print(allPaths.count)
