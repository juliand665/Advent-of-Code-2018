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

extension MutableCollection where Index == Int, Element: MutableCollection, Element.Index == Int {
	/// row-major
	subscript(position: Vector2) -> Element.Element {
		get { return self[position.y][position.x] }
		set { self[position.y][position.x] = newValue }
	}
}
