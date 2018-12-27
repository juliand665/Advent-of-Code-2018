// Created by Julian Dunskus

import Foundation

enum Operation: String, CaseIterable {
	case addr, addi
	case mulr, muli
	case banr, bani
	case borr, bori
	case setr, seti
	case gtir, gtri, gtrr
	case eqir, eqri, eqrr
	
	var opDescription: String? {
		switch self {
		case .addr, .addi:
			return "+"
		case .mulr, .muli:
			return "*"
		case .banr, .bani:
			return "&"
		case .borr, .bori:
			return "|"
		case .setr, .seti:
			return nil
		case .gtir, .gtri, .gtrr:
			return ">"
		case .eqir, .eqri, .eqrr:
			return "=="
		}
	}
	
	var usesRegisters: (a: Bool, b: Bool) {
		switch self {
		case .addr, .mulr, .banr, .borr, .gtrr, .eqrr:
			return (true, true)
		case .addi, .muli, .bani, .bori, .gtri, .eqri, .setr:
			return (true, false)
		case .gtir, .eqir:
			return (false, true)
		case .seti:
			return (false, false)
		}
	}
	
	var isMathOp: Bool {
		switch self {
		case .addr, .addi, .mulr, .muli, .banr, .bani, .borr, .bori:
			return true
		case .setr, .seti, .gtir, .gtri, .gtrr, .eqir, .eqri, .eqrr:
			return false
		}
	}
	
	func evaluate(a: Int, b: Int, register: (Int) -> Int) -> Int {
		switch self {
		case .addr: return register(a) + register(b)
		case .addi: return register(a) + b
			
		case .mulr: return register(a) * register(b)
		case .muli: return register(a) * b
			
		case .banr: return register(a) & register(b)
		case .bani: return register(a) & b
			
		case .borr: return register(a) | register(b)
		case .bori: return register(a) | b
			
		case .setr: return register(a)
		case .seti: return a
			
		case .gtir: return a > register(b) ? 1 : 0
		case .gtri: return register(a) > b ? 1 : 0
		case .gtrr: return register(a) > register(b) ? 1 : 0
			
		case .eqir: return a == register(b) ? 1 : 0
		case .eqri: return register(a) == b ? 1 : 0
		case .eqrr: return register(a) == register(b) ? 1 : 0
		}
	}
}

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
