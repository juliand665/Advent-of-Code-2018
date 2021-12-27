// Created by Julian Dunskus

import Foundation

let log = input().lines().sorted()
let parts = zip(
	log.filter { $0.hasSuffix("begins shift") },
	log.split(omittingEmptySubsequences: false) { $0.hasSuffix("begins shift") }.dropFirst()
)

var sleepTimes: [Int: [Int]] = [:]
for (start, entries) in parts {
	var idParser = Parser(reading: start)
	idParser.consume(through: "#")
	let id = idParser.readInt()
	
	var times = sleepTimes[id] ?? Array(repeating: 0, count: 60)
	var lastStartTime: Int?
	for entry in entries {
		if let startTime = lastStartTime {
			assert(entry.hasSuffix("wakes up"))
			var parser = Parser(reading: entry)
			parser.consume(through: ":")
			let endTime = parser.readInt()
			
			for minute in startTime..<endTime {
				times[minute] += 1
			}
			lastStartTime = nil
		} else {
			assert(entry.hasSuffix("falls asleep"))
			var parser = Parser(reading: entry)
			parser.consume(through: ":")
			lastStartTime = parser.readInt()
		}
	}
	
	sleepTimes[id] = times
}

let mostAsleepGuard = sleepTimes.mapValues { $0.sum() }.max { $0.value < $1.value }!.key
let mostAsleepMinute = sleepTimes[mostAsleepGuard]!.enumerated().max { $0.element < $1.element }!.offset
print(mostAsleepGuard, "*", mostAsleepMinute, "=", mostAsleepGuard * mostAsleepMinute)

let options = sleepTimes.lazy.flatMap { (id, times) in
	times.enumerated().map {
		(id: id, minute: $0.offset, count: $0.element)
	}
}
let bestChoice = options.max { $0.count < $1.count }!
print(bestChoice, bestChoice.id * bestChoice.minute)
