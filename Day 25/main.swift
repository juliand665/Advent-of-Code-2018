import AoC_Helpers
import HandyOperators

let fixedPoints = input().lines().map(Vector4.init)

// union-find, i think?
var parents: [Int?] = .init(repeating: nil, count: fixedPoints.count)
func findRootIndex(of start: Int) -> Int {
	guard let parent = parents[start] else { return start }
	return findRootIndex(of: parent) <- { parents[start] = $0 }
}

for (index, point) in fixedPoints.enumerated() {
	let previous = fixedPoints.enumerated().prefix(index)
	var root = index
	for (otherIndex, other) in previous {
		guard point.distance(to: other) <= 3 else { continue }
		let otherRoot = findRootIndex(of: otherIndex)
		if otherRoot < root {
			parents[root] = otherRoot
			root = otherRoot
		} else if otherRoot > root {
			parents[otherRoot] = root
		}
	}
}

measureTime {
	let constellationCount = parents.count(of: nil)
	print(constellationCount, "constellations")
}
