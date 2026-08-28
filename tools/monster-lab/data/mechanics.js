"use strict";

window.MonsterLabMechanics = [
  {
    id: "armor",
    godotField: "armor",
    name: "Armor",
    shortName: "Armor",
    description: "Reduces physical damage. Negative armor increases physical damage taken.",
    tags: ["physical", "mitigation", "shred-check"],
    matchup: {
      identity: "armored physical mitigation",
      pressure: "pressures direct physical hits that do not bring armor shred or strong scaling",
      counterplay: "answers well to armor reduction, magical damage, poison, or larger individual hits",
      route: "signals a slower physical-check route node"
    },
    valueLabel: "armor",
    min: 0,
    max: 120,
    exportScale: 1,
    baseCost: 8,
    costPerValue: 0.44,
    effectiveHpPerValue: 0.012,
    poisonModifier: 0.0,
    burstModifier: -0.18,
    sustainedModifier: -0.08,
    curves: {
      1: [4, 14],
      2: [12, 28],
      3: [24, 44],
      4: [38, 62],
      5: [56, 88],
      6: [78, 115]
    }
  },
  {
    id: "dodge_chance",
    godotField: "dodge_chance",
    name: "Dodge",
    shortName: "Dodge",
    description: "Chance to avoid physical attacks completely.",
    tags: ["physical", "avoidance", "reliability-check"],
    matchup: {
      identity: "evasive avoidance",
      pressure: "pressures builds that depend on a few important direct weapon hits landing",
      counterplay: "answers well to reliable damage, damage-over-time, or repeated low-commitment attacks",
      route: "signals a reliability-check route node"
    },
    valueLabel: "dodge %",
    min: 0,
    max: 40,
    exportScale: 0.01,
    baseCost: 12,
    costPerValue: 1.45,
    effectiveHpPerValue: 0.014,
    poisonModifier: 0.1,
    burstModifier: -0.24,
    sustainedModifier: -0.12,
    curves: {
      1: [3, 7],
      2: [6, 12],
      3: [10, 18],
      4: [15, 25],
      5: [22, 32],
      6: [28, 38]
    }
  },
  {
    id: "crit_negation",
    godotField: "crit_negation",
    name: "Crit Negation",
    shortName: "Crit Neg",
    description: "Critical hits still happen, but deal less bonus damage.",
    tags: ["physical", "crit-check", "burst-check"],
    matchup: {
      identity: "anti-crit burst control",
      pressure: "pressures crit-heavy burst plans that rely on bonus damage spikes",
      counterplay: "answers well to non-crit scaling, steady damage, poison, or flat damage bonuses",
      route: "signals a burst-check route node"
    },
    valueLabel: "crit negation %",
    min: 0,
    max: 80,
    exportScale: 0.01,
    baseCost: 10,
    costPerValue: 0.8,
    effectiveHpPerValue: 0.006,
    poisonModifier: 0.08,
    burstModifier: -0.26,
    sustainedModifier: -0.04,
    curves: {
      1: [8, 18],
      2: [16, 28],
      3: [24, 42],
      4: [36, 56],
      5: [50, 68],
      6: [62, 78]
    }
  },
  {
    id: "block",
    godotField: "block",
    name: "Block",
    shortName: "Block",
    description: "Reduces incoming physical damage by a flat amount.",
    tags: ["physical", "flat-reduction", "multi-hit-check"],
    matchup: {
      identity: "flat physical blocking",
      pressure: "pressures rapid small-hit physical builds and low base-damage attacks",
      counterplay: "answers well to heavier single hits, magical damage, poison, or block bypass",
      route: "signals a multi-hit-check route node"
    },
    valueLabel: "blocked damage",
    min: 0,
    max: 24,
    exportScale: 1,
    baseCost: 9,
    costPerValue: 2.9,
    effectiveHpPerValue: 0.02,
    poisonModifier: 0.12,
    burstModifier: -0.16,
    sustainedModifier: -0.2,
    curves: {
      1: [1, 3],
      2: [3, 6],
      3: [5, 10],
      4: [8, 14],
      5: [12, 19],
      6: [16, 23]
    }
  },
  {
    id: "poison_resistance",
    godotField: "poison_resistance",
    name: "Resistance",
    shortName: "Resist",
    description: "Reduces magical damage by a percentage.",
    tags: ["magical", "mitigation", "poison-check"],
    matchup: {
      identity: "magical resistance",
      pressure: "pressures poison and magical builds that expect percentage scaling to carry the fight",
      counterplay: "answers well to physical damage, resistance shred, or mixed damage plans",
      route: "signals an anti-poison route node"
    },
    valueLabel: "resistance %",
    min: 0,
    max: 80,
    exportScale: 0.01,
    baseCost: 7,
    costPerValue: 0.54,
    effectiveHpPerValue: 0.01,
    poisonModifier: -0.36,
    burstModifier: -0.04,
    sustainedModifier: -0.08,
    curves: {
      1: [3, 10],
      2: [8, 20],
      3: [16, 32],
      4: [26, 46],
      5: [38, 62],
      6: [54, 76]
    }
  },
  {
    id: "absorb",
    godotField: "absorb",
    name: "Absorb",
    shortName: "Absorb",
    description: "Reduces incoming magical damage by a flat amount.",
    tags: ["magical", "flat-reduction", "dot-check"],
    matchup: {
      identity: "flat magical absorption",
      pressure: "pressures small poison ticks and repeated low-damage magical effects",
      counterplay: "answers well to larger poison ticks, physical damage, or non-magical scaling",
      route: "signals a damage-over-time check route node"
    },
    valueLabel: "absorbed damage",
    min: 0,
    max: 18,
    exportScale: 1,
    baseCost: 9,
    costPerValue: 3.2,
    effectiveHpPerValue: 0.018,
    poisonModifier: -0.3,
    burstModifier: -0.04,
    sustainedModifier: -0.16,
    curves: {
      1: [1, 2],
      2: [2, 4],
      3: [3, 7],
      4: [5, 10],
      5: [8, 14],
      6: [12, 18]
    }
  },
  {
    id: "cleanse_threshold",
    godotField: "cleanse_threshold",
    name: "Cleanse",
    shortName: "Cleanse",
    description: "Periodically clears all debuff stacks after enough attacks.",
    tags: ["debuff", "cleanse", "poison-check"],
    matchup: {
      identity: "debuff cleansing",
      pressure: "pressures poison stacking and debuff plans that need long uninterrupted uptime",
      counterplay: "answers well to burst windows, direct physical damage, or debuffs that rebuild quickly",
      route: "signals a poison-stack check route node"
    },
    valueLabel: "attack threshold",
    min: 1,
    max: 8,
    exportScale: 1,
    invertCost: true,
    baseCost: 18,
    costPerValue: 5.2,
    effectiveHpPerValue: 0.012,
    poisonModifier: -0.42,
    burstModifier: 0.08,
    sustainedModifier: -0.1,
    conflicts: ["poison_resistance"],
    curves: {
      1: [6, 8],
      2: [5, 7],
      3: [4, 6],
      4: [3, 5],
      5: [2, 4],
      6: [1, 3]
    }
  },
  {
    id: "suppress",
    godotField: "suppress",
    name: "Suppress",
    shortName: "Suppress",
    description: "Damage-over-time effects tick less often.",
    tags: ["debuff", "dot-timing", "poison-check"],
    matchup: {
      identity: "damage-over-time suppression",
      pressure: "pressures poison and burn-style builds by stretching their tick timing",
      counterplay: "answers well to direct attacks, front-loaded poison, or mixed non-DOT damage",
      route: "signals a DOT timing route node"
    },
    valueLabel: "DOT delay %",
    min: 0,
    max: 100,
    exportScale: 0.01,
    baseCost: 11,
    costPerValue: 0.78,
    effectiveHpPerValue: 0.007,
    poisonModifier: -0.38,
    burstModifier: 0.08,
    sustainedModifier: -0.12,
    curves: {
      1: [8, 16],
      2: [14, 26],
      3: [24, 40],
      4: [36, 58],
      5: [52, 78],
      6: [70, 95]
    }
  },
  {
    id: "slow",
    godotField: "slow",
    name: "Slow",
    shortName: "Slow",
    description: "Slows the player's attack speed.",
    tags: ["timing", "attack-speed-check", "sustained-check"],
    matchup: {
      identity: "attack-speed disruption",
      pressure: "pressures sustained DPS builds that need many actions inside the fight window",
      counterplay: "answers well to burst damage, passive effects, or fewer high-impact actions",
      route: "signals a tempo-tax route node"
    },
    valueLabel: "slow %",
    min: 0,
    max: 80,
    exportScale: 0.01,
    baseCost: 12,
    costPerValue: 0.9,
    effectiveHpPerValue: 0.009,
    poisonModifier: -0.06,
    burstModifier: 0.04,
    sustainedModifier: -0.28,
    curves: {
      1: [6, 12],
      2: [10, 20],
      3: [18, 32],
      4: [28, 46],
      5: [42, 62],
      6: [56, 76]
    }
  },
  {
    id: "stun_duration_ms",
    godotField: "stun_duration_ms",
    name: "Stun",
    shortName: "Stun",
    description: "Pauses the player's current attack sequence. Runtime behavior is deferred until the timing-disruption pass.",
    tags: ["timing", "preview-only", "disruption"],
    matchup: {
      identity: "burst-triggered stun preview",
      pressure: "pressures large direct-hit burst windows once timing disruption exists",
      counterplay: "answers well to smaller hit packets, poison, or staggered damage windows",
      route: "signals a future timing-disruption route node"
    },
    valueLabel: "stun ms",
    extraFields: [
      {
        id: "stun_trigger_hit_percent",
        label: "Hit Threshold %",
        description: "Stun triggers when one direct hit deals at least this percent of monster max HP.",
        min: 1,
        max: 100,
        step: 1,
        default: 12,
        valueLabel: "% max HP"
      }
    ],
    min: 0,
    max: 1200,
    exportScale: 1,
    previewOnly: true,
    baseCost: 14,
    costPerValue: 0.06,
    effectiveHpPerValue: 0.0005,
    poisonModifier: -0.02,
    burstModifier: -0.08,
    sustainedModifier: -0.16,
    curves: {
      1: [100, 200],
      2: [150, 300],
      3: [250, 450],
      4: [400, 650],
      5: [600, 900],
      6: [800, 1100]
    }
  },
  {
    id: "interrupt_skip_count",
    godotField: "interrupt_skip_count",
    name: "Interrupt",
    shortName: "Interrupt",
    description: "Cancels one direct attack skill and skips that same skill's future macro triggers. Other skills can still cast. Runtime behavior is deferred until the timing-disruption pass.",
    tags: ["timing", "preview-only", "disruption"],
    matchup: {
      identity: "repetition interrupt preview",
      pressure: "pressures builds that repeat one direct attack skill as their whole damage engine",
      counterplay: "answers well to mixed skill rotations, poison, passive damage, or varied direct attacks",
      route: "signals a future anti-repetition route node"
    },
    valueLabel: "skipped casts",
    extraFields: [
      {
        id: "interrupt_repeat_threshold",
        label: "Repeat Threshold",
        description: "Interrupt triggers when the same direct skill is used this many times in a row.",
        min: 2,
        max: 12,
        step: 1,
        default: 3,
        valueLabel: "same-skill triggers"
      }
    ],
    min: 0,
    max: 3,
    exportScale: 1,
    previewOnly: true,
    baseCost: 16,
    costPerValue: 18,
    effectiveHpPerValue: 0.018,
    poisonModifier: 0.04,
    burstModifier: -0.18,
    sustainedModifier: -0.22,
    curves: {
      1: [1, 1],
      2: [1, 1],
      3: [1, 2],
      4: [1, 2],
      5: [2, 2],
      6: [2, 3]
    }
  }
];
