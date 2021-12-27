// Created by Julian Dunskus.

import Foundation

let changes = input().lines().compactMap { Int(String($0)) }

let frequency = changes.sum()
print(frequency)

var sum = 0
var seen: Set = [0]
for change in changes.repeated() {
	sum += change
	guard seen.insert(sum).inserted else {
		print(sum)
		break
	}
}
