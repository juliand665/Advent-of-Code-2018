// Created by Julian Dunskus

import Foundation

infix operator <-: NilCoalescingPrecedence

@discardableResult public func <- <T>(value: T, transform: (inout T) throws -> Void) rethrows -> T {
	var copy = value
	try transform(&copy)
	return copy
}

infix operator ???: NilCoalescingPrecedence

func ??? <Wrapped>(optional: Wrapped?, error: @autoclosure () -> Error) throws -> Wrapped {
	guard let unwrapped = optional else { throw error() }
	return unwrapped
}

prefix operator ^

prefix func ^ <S, T> (keyPath: KeyPath<S, T>) -> (S) -> T {
	return { $0[keyPath: keyPath] }
}

func repeatElement<T>(_ element: T) -> Repeated<T> {
	return repeatElement(element, count: .max)
}

extension Sequence {
	func count(where isIncluded: (Element) throws -> Bool) rethrows -> Int {
		return try lazy.filter(isIncluded).count
	}
	
	func repeated() -> AnySequence<Element> {
		return AnySequence(AnyIterator { self }.joined())
	}
	
	func forceMap<T>(_ transform: (Element) -> T?) -> [T] {
		return map { transform($0)! }
	}
}

extension Sequence where Element: Equatable {
	func count(of element: Element) -> Int {
		return lazy.filter { $0 == element }.count
	}
}

extension Sequence where Element: Numeric {
	func sum() -> Element {
		return reduce(0, +)
	}
}

extension Collection {
	func increasingCombinations() -> AnySequence<(Element, Element)> {
		return AnySequence(enumerated()
			.lazy
			.flatMap { zip(repeatElement($0.element), self.dropFirst($0.offset + 1)) }
		)
	}
	
	func allCombinations() -> AnySequence<(Element, Element)> {
		return AnySequence(lazy.flatMap { zip(repeatElement($0), self) })
	}
}

extension Character {
	var firstScalarValue: UInt32 {
		return unicodeScalars.first!.value
	}
}

extension Collection {
	func element(at index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}

extension Collection where Index == Int, Element: Collection, Element.Index == Int {
	func element(at position: Vector2) -> Element.Element? {
		return element(at: position.y)?.element(at: position.x)
	}
}

extension MutableCollection where Index == Int, Element: MutableCollection, Element.Index == Int {
	/// row-major
	subscript(position: Vector2) -> Element.Element {
		get { return self[position.y][position.x] }
		set { self[position.y][position.x] = newValue }
	}
}

protocol ReferenceHashable: AnyObject, Hashable {}

extension ReferenceHashable {
	func hash(into hasher: inout Hasher) {
		withUnsafePointer(to: self) {
			hasher.combine(bytes: UnsafeRawBufferPointer(start: $0, count: MemoryLayout<Self>.size))
		}
	}
}

extension Sequence {
	func sorted<C>(on accessor: (Element) -> C) -> [Element] where C: Comparable {
		return self
			.map { ($0, accessor($0)) }
			.sorted { $0.1 < $1.1 }
			.map { $0.0 }
	}
}
