// Created by Julian Dunskus

import Foundation

extension Instruction: CustomStringConvertible {
	var description: String {
		let aDesc = "\(operation.usesRegisters.a ? "r" : "")\(a)"
		let bDesc = "\(operation.usesRegisters.b ? "r" : "")\(b)"
		if operation.isMathOp, operation.usesRegisters.a, a == c {
			return "r\(c) \(operation.opDescription!)= \(bDesc)"
		} else if operation.isMathOp, operation.usesRegisters.b, b == c {
			return "r\(c) \(operation.opDescription!)= \(aDesc)"
		} else {
			if let opDescription = operation.opDescription {
				return "r\(c)  = \(aDesc) \(opDescription) \(bDesc)"
			} else {
				return "r\(c)  = \(aDesc)"
			}
		}
	}
}

let lines = input().lines()
let ipRegister = Int(String(lines.first!.last!))!
let instructions = lines.dropFirst().map(Instruction.init)

print(instructions.map(^\.description).joined(separator: "\n"))

var registers = Array(repeating: 0, count: 6)
registers[0] = 15823996

while let instruction = instructions.element(at: registers[ipRegister]) {
	registers[instruction.c] = instruction.operation.evaluate(a: instruction.a, b: instruction.b) { registers[$0] }
	registers[ipRegister] += 1
	if registers[ipRegister] == 18 {
		print("skipping")
		registers[ipRegister] = 27
		registers[3] = registers[3] / 256
	}
}

print(registers)

let target = 15823996
var acc = 0
var seen: [Int] = []
repeat {
	seen.append(acc)
	var inner = acc | 65536 // 0x10000
	acc = 16098955 // 0xF5A68B
	while inner >= 1 {
		acc += inner & 0xFF
		acc &= 0xFFFFFF
		acc *= 65899 // 0x1016B
		acc &= 0xFFFFFF
		
		inner /= 256
	}
} while !seen.contains(acc)
print("last non-repeated accumulator:", seen.last!)
