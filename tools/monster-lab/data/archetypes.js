"use strict";

window.MonsterLabArchetypes = [
  {
    id: "stonewall",
    name: "Stonewall",
    tone: "slow, blunt, hard to crack",
    baseHpBias: 1.24,
    mechanicWeights: {
      armor: 70,
      shielded_hide: 42,
      regeneration: 18,
      enrage: 10,
      resistance: 8
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
      resistance: 64,
      poison_cleanse: 42,
      regeneration: 24,
      armor: 12,
      shielded_hide: 8
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
      evasion: 70,
      enrage: 28,
      thorns: 20,
      armor: 8,
      resistance: 6
    },
    nameParts: {
      prefixes: ["Quick", "Velvet", "Needle", "Laughing", "Silver"],
      nouns: ["Cutthroat", "Fencer", "Knifewhisper", "Blade", "Rake"]
    }
  },
  {
    id: "berserker",
    name: "Berserker",
    tone: "low patience, high timer pressure",
    baseHpBias: 0.98,
    mechanicWeights: {
      enrage: 72,
      thorns: 36,
      regeneration: 14,
      armor: 10,
      evasion: 10
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
      shielded_hide: 58,
      armor: 38,
      resistance: 30,
      regeneration: 16,
      poison_cleanse: 10
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
      regeneration: 48,
      resistance: 36,
      poison_cleanse: 24,
      thorns: 16,
      armor: 10
    },
    nameParts: {
      prefixes: ["Mire", "Sodden", "Moss", "Brackish", "Fen"],
      nouns: ["Thing", "Gnawer", "Hermit", "Slug", "Sumpguard"]
    }
  }
];
