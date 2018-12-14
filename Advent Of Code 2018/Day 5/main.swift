// Created by Julian Dunskus

import Foundation

func canEliminate(_ char1: Character, _ char2: Character) -> Bool {
	return char1.firstScalarValue ^ char2.firstScalarValue == 0x20
}

extension StringProtocol {
	func reacted() -> String {
		return reduce(into: "") { polymer, next in
			if let last = polymer.last, canEliminate(last, next) {
				polymer.removeLast()
			} else {
				polymer.append(next)
			}
		} // should technically reverse this, but it works for our purposes so ¯\_(ツ)_/¯
	}
}

let polymer = input().lines().first!
let reduced = polymer.reacted()
print(reduced.count)

let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
let options = alphabet.map { toEliminate -> String in
	return reduced
		.filter { $0 != toEliminate && !canEliminate($0, toEliminate) }
		.reacted()
}
let best = options.min { $0.count < $1.count }!
print(best.count)

/* stupidly overcomplicated old solution:
final class DoublyLinkedList<Element>: Sequence {
	var start: Entry?
	var end: Entry?
	
	init<S>(_ sequence: S) where S: Sequence, S.Element == Element {
		var iterator = sequence.makeIterator()
		guard let first = iterator.next() else { return }
		
		var previous = Entry(value: first)
		start = previous
		end = start
		while let next = iterator.next() {
			let entry = Entry(value: next)
			link(previous, entry)
			previous = entry
		}
	}
	
	var entrySequence: UnfoldSequence<Entry, Entry?> {
		return sequence(state: start) { current in
			defer { current = current?.next }
			return current
		}
	}
	
	func makeIterator() -> LazyMapSequence<UnfoldSequence<Entry, Entry?>, Element>.Iterator {
		return entrySequence
			.lazy
			.map { $0.value }
			.makeIterator()
	}
	
	func removeAll(where shouldRemove: (Element) throws -> Bool) rethrows {
		for entry in entrySequence {
			if try shouldRemove(entry.value) {
				remove(entry)
			}
		}
	}
	
	func link(_ prev: Entry?, _ next: Entry?) {
		prev?.next = next
		next?.prev = prev
	}
	
	func remove(_ entry: Entry) {
		link(entry.prev, entry.next)
		if entry === start { start = entry.next }
		if entry === end { end = entry.prev }
	}
	
	final class Entry {
		var value: Element
		var prev: Entry?
		var next: Entry?
		
		init(value: Element) {
			self.value = value
		}
	}
}

extension DoublyLinkedList where Element == Character {
	func react() {
		var entry = start
		while let current = entry, let next = current.next {
			if canEliminate(current.value, next.value) {
				entry = current.prev ?? next.next
				remove(current)
				remove(next)
			} else {
				entry = next
			}
		}
	}
	
}

typealias Polymer = DoublyLinkedList<Character>

let polymer = Polymer(input().lines().first!)
polymer.react()

let reduced = String(polymer)
print(reduced.count)

let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
let options = alphabet.map { toEliminate -> String in
	let copy = Polymer(reduced)
	copy.removeAll { $0 == toEliminate || canEliminate($0, toEliminate) }
	copy.react()
	return String(copy)
}
let best = options.min { $0.count < $1.count }!
print(best.count)
*/
