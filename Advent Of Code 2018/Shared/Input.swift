// Created by Julian Dunskus.

import Foundation

func input(fileName: String = "input") -> String {
	let url = URL(fileURLWithPath: Bundle.main.path(forResource: fileName, ofType: "txt")!)
	let rawInput = try! Data(contentsOf: url)
	return String(data: rawInput, encoding: .utf8)!
}

extension String {
	func lines() -> [Substring] {
		return split(separator: "\n")
	}
}
