// Created by Julian Dunskus

import Foundation

struct Claim {
	var id: Int
	var x: Int
	var y: Int
	var width: Int
	var height: Int
	
	init(raw: Substring) {
		var parser = Parser(reading: raw)
		parser.consume("#")
		id = parser.readInt()
		parser.consume(" @ ")
		x = parser.readInt()
		parser.consume(",")
		y = parser.readInt()
		parser.consume(": ")
		width = parser.readInt()
		parser.consume("x")
		height = parser.readInt()
	}
}

enum ClaimState {
	case unclaimed
	case claimed(by: Int)
	case overlapped
	
	var isOverlap: Bool {
		if case .overlapped = self {
			return true
		} else {
			return false
		}
	}
}

let claims = input().lines().map(Claim.init)

let width = claims.map { $0.x + $0.width }.max()!
let height = claims.map { $0.y + $0.height }.max()!

var area = Array(repeating: Array(repeating: ClaimState.unclaimed, count: height), count: width)
var validClaims = Set(claims.map { $0.id })
for claim in claims {
	for x in claim.x..<claim.x + claim.width {
		for y in claim.y..<claim.y + claim.height {
			switch area[x][y] {
			case .unclaimed:
				area[x][y] = .claimed(by: claim.id)
			case .claimed(let previousID):
				validClaims.remove(previousID)
				validClaims.remove(claim.id)
				area[x][y] = .overlapped
			case .overlapped:
				validClaims.remove(claim.id)
			}
		}
	}
}

let overlap = area
	.lazy
	.map { $0.count { $0.isOverlap } }
	.sum()
print(overlap)

print(validClaims)
