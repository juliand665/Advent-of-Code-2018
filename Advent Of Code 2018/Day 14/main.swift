// Created by Julian Dunskus

import Foundation

let recipeCount = 894501
let digits = String(recipeCount).map(String.init).forceMap(Int.init)

var recipes = [3, 7]
recipes.reserveCapacity(recipeCount + 11)

var pos1 = 0
var pos2 = 1
func generateRecipes(while shouldContinue: () -> Bool) {
	while shouldContinue() {
		let elf1 = recipes[pos1]
		let elf2 = recipes[pos2]
		let new = elf1 + elf2
		if new >= 10 {
			recipes.append(1)
			guard shouldContinue() else { break }
			recipes.append(new - 10)
		} else {
			recipes.append(new)
		}
		pos1 += elf1 + 1
		pos1 %= recipes.count
		pos2 += elf2 + 1
		pos2 %= recipes.count
	}
}

generateRecipes { recipes.count < recipeCount + 10 }
print(recipes.suffix(10).map(String.init).joined())

var currentDigit = 0
generateRecipes {
	if recipes.last! == digits[currentDigit] {
		currentDigit += 1
		if currentDigit == digits.count {
			// found!
			print(recipes.suffix(10).map(String.init).joined())
			print(recipes.count - digits.count)
			return false
		}
	} else {
		currentDigit = recipes.last! == digits.first! ? 1 : 0
	}
	return true
}
