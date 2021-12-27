// Created by Julian Dunskus

import Foundation

struct Node {
	var children: [Node]
	var metadata: [Int]
	
	init(raw: inout [Int]) {
		let childCount = raw.removeFirst()
		let metadataCount = raw.removeFirst()
		children = (0..<childCount).map { _ in Node(raw: &raw) }
		metadata = Array(raw.prefix(metadataCount))
		raw.removeFirst(metadataCount)
	}
	
	func recursiveSum() -> Int {
		return metadata.sum() + children.map { $0.recursiveSum() }.sum()
	}
	
	func metaBasedSum() -> Int {
		if children.isEmpty {
			return metadata.sum()
		} else {
			let childSums = children.map { $0.metaBasedSum() }
			return metadata.map { childSums.indices.contains($0 - 1) ? childSums[$0 - 1] : 0 }.sum()
		}
	}
}

var numbers = input().lines().first!.split(separator: " ").map { Int($0)! }
let root = Node(raw: &numbers)
assert(numbers.isEmpty)

print(root.recursiveSum())
print(root.metaBasedSum())
