// Created by Julian Dunskus

import Foundation

struct Instruction: Parseable {
	var operation: Operation
	var a, b, c: Int
	
	init(from parser: inout Parser) {
		self.operation = Operation(rawValue: String(parser.consume(through: " ")))!
		parser.consume(while: " ")
		self.a = parser.readInt()
		parser.consume(while: " ")
		self.b = parser.readInt()
		parser.consume(while: " ")
		self.c = parser.readInt()
	}
}

let lines = input().lines()
let ipRegister = Int(String(lines.first!.last!))!
let instructions = lines.dropFirst().map(Instruction.init)

var registers = Array(repeating: 0, count: 6)

while let instruction = instructions.element(at: registers[ipRegister]) {
	registers[instruction.c] = instruction.operation.evaluate(a: instruction.a, b: instruction.b) { registers[$0] }
	registers[ipRegister] += 1
}

print(registers)

// part 2 solved in text editor; results in program.txt
