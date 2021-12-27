// Created by Julian Dunskus

import Foundation

let ids = input().lines()
let letterCounts = ids.map {
	Dictionary(zip($0, repeatElement(1, count: .max)), uniquingKeysWith: +)
}
let doubles = letterCounts.count { $0.values.contains(2) }
let triples = letterCounts.count { $0.values.contains(3) }
print(doubles * triples)

func differExactlyOnce(_ l: Substring, _ r: Substring) -> Bool {
	guard let l0 = l.first, let r0 = r.first else { return false }
	if l0 == r0 {
		return differExactlyOnce(l.dropFirst(), r.dropFirst())
	} else {
		return l.dropFirst() == r.dropFirst()
	}
}

let combination = ids
	.combinations()
	.first(where: differExactlyOnce)!
print(combination)
