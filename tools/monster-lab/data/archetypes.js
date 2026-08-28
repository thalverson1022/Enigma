"use strict";

window.MonsterLabArchetypes = [
  {
    id: "stonewall",
    name: "Stonewall",
    tone: "slow, blunt, hard to crack",
    baseHpBias: 1.24,
    mechanicWeights: {
      armor: 72,
      block: 50,
      slow: 20,
      crit_negation: 18,
      poison_resistance: 8
    },
    nameParts: {
      prefixes: ["Iron", "Stone", "Granite", "Anvil", "Old"],
      nouns: ["Bulwark", "Brute", "Sentinel", "Backbreaker", "Gatekeeper"]
    }
  },
  {
    id: "venomproof",
    name: "Venomproof",
    tone: "anti-poison, patient, clinical",
    baseHpBias: 1.06,
    mechanicWeights: {
      poison_resistance: 68,
      cleanse_threshold: 48,
      absorb: 36,
      suppress: 28,
      armor: 10
    },
    nameParts: {
      prefixes: ["Pale", "Glass", "Antidote", "Bleached", "Serum"],
      nouns: ["Acolyte", "Warden", "Mireguard", "Leech", "Vessel"]
    }
  },
  {
    id: "duelist",
    name: "Duelist",
    tone: "nimble, evasive, tests hit reliability",
    baseHpBias: 0.88,
    mechanicWeights: {
      dodge_chance: 72,
      crit_negation: 36,
      interrupt_skip_count: 18,
      block: 14,
      armor: 8
    },
    nameParts: {
      prefixes: ["Quick", "Velvet", "Needle", "Laughing", "Silver"],
      nouns: ["Cutthroat", "Fencer", "Knifewhisper", "Blade", "Rake"]
    }
  },
  {
    id: "suppressor",
    name: "Suppressor",
    tone: "low patience, timing hostile",
    baseHpBias: 0.98,
    mechanicWeights: {
      slow: 64,
      suppress: 42,
      stun_duration_ms: 26,
      interrupt_skip_count: 20,
      dodge_chance: 10
    },
    nameParts: {
      prefixes: ["Red", "Howling", "Splintered", "Fevered", "Ash"],
      nouns: ["Ravager", "Butcher", "Breaker", "Mauler", "Hotblood"]
    }
  },
  {
    id: "warden",
    name: "Warden",
    tone: "structured defenses, gatekeeping checks",
    baseHpBias: 1.16,
    mechanicWeights: {
      armor: 44,
      block: 42,
      poison_resistance: 32,
      absorb: 28,
      cleanse_threshold: 18
    },
    nameParts: {
      prefixes: ["Oathbound", "Cinctured", "Candlelit", "Brass", "Vault"],
      nouns: ["Keeper", "Marshal", "Jailer", "Watch", "Custodian"]
    }
  },
  {
    id: "bogborn",
    name: "Bogborn",
    tone: "messy sustain and poison friction",
    baseHpBias: 1.08,
    mechanicWeights: {
      suppress: 50,
      poison_resistance: 40,
      cleanse_threshold: 34,
      absorb: 22,
      slow: 16
    },
    nameParts: {
      prefixes: ["Mire", "Sodden", "Moss", "Brackish", "Fen"],
      nouns: ["Thing", "Gnawer", "Hermit", "Slug", "Sumpguard"]
    }
  }
];
