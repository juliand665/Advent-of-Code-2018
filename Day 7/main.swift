// Created by Julian Dunskus

import Foundation

typealias Step = Character

let dependencies: [(Step, Step)] = input().lines().map {
	let words = $0.split(separator: " ")
	return (words[1].first!, words[7].first!)
}

let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
let requirements: [Step: Set<Step>] = Dictionary(uniqueKeysWithValues: zip(alphabet, repeatElement([]))) <- { requirements in
	for (dependency, dependent) in dependencies {
		requirements[dependent]!.insert(dependency)
	}
}

do {
	var order = ""
	var remaining = requirements
	while !remaining.isEmpty {
		let choice = remaining
			.filter { $0.value.isEmpty }
			.map { $0.key }
			.sorted()
			.first!
		order.append(choice)
		remaining.removeValue(forKey: choice)
		for dependent in remaining.keys {
			remaining[dependent]?.remove(choice)
		}
	}
	print(order)
}

let aValue = ("A" as Step).firstScalarValue
func duration(for step: Step) -> Int {
	return 61 + aValue.distance(to: step.firstScalarValue)
}

struct Progress {
	var step: Step
	var remaining: Int
	
	init(_ step: Step) {
		self.step = step
		self.remaining = duration(for: step)
	}
}

do {
	var remaining = requirements
	var work = [Progress?](repeating: nil, count: 5)
	var time = 0
	while !remaining.isEmpty {
		for index in work.indices {
			work[index] = work[index] <- { progress in
				progress?.remaining -= 1
				
				if let existing = progress, existing.remaining == 0 {
					for dependent in remaining.keys {
						remaining[dependent]?.remove(existing.step)
					}
					progress = nil
				}
				
				if progress == nil {
					let choice = remaining
						.filter { $0.value.isEmpty }
						.map { $0.key }
						.sorted()
						.first
					if let choice = choice {
						progress = Progress(choice)
						remaining.removeValue(forKey: choice)
					}
				}
			}
		}
		time += 1
	}
	time += work.compactMap { $0?.remaining }.max() ?? 0
	print(time) // not 1121
}

func minDuration(for step: Step) -> Int {
	return duration(for: step) + (requirements[step]!.map(minDuration).max() ?? 0)
}
print(alphabet.map(minDuration))
