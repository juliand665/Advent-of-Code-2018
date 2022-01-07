import AoC_Helpers
import SimpleParser
import HandyOperators

enum DamageType: String, CustomStringConvertible {
	case bludgeoning
	case slashing
	case radiation
	case cold
	case fire
	
	var description: String { rawValue }
}

struct GroupStats: Parseable {
	var unitCount: Int
	var hitpoints: Int
	var weaknesses: Set<DamageType> = []
	var immunities: Set<DamageType> = []
	var attackDamage: Int
	var attackType: DamageType
	var initiative: Int
	
	init(from parser: inout Parser) {
		unitCount = parser.readInt()
		parser.consume(" units each with ")
		hitpoints = parser.readInt()
		parser.consume(" hit points")
		if parser.tryConsume(" (") {
			let specials = parser.consume(through: ")")!.components(separatedBy: "; ")
			for special in specials {
				let (kind, rawTypes) = special.components(separatedBy: " to ").bothElements()!
				let types = Set(rawTypes.components(separatedBy: ", ").map { DamageType(rawValue: $0)! })
				switch kind {
				case "weak":
					assert(weaknesses.isEmpty)
					weaknesses = types
				case "immune":
					assert(immunities.isEmpty)
					immunities = types
				case let kind:
					fatalError("unrecognized special: '\(kind)'")
				}
			}
		}
		parser.consume(" with an attack that does ")
		attackDamage = parser.readInt()
		parser.consume(" ")
		attackType = .init(rawValue: parser.readWord())!
		parser.consume(" damage at initiative ")
		initiative = parser.readInt()
	}
}

final class Group {
	var unitCount: Int
	let stats: GroupStats
	
	/// effective. Power لُلُصّبُلُلصّبُررً ॣ ॣh ॣ ॣ 冗
	var effectivePower: Int {
		unitCount * stats.attackDamage
	}
	
	var isDead: Bool {
		unitCount <= 0
	}
	
	var initiative: Int { // we use this a lot
		stats.initiative
	}
	
	init(_ stats: GroupStats) {
		self.stats = stats
		self.unitCount = stats.unitCount
	}
	
	func damageMultiplier(for type: DamageType) -> Int {
		stats.immunities.contains(type) ? 0 :
		stats.weaknesses.contains(type) ? 2 : 1
	}
	
	func damage(to other: Group) -> Int {
		effectivePower * other.damageMultiplier(for: stats.attackType)
	}
	
	func receiveAttack(from other: Group) {
		let damageTaken = other.damage(to: self)
		let unitsLost = min(unitCount, damageTaken / stats.hitpoints)
		unitCount -= unitsLost
	}
	
	func target<S: Sequence>(in groups: S) -> Group? where S.Element == Group {
		let best = groups.max { // tuples (still!) don't conform to comparable :(
			(damage(to: $0), $0.effectivePower, $0.initiative)
			< (damage(to: $1), $1.effectivePower, $1.initiative)
		}
		guard let best = best, damage(to: best) > 0 else { return nil }
		return best
	}
}

extension Group: CustomStringConvertible {
	var description: String {
		"Group(\(unitCount) units)"
	}
}

struct Battle {
	var immuneSystem: [Group]
	var infection: [Group]
	
	var isDone: Bool {
		immuneSystem.isEmpty || infection.isEmpty
	}
	
	mutating func runFight() {
		let targets = collectTargets(for: immuneSystem, attacking: infection)
		+ collectTargets(for: infection, attacking: immuneSystem)
		
		let order = targets.sorted(on: \.0.initiative).reversed()
		for (attacker, defender) in order {
			defender.receiveAttack(from: attacker)
		}
		
		immuneSystem.removeAll(where: \.isDead)
		infection.removeAll(where: \.isDead)
	}
	
	func collectTargets(for army: [Group], attacking other: [Group]) -> [(Group, Group)] {
		var remainingTargets: [ObjectIdentifier: Group] = .init(
			uniqueKeysWithValues: other.map { (ObjectIdentifier($0), $0) }
		)
		return army
			.sorted { ($0.effectivePower, $0.initiative) < ($1.effectivePower, $1.initiative) }
			.reversed()
			.compactMap { group in
				group.target(in: remainingTargets.values).map {
					remainingTargets.removeValue(forKey: ObjectIdentifier($0))
					return (group, $0)
				}
			}
	}
	
	func numbers() -> [Int] {
		immuneSystem.map(\.unitCount) + infection.map(\.unitCount)
	}
}

let (immuneSystem, infection) = input()
	.lines()
	.split(whereSeparator: \.isEmpty)
	.map { $0.dropFirst().map(GroupStats.init) }
	.bothElements()!

func simulateOutcome(immuneBoost: Int = 0) -> Battle {
	Battle(
		immuneSystem: immuneSystem
			.map { $0 <- { $0.attackDamage += immuneBoost } }
			.map(Group.init),
		infection: infection.map(Group.init)
	) <- { battle in
		var lastNumbers: [Int]
		repeat {
			lastNumbers = battle.numbers() // sometimes things get stuck in a stalemate
			battle.runFight()
		} while !battle.isDone && battle.numbers() != lastNumbers
	}
}

measureTime {
	let initial = simulateOutcome()
	print("remaining enemy units:", initial.infection.map(\.unitCount).sum())
}

var lowerBound = 0
var upperBound = 1
// explore exponentially to find upper bound
while true {
	let outcome = simulateOutcome(immuneBoost: upperBound)
	guard outcome.immuneSystem.isEmpty else { break } // upper bound found!
	upperBound <<= 1
}

print("upper bound:", upperBound)

// binary search
while lowerBound < upperBound - 1 {
	let midpoint = (lowerBound + upperBound) / 2
	let outcome = simulateOutcome(immuneBoost: midpoint)
	if outcome.infection.isEmpty {
		upperBound = midpoint
		print("upper:", upperBound)
	} else {
		lowerBound = midpoint
		print("lower:", lowerBound)
	}
}
let minBoost = simulateOutcome(immuneBoost: upperBound).infection.isEmpty ? upperBound : lowerBound
print("minimum boost:", minBoost)
let outcome = simulateOutcome(immuneBoost: minBoost)
print("remaining friendly units:", outcome.immuneSystem.map(\.unitCount).sum())
