r4 = 123
repeat {
	r4 &= 456 // 72
} while r4 != 72
r4 = 0
// bitwise AND test complete

repeat {
	r3 = r4 | 65536 // 0x10000
	r4 = 16098955 // 0xF5A68B
	while r3 >= 1 {
		r4 += r3 & 0xFF
		r4 &= 0xFFFFFF
		r4 *= 65899 // 0x1016B
		r4 &= 0xFFFFFF
		
		r3 /= 256
	}
} while r4 != r0

// r0 = 0x82FC5B
