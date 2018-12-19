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
