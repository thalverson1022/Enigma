"use strict";

const CATEGORIES = {
  BASIC: "basic",
  RARE: "rare",
  SPECIAL: "special",
};

const VALUE_KINDS = {
  FLAT: "flat",
  PERCENT: "percent",
  CHANCE: "chance",
  STACKS: "stacks",
  BINARY: "binary",
};

const gearSlots = ["weapon", "helm", "armor", "trinket", "charm"];
const proceduralRarities = ["basic", "master", "epic", "cursed", "chaos", "unique"];

const rarityLabels = {
  crude: "Crude",
  basic: "Basic",
  master: "Master",
  epic: "Epic",
  cursed: "Cursed",
  chaos: "Chaos",
  unique: "Unique",
  legendary: "Legendary",
};

const slotLabels = {
  weapon: "Weapon",
  helm: "Helm",
  armor: "Armor",
  trinket: "Trinket",
  charm: "Charm",
};

const rogueFamilies = {
  weapon: "Dagger",
  helm: "Hood",
  armor: "Doublet",
  trinket: "Ring",
  charm: "Necklace",
};

function special(label) {
  return {
    label,
    category: CATEGORIES.SPECIAL,
    valueKind: VALUE_KINDS.BINARY,
    drawbackAllowed: false,
    prefix: "Singular",
    suffix: "Singularity",
  };
}

const statDefinitions = {
  base_damage: stat("Base Damage", CATEGORIES.BASIC, VALUE_KINDS.FLAT, "Keen", "Force"),
  percent_physical_damage: stat("Percent Physical Damage", CATEGORIES.BASIC, VALUE_KINDS.PERCENT, "Brutal", "Brutality"),
  increased_attack_speed: stat("Increased Attack Speed", CATEGORIES.BASIC, VALUE_KINDS.PERCENT, "Swift", "Speed"),
  crit_chance: stat("Crit Chance", CATEGORIES.BASIC, VALUE_KINDS.CHANCE, "Sharp", "Sharpness"),
  crit_damage: stat("Crit Damage", CATEGORIES.BASIC, VALUE_KINDS.PERCENT, "Savage", "Savagery"),
  base_elemental_damage: stat("Base Elemental Damage", CATEGORIES.BASIC, VALUE_KINDS.FLAT, "Venomous", "Venom"),
  percent_elemental_damage: stat("Percent Elemental Damage", CATEGORIES.BASIC, VALUE_KINDS.PERCENT, "Toxic", "Toxins"),
  increased_shred_stacks: stat("Increased Shred Stacks", CATEGORIES.BASIC, VALUE_KINDS.STACKS, "Rending", "Rending"),
  increased_decay_stacks: stat("Increased Decay Stacks", CATEGORIES.BASIC, VALUE_KINDS.STACKS, "Withering", "Withering"),
  increased_elemental_stacks: stat("Increased Elemental Stacks", CATEGORIES.BASIC, VALUE_KINDS.STACKS, "Poisoned", "Poisoning"),
  increased_gold: stat("Increased Gold", CATEGORIES.BASIC, VALUE_KINDS.PERCENT, "Greedy", "Avarice"),
  shop_discount: stat("Shop Discount", CATEGORIES.BASIC, VALUE_KINDS.PERCENT, "Bargain", "Bargains"),
  increased_magic_find: stat("Increased Magic Find", CATEGORIES.BASIC, VALUE_KINDS.PERCENT, "Lucky", "Luck"),
  chance_for_retrigger: stat("Chance for Retrigger", CATEGORIES.RARE, VALUE_KINDS.CHANCE, "Echoing", "Echoes", false),
  chance_to_shred: stat("Chance to Shred", CATEGORIES.RARE, VALUE_KINDS.CHANCE, "Serrated", "Shredding", false),
  chance_to_decay: stat("Chance to Decay", CATEGORIES.RARE, VALUE_KINDS.CHANCE, "Decaying", "Decay", false),
  crit_applies_element: stat("Crit Applies Element", CATEGORIES.RARE, VALUE_KINDS.CHANCE, "Infecting", "Infection", false),
  disable_enemy_dodge: special("Enemies can no longer dodge"),
  disable_enemy_block: special("Enemies can no longer block"),
  disable_enemy_absorb: special("Enemies can no longer absorb"),
  disable_enemy_suppress: special("Enemies can no longer suppress"),
  disable_enemy_cleanse: special("Enemies can no longer cleanse"),
  ignore_armor_no_shred: special("You ignore armor, but can no longer apply shred"),
  ignore_resistance_physical_penalty: special("You ignore resistance, but your physical damage is reduced by 50%"),
  double_applied_stacks: special("Stacks you apply are doubled"),
  convert_damage_to_physical: special("All of your damage is now physical"),
  convert_damage_to_magical: special("All of your damage is now magical"),
  all_stats_increased: special("All stats are increased by 20%"),
  immune_to_stun: special("You are immune to stun"),
  immune_to_slow: special("You are immune to slow"),
  immune_to_interrupt: special("You are immune to interrupt"),
};

function stat(label, category, valueKind, prefix, suffix, drawbackAllowed = true) {
  return { label, category, valueKind, drawbackAllowed, prefix, suffix };
}

function weighted(entries) {
  return entries.map(([statId, weight]) => ({ statId, weight }));
}

const slotPools = {
  weapon: {
    basic: weighted([
      ["base_damage", 20],
      ["percent_physical_damage", 15],
      ["crit_damage", 15],
      ["base_elemental_damage", 10],
      ["percent_elemental_damage", 10],
      ["increased_gold", 5],
      ["shop_discount", 5],
      ["increased_magic_find", 5],
    ]),
    rare: weighted([
      ["chance_to_shred", 15],
      ["chance_to_decay", 10],
      ["chance_for_retrigger", 10],
      ["increased_gold", 5],
      ["shop_discount", 5],
      ["increased_magic_find", 5],
    ]),
    special: weighted([
      ["convert_damage_to_physical", 5],
      ["convert_damage_to_magical", 5],
      ["all_stats_increased", 5],
    ]),
  },
  helm: {
    basic: weighted([
      ["percent_physical_damage", 10],
      ["crit_chance", 15],
      ["increased_attack_speed", 15],
      ["base_elemental_damage", 10],
      ["percent_elemental_damage", 10],
      ["increased_shred_stacks", 10],
      ["increased_decay_stacks", 10],
      ["increased_elemental_stacks", 10],
      ["increased_gold", 5],
      ["shop_discount", 5],
      ["increased_magic_find", 5],
    ]),
    rare: weighted([
      ["chance_to_shred", 10],
      ["chance_to_decay", 10],
      ["crit_applies_element", 10],
      ["increased_gold", 5],
      ["shop_discount", 5],
      ["increased_magic_find", 5],
    ]),
    special: weighted([
      ["double_applied_stacks", 5],
      ["ignore_armor_no_shred", 5],
      ["ignore_resistance_physical_penalty", 5],
    ]),
  },
  armor: {
    basic: weighted([
      ["percent_physical_damage", 15],
      ["crit_chance", 10],
      ["percent_elemental_damage", 10],
      ["increased_gold", 15],
      ["increased_shred_stacks", 10],
      ["increased_decay_stacks", 10],
      ["increased_elemental_stacks", 10],
      ["shop_discount", 5],
      ["increased_magic_find", 5],
    ]),
    rare: weighted([
      ["chance_to_shred", 10],
      ["chance_to_decay", 10],
      ["crit_applies_element", 10],
      ["increased_gold", 5],
      ["shop_discount", 5],
      ["increased_magic_find", 5],
    ]),
    special: weighted([
      ["all_stats_increased", 5],
      ["disable_enemy_dodge", 10],
      ["disable_enemy_block", 10],
      ["disable_enemy_absorb", 10],
      ["disable_enemy_suppress", 10],
      ["disable_enemy_cleanse", 10],
      ["immune_to_stun", 5],
      ["immune_to_slow", 5],
      ["immune_to_interrupt", 5],
    ]),
  },
  trinket: {
    basic: weighted([
      ["base_damage", 15],
      ["percent_physical_damage", 15],
      ["crit_chance", 15],
      ["increased_attack_speed", 15],
      ["base_elemental_damage", 10],
      ["percent_elemental_damage", 10],
      ["increased_gold", 5],
      ["shop_discount", 5],
      ["increased_magic_find", 5],
    ]),
    rare: weighted([
      ["chance_for_retrigger", 15],
      ["chance_to_shred", 10],
      ["chance_to_decay", 10],
      ["crit_applies_element", 10],
      ["increased_gold", 5],
      ["shop_discount", 5],
      ["increased_magic_find", 5],
    ]),
    special: weighted([
      ["double_applied_stacks", 5],
      ["disable_enemy_dodge", 10],
      ["disable_enemy_block", 10],
      ["disable_enemy_absorb", 10],
      ["disable_enemy_suppress", 10],
      ["disable_enemy_cleanse", 10],
      ["convert_damage_to_physical", 5],
      ["convert_damage_to_magical", 5],
    ]),
  },
  charm: {
    basic: weighted([
      ["percent_physical_damage", 10],
      ["crit_chance", 20],
      ["increased_attack_speed", 15],
      ["crit_damage", 15],
      ["base_elemental_damage", 10],
      ["percent_elemental_damage", 10],
      ["increased_gold", 5],
      ["increased_shred_stacks", 10],
      ["increased_decay_stacks", 10],
      ["increased_elemental_stacks", 10],
      ["shop_discount", 5],
      ["increased_magic_find", 5],
    ]),
    rare: weighted([
      ["chance_to_shred", 10],
      ["chance_to_decay", 10],
      ["crit_applies_element", 15],
      ["increased_gold", 5],
      ["shop_discount", 5],
      ["increased_magic_find", 5],
    ]),
    special: weighted([
      ["ignore_armor_no_shred", 5],
      ["ignore_resistance_physical_penalty", 5],
      ["double_applied_stacks", 5],
      ["disable_enemy_dodge", 10],
      ["disable_enemy_block", 10],
      ["disable_enemy_absorb", 10],
      ["disable_enemy_suppress", 10],
      ["disable_enemy_cleanse", 10],
    ]),
  },
};

const valueRanges = {
  weapon: {
    base_damage: [2, 5],
    percent_physical_damage: [0.06, 0.12],
    crit_damage: [0.3, 0.45],
    base_elemental_damage: [3, 6],
    percent_elemental_damage: [0.18, 0.24],
    increased_gold: [0.4, 0.6],
    shop_discount: [0.05, 0.1],
    increased_magic_find: [0.15, 0.2],
    chance_to_shred: [0.08, 0.1],
    chance_to_decay: [0.08, 0.1],
    chance_for_retrigger: [0.05, 0.08],
  },
  helm: {
    percent_physical_damage: [0.12, 0.15],
    crit_chance: [0.018, 0.048],
    increased_attack_speed: [0.03, 0.072],
    base_elemental_damage: [4, 10],
    percent_elemental_damage: [0.15, 0.21],
    increased_shred_stacks: [1, 2],
    increased_decay_stacks: [1, 2],
    increased_elemental_stacks: [1, 2],
    increased_gold: [0.8, 1],
    shop_discount: [0.05, 0.1],
    increased_magic_find: [0.15, 0.2],
    chance_to_shred: [0.08, 0.1],
    chance_to_decay: [0.08, 0.1],
    crit_applies_element: [0.2, 0.3],
  },
  armor: {
    percent_physical_damage: [0.06, 0.12],
    crit_chance: [0.012, 0.024],
    percent_elemental_damage: [0.18, 0.24],
    increased_gold: [0.4, 0.6],
    increased_shred_stacks: [1, 2],
    increased_decay_stacks: [1, 2],
    increased_elemental_stacks: [1, 2],
    shop_discount: [0.05, 0.1],
    increased_magic_find: [0.15, 0.2],
    chance_to_shred: [0.08, 0.1],
    chance_to_decay: [0.08, 0.1],
    crit_applies_element: [0.1, 0.2],
  },
  trinket: {
    base_damage: [4, 6],
    percent_physical_damage: [0.09, 0.15],
    crit_chance: [0.024, 0.036],
    increased_attack_speed: [0.048, 0.06],
    base_elemental_damage: [5, 8],
    percent_elemental_damage: [0.12, 0.18],
    increased_gold: [0.2, 0.4],
    shop_discount: [0.05, 0.1],
    increased_magic_find: [0.15, 0.2],
    chance_for_retrigger: [0.03, 0.06],
    chance_to_shred: [0.08, 0.1],
    chance_to_decay: [0.08, 0.1],
    crit_applies_element: [0.1, 0.15],
  },
  charm: {
    percent_physical_damage: [0.09, 0.15],
    crit_chance: [0.036, 0.048],
    increased_attack_speed: [0.06, 0.09],
    crit_damage: [0.24, 0.36],
    base_elemental_damage: [6, 10],
    percent_elemental_damage: [0.18, 0.24],
    increased_gold: [0.3, 0.6],
    increased_shred_stacks: [1, 2],
    increased_decay_stacks: [1, 2],
    increased_elemental_stacks: [1, 2],
    shop_discount: [0.05, 0.1],
    increased_magic_find: [0.15, 0.2],
    chance_to_shred: [0.08, 0.1],
    chance_to_decay: [0.08, 0.1],
    crit_applies_element: [0.12, 0.18],
  },
};

const categoryValueRanges = {
  rare: {
    weapon: {
      increased_gold: [0.44, 0.66],
      shop_discount: [0.06, 0.11],
      increased_magic_find: [0.17, 0.22],
    },
    helm: {
      increased_gold: [0.88, 1.1],
      shop_discount: [0.06, 0.11],
      increased_magic_find: [0.17, 0.22],
    },
    armor: {
      increased_gold: [0.44, 0.66],
      shop_discount: [0.06, 0.11],
      increased_magic_find: [0.17, 0.22],
    },
    trinket: {
      increased_gold: [0.22, 0.44],
      shop_discount: [0.06, 0.11],
      increased_magic_find: [0.17, 0.22],
    },
    charm: {
      increased_gold: [0.33, 0.66],
      shop_discount: [0.06, 0.11],
      increased_magic_find: [0.17, 0.22],
    },
  },
};

const rarityMultipliers = {
  basic: 1,
  master: 1.75,
  epic: 2,
  cursed: 2.5,
  cursedDrawback: -2.5,
  chaos: 3,
  chaosDrawback: -3,
  unique: 2,
};

const rarityRollPlans = {
  basic: [{ category: CATEGORIES.BASIC }],
  master: [{ category: CATEGORIES.BASIC }, { category: CATEGORIES.BASIC }],
  epic: [
    { category: CATEGORIES.BASIC },
    { category: CATEGORIES.BASIC },
    { category: CATEGORIES.RARE },
  ],
  cursed: [
    { category: CATEGORIES.BASIC },
    { category: CATEGORIES.BASIC },
    { category: CATEGORIES.RARE },
    { category: CATEGORIES.BASIC, isDrawback: true },
  ],
  unique: [
    { category: CATEGORIES.BASIC },
    { category: CATEGORIES.BASIC },
    { category: CATEGORIES.BASIC },
    { category: CATEGORIES.RARE },
    { category: CATEGORIES.SPECIAL },
  ],
};

const chaosOutcomes = [
  { outcome: "basic_positive", category: CATEGORIES.BASIC, isDrawback: false, weight: 5 },
  { outcome: "rare_positive", category: CATEGORIES.RARE, isDrawback: false, weight: 4 },
  { outcome: "basic_drawback", category: CATEGORIES.BASIC, isDrawback: true, weight: 5 },
];
const chaosRollCount = 4;

const rarityPresets = {
  early: { basic: 58, master: 26, epic: 10, cursed: 4, chaos: 1, unique: 1 },
  mid: { basic: 34, master: 30, epic: 20, cursed: 8, chaos: 4, unique: 4 },
  late: { basic: 18, master: 25, epic: 28, cursed: 12, chaos: 8, unique: 9 },
  highVariance: { basic: 22, master: 18, epic: 20, cursed: 16, chaos: 14, unique: 10 },
};

const rarityCurveAnchors = {
  early: {
    start: { basic: 66, master: 24, epic: 6, cursed: 2, chaos: 1, unique: 1 },
    end: { basic: 42, master: 30, epic: 16, cursed: 7, chaos: 2, unique: 3 },
  },
  mid: {
    start: { basic: 48, master: 30, epic: 14, cursed: 5, chaos: 1, unique: 2 },
    end: { basic: 24, master: 28, epic: 25, cursed: 11, chaos: 5, unique: 7 },
  },
  late: {
    start: { basic: 32, master: 29, epic: 22, cursed: 9, chaos: 3, unique: 5 },
    end: { basic: 12, master: 22, epic: 31, cursed: 14, chaos: 9, unique: 12 },
  },
  highVariance: {
    start: { basic: 32, master: 20, epic: 18, cursed: 13, chaos: 10, unique: 7 },
    end: { basic: 12, master: 14, epic: 20, cursed: 18, chaos: 22, unique: 14 },
  },
};

const rarityCurveDepthOverrides = {
  early: {
    1: { basic: 65, master: 23, epic: 6, cursed: 2, chaos: 3, unique: 1 },
    6: { basic: 54, master: 26, epic: 10, cursed: 4, chaos: 4, unique: 2 },
    12: { basic: 41, master: 29, epic: 15, cursed: 7, chaos: 5, unique: 3 },
  },
};

const baseline = {
  seed: "1001",
  randomSeed: false,
  activePreset: "custom",
  contractDepth: 1,
  startingGold: 80,
  shopSize: 4,
  valueScale: 1,
  batchSize: 1000,
  rerollCostBase: 5,
  rerollCostStep: 5,
  rarityMode: "curve",
  rarityCurvePreset: "early",
  rarityWeights: structuredClone(rarityPresets.early),
  slotWeights: { weapon: 20, helm: 20, armor: 20, trinket: 20, charm: 20 },
};

const quickSimulationPresets = {
  earlyRun: {
    label: "Early Run",
    contractDepth: 2,
    rarityMode: "curve",
    rarityCurvePreset: "early",
    valueScale: 0.95,
    batchSize: 400,
    shopSize: 4,
    seed: "early-run",
  },
  midRun: {
    label: "Mid Run",
    contractDepth: 6,
    rarityMode: "curve",
    rarityCurvePreset: "mid",
    valueScale: 1,
    batchSize: 700,
    shopSize: 4,
    seed: "mid-run",
  },
  lateRun: {
    label: "Late Run",
    contractDepth: 10,
    rarityMode: "curve",
    rarityCurvePreset: "late",
    valueScale: 1.08,
    batchSize: 1000,
    shopSize: 5,
    seed: "late-run",
  },
  highVariance: {
    label: "High Variance",
    contractDepth: 12,
    rarityMode: "curve",
    rarityCurvePreset: "highVariance",
    valueScale: 1.15,
    batchSize: 1200,
    shopSize: 5,
    seed: "high-variance",
  },
};

const state = {
  config: structuredClone(baseline),
  shopIndex: 0,
  rerollCount: 0,
  currentGold: baseline.startingGold,
  goldSpent: 0,
  shopItems: [],
  seenItems: [],
  notableItem: null,
};

const elements = {
  resetButton: document.querySelector("#reset-button"),
  generateButton: document.querySelector("#generate-button"),
  rerollButton: document.querySelector("#reroll-button"),
  simulateButton: document.querySelector("#simulate-button"),
  seedInput: document.querySelector("#seed-input"),
  randomSeed: document.querySelector("#random-seed"),
  simulationPreset: document.querySelector("#simulation-preset"),
  presetReadout: document.querySelector("#preset-readout"),
  contractDepth: document.querySelector("#contract-depth"),
  startingGold: document.querySelector("#starting-gold"),
  shopSize: document.querySelector("#shop-size"),
  valueScale: document.querySelector("#value-scale"),
  valueReadout: document.querySelector("#value-readout"),
  batchSize: document.querySelector("#batch-size"),
  rerollCostBase: document.querySelector("#reroll-cost-base"),
  rerollCostStep: document.querySelector("#reroll-cost-step"),
  rarityMode: document.querySelector("#rarity-mode"),
  rarityCurvePreset: document.querySelector("#rarity-curve-preset"),
  curveReadout: document.querySelector("#curve-readout"),
  tierControls: document.querySelector("#tier-controls"),
  slotControls: document.querySelector("#slot-controls"),
  affixControls: document.querySelector("#affix-controls"),
  tierTotal: document.querySelector("#tier-total"),
  slotTotal: document.querySelector("#slot-total"),
  affixTotal: document.querySelector("#affix-total"),
  seedReadout: document.querySelector("#seed-readout"),
  shopNote: document.querySelector("#shop-note"),
  currentGold: document.querySelector("#current-gold"),
  rerollCount: document.querySelector("#reroll-count"),
  goldSpent: document.querySelector("#gold-spent"),
  nextRerollCost: document.querySelector("#next-reroll-cost"),
  amazingSeen: document.querySelector("#amazing-seen"),
  shopGrid: document.querySelector("#shop-grid"),
  bestScore: document.querySelector("#best-score"),
  bestItem: document.querySelector("#best-item"),
  distribution: document.querySelector("#distribution"),
  totalItemsSeen: document.querySelector("#total-items-seen"),
  simulationResults: document.querySelector("#simulation-results"),
};

function createMulberry32(seed) {
  let stateValue = seed >>> 0;
  return () => {
    stateValue = (stateValue + 0x6d2b79f5) >>> 0;
    let value = stateValue;
    value = Math.imul(value ^ (value >>> 15), value | 1);
    value ^= value + Math.imul(value ^ (value >>> 7), value | 61);
    return ((value ^ (value >>> 14)) >>> 0) / 4294967296;
  };
}

function hashSeed(seed) {
  const seedText = String(seed);
  let hash = 2166136261;
  for (let index = 0; index < seedText.length; index += 1) {
    hash ^= seedText.charCodeAt(index);
    hash = Math.imul(hash, 16777619);
  }
  return hash >>> 0;
}

function rngFrom(seed) {
  return createMulberry32(hashSeed(seed));
}

function createRandomSeed() {
  const bytes = new Uint32Array(2);
  if (typeof crypto !== "undefined" && typeof crypto.getRandomValues === "function") {
    crypto.getRandomValues(bytes);
  } else {
    bytes[0] = Math.floor(Math.random() * 0xffffffff);
    bytes[1] = Date.now() >>> 0;
  }
  return `random-${bytes[0].toString(36)}-${bytes[1].toString(36)}`;
}

function pickWeighted(entries, random) {
  const candidates = entries.filter((entry) => Number(entry.weight) > 0);
  const total = candidates.reduce((sum, entry) => sum + Number(entry.weight), 0);
  if (!candidates.length || total <= 0) {
    return null;
  }
  let roll = random() * total;
  for (const entry of candidates) {
    roll -= Number(entry.weight);
    if (roll <= 0) {
      return entry.value;
    }
  }
  return candidates[candidates.length - 1].value;
}

function clampNumber(value, min, max, fallback) {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) {
    return fallback;
  }
  return Math.min(max, Math.max(min, parsed));
}

function applyCurrentInputs() {
  state.config.seed = String(elements.seedInput.value || baseline.seed).trim() || baseline.seed;
  state.config.randomSeed = Boolean(elements.randomSeed.checked);
  state.config.activePreset = elements.simulationPreset.value === "custom" || quickSimulationPresets[elements.simulationPreset.value]
    ? elements.simulationPreset.value
    : baseline.activePreset;
  state.config.contractDepth = clampNumber(elements.contractDepth.value, 1, 12, baseline.contractDepth);
  state.config.startingGold = clampNumber(elements.startingGold.value, 0, 9999, baseline.startingGold);
  state.config.shopSize = clampNumber(elements.shopSize.value, 1, 12, baseline.shopSize);
  state.config.valueScale = clampNumber(elements.valueScale.value, 0.25, 3, baseline.valueScale);
  state.config.batchSize = clampNumber(elements.batchSize.value, 1, 10000, baseline.batchSize);
  state.config.rerollCostBase = clampNumber(elements.rerollCostBase.value, 0, 100, baseline.rerollCostBase);
  state.config.rerollCostStep = clampNumber(elements.rerollCostStep.value, 0, 100, baseline.rerollCostStep);
  state.config.rarityMode = elements.rarityMode.value === "manual" ? "manual" : "curve";
  state.config.rarityCurvePreset = rarityPresets[elements.rarityCurvePreset.value]
    ? elements.rarityCurvePreset.value
    : baseline.rarityCurvePreset;
}

function applyQuickSimulationPreset(presetId) {
  const preset = quickSimulationPresets[presetId];
  if (!preset) {
    state.config.activePreset = "custom";
    elements.simulationPreset.value = "custom";
    render();
    return null;
  }
  state.config = {
    ...state.config,
    ...preset,
    activePreset: presetId,
    randomSeed: false,
    rarityWeights: structuredClone(rarityPresets[preset.rarityCurvePreset] ?? state.config.rarityWeights),
  };
  syncInputsFromConfig();
  setupControls();
  startNewSession();
  return structuredClone(state.config);
}

function effectiveRarityWeights(config) {
  if (config.rarityMode === "manual") {
    return config.rarityWeights;
  }
  return interpolatedRarityCurve(config.rarityCurvePreset, config.contractDepth);
}

function interpolatedRarityCurve(preset, contractDepth) {
  const depthKey = String(clampNumber(contractDepth, 1, 12, 1));
  const override = rarityCurveDepthOverrides[preset]?.[depthKey];
  if (override) {
    return normalizeWeightTotal(override, 100);
  }
  const curve = rarityCurveAnchors[preset] ?? rarityCurveAnchors.early;
  const progress = depthProgress(contractDepth);
  const weights = {};
  for (const rarity of proceduralRarities) {
    const start = Number(curve.start[rarity] ?? 0);
    const end = Number(curve.end[rarity] ?? start);
    weights[rarity] = Math.max(0, Math.round(start + (end - start) * progress));
  }
  return normalizeWeightTotal(weights, 100);
}

function depthProgress(contractDepth) {
  return clampNumber(contractDepth, 1, 12, 1) / 11 - 1 / 11;
}

function normalizeWeightTotal(weights, targetTotal) {
  const normalized = {};
  let total = 0;
  for (const rarity of proceduralRarities) {
    normalized[rarity] = Math.max(0, Math.round(Number(weights[rarity] ?? 0)));
    total += normalized[rarity];
  }
  let delta = targetTotal - total;
  const order = [...proceduralRarities].sort((a, b) => normalized[b] - normalized[a]);
  let index = 0;
  while (delta !== 0 && order.length) {
    const rarity = order[index % order.length];
    if (delta > 0) {
      normalized[rarity] += 1;
      delta -= 1;
    } else if (normalized[rarity] > 0) {
      normalized[rarity] -= 1;
      delta += 1;
    }
    index += 1;
  }
  return normalized;
}

function generationConfigSignature(config) {
  return JSON.stringify({
    depth: config.contractDepth,
    shopSize: config.shopSize,
    valueScale: config.valueScale,
    rarityMode: config.rarityMode,
    rarityCurvePreset: config.rarityCurvePreset,
    rarityWeights: effectiveRarityWeights(config),
    slotWeights: config.slotWeights,
  });
}

function deterministicKeys(config, shopIndex, rerollCount, itemIndex = null, rollIndex = null, purpose = "") {
  const base = [
    config.seed,
    `depth:${config.contractDepth}`,
    `shop:${shopIndex}`,
    `reroll:${rerollCount}`,
    `mode:${config.rarityMode}`,
    `preset:${config.rarityCurvePreset}`,
    `cfg:${hashSeed(generationConfigSignature(config)).toString(16)}`,
  ].join("|");
  const keys = {
    session: String(config.seed),
    shop: base,
  };
  if (itemIndex !== null) {
    keys.item = `${base}|item:${itemIndex}`;
    keys.rarity = `${keys.item}|rarity`;
    keys.slot = `${keys.item}|slot`;
  }
  if (itemIndex !== null && rollIndex !== null) {
    keys.chaos = `${keys.item}|chaos:${rollIndex}`;
    keys.stat = `${keys.item}|stat:${rollIndex}|${purpose}`;
    keys.value = `${keys.item}|value:${rollIndex}|${purpose}`;
  }
  return keys;
}

function shopKey(config, shopIndex, rerollCount) {
  return deterministicKeys(config, shopIndex, rerollCount).shop;
}

function safeSeed(seed) {
  return String(seed).replace(/[^a-z0-9]+/gi, "_").replace(/^_+|_+$/g, "").slice(0, 32) || "seed";
}

function chaosOutcomeKey(itemKey, rollIndex) {
  return `${itemKey}|chaos:${rollIndex}`;
}

function statSelectionKey(itemKey, rollIndex, purpose) {
  return `${itemKey}|stat:${rollIndex}|${purpose}`;
}

function statValueKey(itemKey, rollIndex, statId) {
  return `${itemKey}|value:${rollIndex}|${statId}`;
}

function generateShop(config, shopIndex = 0, rerollCount = 0) {
  const key = shopKey(config, shopIndex, rerollCount);
  return Array.from({ length: config.shopSize }, (_, itemIndex) =>
    generateItem(config, key, shopIndex, rerollCount, itemIndex),
  );
}

function generateItem(config, key, shopIndex, rerollCount, itemIndex) {
  const itemKey = deterministicKeys(config, shopIndex, rerollCount, itemIndex).item;
  const rarity = pickWeighted(
    proceduralRarities.map((rarityId) => ({
      value: rarityId,
      weight: effectiveRarityWeights(config)[rarityId] ?? 0,
    })),
    rngFrom(deterministicKeys(config, shopIndex, rerollCount, itemIndex).rarity),
  ) ?? "basic";
  const slot = pickWeighted(
    gearSlots.map((slotId) => ({ value: slotId, weight: config.slotWeights[slotId] ?? 0 })),
    rngFrom(deterministicKeys(config, shopIndex, rerollCount, itemIndex).slot),
  ) ?? "weapon";
  const rolls = generateRolls(rarity, slot, config, itemKey);
  const item = {
    id: `gear.generated.shop_lab.${safeSeed(config.seed)}.${shopIndex}.${itemIndex}`,
    deterministicKey: itemKey,
    sourceSeed: config.seed,
    sourceContext: "shop_lab",
    shopIndex,
    rerollCount,
    itemIndex,
    contractDepth: config.contractDepth,
    valueScale: config.valueScale,
    rarity,
    rarityKind: "procedural",
    slot,
    family: rogueFamilies[slot],
    rolls,
  };
  item.name = formatGeneratedGearTitle(item);
  item.signature = itemSignature(item);
  item.price = priceForItem(item);
  item.score = scoreItem(item);
  item.flags = itemFlags(item);
  item.summary = createItemSummary(item);
  return item;
}

function normalizedOfferSnapshot(config, shopIndex = 0, rerollCount = 0) {
  return generateShop(structuredClone(config), shopIndex, rerollCount).map((item) => ({
    id: item.id,
    deterministicKey: item.deterministicKey,
    signature: item.signature,
    rarity: item.rarity,
    slot: item.slot,
    family: item.family,
    rolls: item.rolls.map((roll) => ({
      statId: roll.statId,
      category: roll.category,
      marker: roll.marker,
      value: roll.value,
      poolWeight: roll.poolWeight,
      rarityMultiplier: roll.rarityMultiplier,
      chaosOutcome: roll.chaosOutcome,
    })),
  }));
}

function batchSummarySnapshot(config) {
  const items = [];
  for (let shopIndex = 0; shopIndex < config.batchSize; shopIndex += 1) {
    items.push(...generateShop(structuredClone(config), shopIndex, 0));
  }
  const aggregate = aggregateItems(items);
  return {
    itemCount: items.length,
    depth: config.contractDepth,
    manualValueScale: config.valueScale,
    depthValueScale: contractDepthValueScale(config.contractDepth),
    combinedValueScale: combinedValueScale(config),
    rarityMode: config.rarityMode,
    rarityCurvePreset: config.rarityCurvePreset,
    configuredRarityWeights: structuredClone(effectiveRarityWeights(config)),
    ...aggregate,
    signatures: items.map((item) => item.signature),
  };
}

function aggregateItems(items) {
  const rolls = items.flatMap((item) => item.rolls);
  const uniqueItems = items.filter((item) => item.rarity === "unique");
  const uniqueSpecialRolls = uniqueItems.flatMap((item) => item.rolls.filter((roll) => roll.isSpecial));
  const chaosRolls = items.flatMap((item) => item.rarity === "chaos" ? item.rolls : []);
  const cursedItems = items.filter((item) => item.rarity === "cursed");
  const retriggerRolls = rolls.filter((roll) => roll.statId === "chance_for_retrigger");
  return {
    rollCount: rolls.length,
    rarityCounts: countBy(items, (item) => item.rarity),
    slotCounts: countBy(items, (item) => item.slot),
    markerCounts: countBy(rolls, (roll) => roll.marker),
    categoryCounts: countBy(rolls, (roll) => roll.category),
    statCounts: countBy(rolls, (roll) => roll.statId),
    drawbackStatCounts: countBy(rolls.filter((roll) => roll.isDrawback), (roll) => roll.statId),
    specialStatCounts: countBy(rolls.filter((roll) => roll.isSpecial), (roll) => roll.statId),
    uniqueSpecialCounts: countBy(uniqueSpecialRolls, (roll) => roll.statId),
    chaosOutcomeCounts: countBy(chaosRolls, (roll) => roll.chaosOutcome || roll.marker),
    cursedOutcomeCounts: {
      items: cursedItems.length,
      positiveRolls: cursedItems.reduce((sum, item) => sum + item.rolls.filter((roll) => roll.marker === "positive").length, 0),
      rareRolls: cursedItems.reduce((sum, item) => sum + item.rolls.filter((roll) => roll.category === CATEGORIES.RARE).length, 0),
      drawbackRolls: cursedItems.reduce((sum, item) => sum + item.rolls.filter((roll) => roll.marker === "drawback").length, 0),
    },
    cursedSummary: summarizeCursedItems(cursedItems, items.length),
    chaosSummary: summarizeChaosItems(items.filter((item) => item.rarity === "chaos"), items.length),
    retriggerSummary: summarizeRetriggerRisk(items),
    retriggerValues: retriggerRolls.map((roll) => roll.value),
    qualityCounts: countBy(items, (item) => qualityBand(item)),
    valueSummary: summarizeRollValues(rolls),
  };
}

function summarizeCursedItems(cursedItems, totalItems) {
  const rolls = cursedItems.flatMap((item) => item.rolls);
  const positiveRolls = rolls.filter((roll) => roll.marker === "positive");
  const drawbackRolls = rolls.filter((roll) => roll.marker === "drawback");
  const validShapeItems = cursedItems.filter((item) => {
    const basicPositive = item.rolls.filter((roll) => roll.marker === "positive" && roll.category === CATEGORIES.BASIC).length;
    const rarePositive = item.rolls.filter((roll) => roll.marker === "positive" && roll.category === CATEGORIES.RARE).length;
    const drawbacks = item.rolls.filter((roll) => roll.marker === "drawback" && roll.category === CATEGORIES.BASIC).length;
    return basicPositive === 2 && rarePositive === 1 && drawbacks === 1;
  });
  return {
    itemCount: cursedItems.length,
    itemRate: cursedItems.length / Math.max(1, totalItems),
    validShapeItems: validShapeItems.length,
    validShapeRate: validShapeItems.length / Math.max(1, cursedItems.length),
    positiveRollCount: positiveRolls.length,
    drawbackRollCount: drawbackRolls.length,
    positiveAverageAbs: averageAbsValue(positiveRolls),
    drawbackAverageAbs: averageAbsValue(drawbackRolls),
    topPositiveStats: countBy(positiveRolls, (roll) => roll.statId),
    topDrawbackStats: countBy(drawbackRolls, (roll) => roll.statId),
  };
}

function summarizeChaosItems(chaosItems, totalItems) {
  const rolls = chaosItems.flatMap((item) => item.rolls);
  const classificationCounts = countBy(chaosItems, (item) => chaosClassification(item));
  return {
    itemCount: chaosItems.length,
    itemRate: chaosItems.length / Math.max(1, totalItems),
    classificationCounts,
    classificationRates: Object.fromEntries(
      Object.entries(classificationCounts).map(([key, count]) => [key, count / Math.max(1, chaosItems.length)]),
    ),
    outcomeCounts: countBy(rolls, (roll) => roll.chaosOutcome || roll.marker),
    positiveRollCount: rolls.filter((roll) => roll.marker === "positive").length,
    drawbackRollCount: rolls.filter((roll) => roll.marker === "drawback").length,
    positiveAverageAbs: averageAbsValue(rolls.filter((roll) => roll.marker === "positive")),
    drawbackAverageAbs: averageAbsValue(rolls.filter((roll) => roll.marker === "drawback")),
    topPositiveStats: countBy(rolls.filter((roll) => roll.marker === "positive"), (roll) => roll.statId),
    topDrawbackStats: countBy(rolls.filter((roll) => roll.marker === "drawback"), (roll) => roll.statId),
  };
}

function chaosClassification(item) {
  const drawbackCount = item.rolls.filter((roll) => roll.marker === "drawback").length;
  if (drawbackCount === 0) {
    return "all_positive";
  }
  if (drawbackCount === item.rolls.length) {
    return "all_drawback";
  }
  return "mixed";
}

function summarizeRetriggerRisk(items) {
  const retriggerItems = items.filter((item) => item.flags.hasRetrigger);
  const retriggerRolls = retriggerItems.flatMap((item) => item.rolls.filter((roll) => roll.statId === "chance_for_retrigger"));
  const values = retriggerRolls.map((roll) => roll.value).sort((a, b) => b - a);
  const shops = new Map();
  for (const item of retriggerItems) {
    const key = `${item.shopIndex}:${item.rerollCount}`;
    if (!shops.has(key)) {
      shops.set(key, []);
    }
    shops.get(key).push(item);
  }
  const multiRetriggerShopCount = [...shops.values()].filter((shopItems) => shopItems.length > 1).length;
  const topFiveStack = values.slice(0, 5).reduce((sum, value) => sum + value, 0);
  return {
    itemCount: retriggerItems.length,
    itemRate: retriggerItems.length / Math.max(1, items.length),
    rollCount: retriggerRolls.length,
    shopCount: shops.size,
    multiRetriggerShopCount,
    slotCounts: countBy(retriggerItems, (item) => item.slot),
    rarityCounts: countBy(retriggerItems, (item) => item.rarity),
    minValue: values.length ? Math.min(...values) : 0,
    averageValue: values.length ? values.reduce((sum, value) => sum + value, 0) / values.length : 0,
    maxValue: values.length ? Math.max(...values) : 0,
    topFiveStack,
    capProximity: Math.min(1, topFiveStack),
    values,
  };
}

function qualityBand(item) {
  if (item.flags.hasSpecial || item.score >= 90) {
    return "standout";
  }
  if (item.flags.hasDrawback || item.flags.isChaos) {
    return "risky";
  }
  if (item.score >= 55) {
    return "strong";
  }
  return "baseline";
}

function deterministicSelfCheck(config = baseline) {
  const firstOffers = normalizedOfferSnapshot(config, 0, 0);
  const secondOffers = normalizedOfferSnapshot(config, 0, 0);
  const firstBatch = batchSummarySnapshot(config);
  const secondBatch = batchSummarySnapshot(config);
  const rerollOffers = normalizedOfferSnapshot(config, 1, 1);
  const sameOffers = stableStringify(firstOffers) === stableStringify(secondOffers);
  const sameBatch = stableStringify(firstBatch) === stableStringify(secondBatch);
  const distinctReroll = stableStringify(firstOffers) !== stableStringify(rerollOffers);
  return {
    ok: sameOffers && sameBatch && distinctReroll,
    sameOffers,
    sameBatch,
    distinctReroll,
    offerCount: firstOffers.length,
    batchItemCount: firstBatch.itemCount,
  };
}

function readabilitySnapshot(config = baseline) {
  const samples = [];
  for (const rarity of proceduralRarities) {
    for (const slot of gearSlots) {
      samples.push(sampleItemForReadability(config, rarity, slot));
    }
  }
  return samples.map((item) => ({
    rarity: item.rarity,
    slot: item.slot,
    family: item.family,
    name: item.name,
    badges: readabilityBadges(item).map((badge) => badge.label),
    groups: countBy(item.rolls, (roll) => roll.marker),
    labels: item.rolls.map((roll) => roll.label),
    metadataRows: item.rolls.map((roll) => rollMetadataRows(roll).map(([label]) => label)),
    html: createItemCard(item).innerHTML,
  }));
}

function sampleItemForReadability(config, rarity, slot) {
  const sampleConfig = structuredClone(config);
  sampleConfig.rarityMode = "manual";
  sampleConfig.rarityWeights = Object.fromEntries(proceduralRarities.map((rarityId) => [rarityId, rarityId === rarity ? 100 : 0]));
  sampleConfig.slotWeights = Object.fromEntries(gearSlots.map((slotId) => [slotId, slotId === slot ? 100 : 0]));
  return generateShop(sampleConfig, 0, 0)[0];
}

function combinedValueScale(config) {
  return config.valueScale * contractDepthValueScale(config.contractDepth);
}

function valueScaleRows(config) {
  const examples = [
    { slot: "weapon", statId: "base_damage", rarity: "basic", label: "Basic Dagger Base Damage" },
    { slot: "armor", statId: "crit_chance", rarity: "epic", label: "Epic Doublet Crit Chance" },
    { slot: "trinket", statId: "chance_for_retrigger", rarity: "unique", label: "Unique Ring Retrigger" },
    { slot: "charm", statId: "crit_damage", rarity: "chaos", label: "Chaos Necklace Crit Damage" },
  ];
  return examples.map((example) => {
    const definition = statDefinitions[example.statId];
    const range = valueRangeFor(example.slot, example.statId, definition);
    const rarityMultiplier = rarityValueMultiplier(example.rarity, false);
    const depthMultiplier = contractDepthValueScale(config.contractDepth);
    const scaled = range.map((value) =>
      roundValue(value * rarityMultiplier * config.valueScale * depthMultiplier, definition.valueKind, false),
    );
    return {
      ...example,
      range,
      scaled,
      valueKind: definition.valueKind,
      rarityMultiplier,
      depthMultiplier,
      combinedMultiplier: rarityMultiplier * config.valueScale * depthMultiplier,
    };
  });
}

function summarizeRollValues(rolls) {
  const numericRolls = rolls.filter((roll) => !roll.isSpecial && roll.marker !== "invalid");
  const positives = numericRolls.filter((roll) => !roll.isDrawback);
  const drawbacks = numericRolls.filter((roll) => roll.isDrawback);
  return {
    positiveAverageAbs: averageAbsValue(positives),
    drawbackAverageAbs: averageAbsValue(drawbacks),
    byRarityMarker: summarizeValuesBy(numericRolls, (roll) => `${roll.category}:${roll.marker}`),
  };
}

function summarizeValuesBy(rolls, keyFor) {
  const groups = {};
  for (const roll of rolls) {
    const key = keyFor(roll);
    if (!groups[key]) {
      groups[key] = [];
    }
    groups[key].push(roll);
  }
  return Object.fromEntries(
    Object.entries(groups).map(([key, values]) => [key, averageAbsValue(values)]),
  );
}

function averageAbsValue(rolls) {
  if (!rolls.length) {
    return 0;
  }
  return rolls.reduce((sum, roll) => sum + Math.abs(roll.value), 0) / rolls.length;
}

function rarityProbabilityRows(config, counts = null, itemTotal = 0) {
  const weights = effectiveRarityWeights(config);
  const totalWeight = sumWeights(weights) || 1;
  return proceduralRarities.map((rarity) => {
    const configured = Number(weights[rarity] ?? 0) / totalWeight;
    const observed = counts ? Number(counts[rarity] ?? 0) / Math.max(1, itemTotal) : null;
    return {
      rarity,
      label: rarityLabels[rarity],
      weight: Number(weights[rarity] ?? 0),
      configured,
      observed,
    };
  });
}

function generateRolls(rarity, slot, config, itemKey) {
  if (rarity === "chaos") {
    return generateChaosRolls(slot, config, itemKey);
  }
  const used = new Set();
  return (rarityRollPlans[rarity] ?? rarityRollPlans.basic).map((spec, rollIndex) =>
    generateRoll(slot, rarity, spec, config, itemKey, rollIndex, used),
  );
}

function generateChaosRolls(slot, config, itemKey) {
  const rolls = [];
  for (let rollIndex = 0; rollIndex < chaosRollCount; rollIndex += 1) {
    const eligible = chaosOutcomes.filter((outcome) =>
      poolForSpec(slot, outcome).some((entry) => entry.weight > 0),
    );
    const outcome = pickWeighted(
      eligible.map((entry) => ({ value: entry, weight: entry.weight })),
      rngFrom(chaosOutcomeKey(itemKey, rollIndex)),
    );
    if (!outcome) {
      break;
    }
    rolls.push(generateRoll(slot, "chaos", outcome, config, itemKey, rollIndex, new Set()));
  }
  return rolls;
}

function generateRoll(slot, rarity, spec, config, itemKey, rollIndex, used) {
  const pool = poolForSpec(slot, spec).filter((entry) => entry.weight > 0 && !used.has(entry.statId));
  const picked = pickWeighted(
    pool.map((entry) => ({ value: entry, weight: entry.weight })),
    rngFrom(statSelectionKey(itemKey, rollIndex, spec.outcome ?? spec.category)),
  );
  if (!picked) {
    return invalidRoll(spec, rollIndex);
  }
  used.add(picked.statId);
  return buildRoll({
    slot,
    statId: picked.statId,
    poolWeight: picked.weight,
    category: spec.category,
    isDrawback: Boolean(spec.isDrawback),
    rarity,
    config,
    rollIndex,
    itemKey,
    chaosOutcome: spec.outcome ?? "",
  });
}

function poolForSpec(slot, spec) {
  if (spec.isDrawback) {
    return (slotPools[slot]?.basic ?? []).filter((entry) => statDefinitions[entry.statId]?.drawbackAllowed);
  }
  return slotPools[slot]?.[spec.category] ?? [];
}

function invalidRoll(spec, rollIndex) {
  return {
    rollIndex,
    statId: "invalid_roll",
    label: "Invalid Roll",
    category: spec.category,
    poolWeight: 0,
    valueKind: VALUE_KINDS.FLAT,
    rawRange: [0, 0],
    rarityMultiplier: 0,
    depthMultiplier: 1,
    valueScale: 1,
    value: 0,
    isDrawback: Boolean(spec.isDrawback),
    isSpecial: false,
    chaosOutcome: spec.outcome ?? "",
    marker: "invalid",
  };
}

function buildRoll({ slot, statId, poolWeight, category, isDrawback, rarity, config, rollIndex, itemKey, chaosOutcome }) {
  const definition = statDefinitions[statId];
  const rawRange = valueRangeFor(slot, statId, definition, category);
  const rarityMultiplier = rarityValueMultiplier(rarity, isDrawback);
  const depthMultiplier = contractDepthValueScale(config.contractDepth);
  const rawValue = rollRawValue(rawRange, definition.valueKind, rngFrom(statValueKey(itemKey, rollIndex, statId)));
  const value = roundValue(rawValue * rarityMultiplier * config.valueScale * depthMultiplier, definition.valueKind, isDrawback);
  return {
    rollIndex,
    statId,
    label: definition.label,
    category,
    poolWeight,
    valueKind: definition.valueKind,
    rawRange,
    rarityMultiplier,
    depthMultiplier,
    valueScale: config.valueScale,
    value,
    isDrawback,
    isSpecial: category === CATEGORIES.SPECIAL,
    chaosOutcome,
    marker: isDrawback ? "drawback" : category === CATEGORIES.SPECIAL ? "special" : "positive",
  };
}

function valueRangeFor(slot, statId, definition, category = CATEGORIES.BASIC) {
  if (definition.valueKind === VALUE_KINDS.BINARY) {
    return [1, 1];
  }
  const categoryRange = categoryValueRanges[category]?.[slot]?.[statId];
  if (categoryRange) {
    return categoryRange;
  }
  return valueRanges[slot]?.[statId] ?? [0, 0];
}

function rollRawValue(range, kind, random) {
  if (kind === VALUE_KINDS.BINARY) {
    return 1;
  }
  return range[0] + random() * (range[1] - range[0]);
}

function rarityValueMultiplier(rarity, isDrawback) {
  if (rarity === "cursed" && isDrawback) {
    return rarityMultipliers.cursedDrawback;
  }
  if (rarity === "chaos" && isDrawback) {
    return rarityMultipliers.chaosDrawback;
  }
  return rarityMultipliers[rarity] ?? 1;
}

function contractDepthValueScale(contractDepth) {
  return Math.round((1 + depthProgress(contractDepth) * 0.35) * 100) / 100;
}

function roundValue(value, kind, isDrawback) {
  if (kind === VALUE_KINDS.PERCENT || kind === VALUE_KINDS.CHANCE) {
    return Math.round(value * 100) / 100;
  }
  if (kind === VALUE_KINDS.FLAT || kind === VALUE_KINDS.STACKS) {
    const rounded = Math.round(value);
    if (!isDrawback && kind === VALUE_KINDS.STACKS) {
      return Math.max(1, rounded);
    }
    return rounded;
  }
  return value;
}

function formatGeneratedGearTitle(item) {
  const positive = item.rolls.filter((roll) => roll.marker === "positive");
  const first = positive[0];
  const second = positive[1];
  if (!first) {
    return `${rarityLabels[item.rarity]} ${item.family}`;
  }
  const prefix = statDefinitions[first.statId]?.prefix ?? rarityLabels[item.rarity];
  if (!second) {
    return `${prefix} ${item.family}`;
  }
  const suffix = statDefinitions[second.statId]?.suffix ?? rarityLabels[item.rarity];
  return `${prefix} ${item.family} of ${suffix}`;
}

function itemSignature(item) {
  const rollBits = item.rolls.map((roll) =>
    [roll.statId, roll.category, roll.marker, roll.value, roll.chaosOutcome].join(":"),
  );
  return [item.rarity, item.slot, ...rollBits].join("|");
}

function itemFlags(item) {
  return {
    isCursed: item.rarity === "cursed",
    isChaos: item.rarity === "chaos",
    isUnique: item.rarity === "unique",
    hasDrawback: item.rolls.some((roll) => roll.isDrawback),
    hasSpecial: item.rolls.some((roll) => roll.isSpecial),
    hasRetrigger: item.rolls.some((roll) => roll.statId === "chance_for_retrigger"),
  };
}

function readabilityBadges(item) {
  const badges = [
    { label: rarityLabels[item.rarity], kind: `rarity-${item.rarity}` },
    { label: slotLabels[item.slot], kind: `slot-${item.slot}` },
    { label: item.family, kind: "family" },
  ];
  if (item.flags.isChaos) {
    badges.push({ label: "Chaos", kind: "chaos" });
  }
  if (item.flags.isUnique) {
    badges.push({ label: "Unique", kind: "unique" });
  }
  if (item.flags.hasDrawback) {
    badges.push({ label: "Drawback", kind: "drawback" });
  }
  if (item.flags.hasSpecial) {
    badges.push({ label: "Special", kind: "special" });
  }
  if (item.flags.hasRetrigger) {
    badges.push({ label: "Retrigger watch", kind: "watch" });
  }
  return badges;
}

function scoreItem(item) {
  const rarityScore = { basic: 10, master: 24, epic: 40, cursed: 46, chaos: 48, unique: 62 }[item.rarity] ?? 0;
  const positiveCount = item.rolls.filter((roll) => roll.marker === "positive").length;
  const drawbackCount = item.rolls.filter((roll) => roll.marker === "drawback").length;
  const specialCount = item.rolls.filter((roll) => roll.marker === "special").length;
  const rareCount = item.rolls.filter((roll) => roll.category === CATEGORIES.RARE).length;
  return rarityScore + positiveCount * 8 + rareCount * 6 + specialCount * 14 - drawbackCount * 7;
}

function priceForItem(item) {
  const base = { basic: 18, master: 32, epic: 46, cursed: 40, chaos: 55, unique: 70 }[item.rarity] ?? 18;
  return base + Math.max(0, Math.round((item.score - 45) / 5));
}

function createItemSummary(item) {
  const counts = countBy(item.rolls, (roll) => roll.marker);
  return [
    `${item.family}`,
    `${counts.positive ?? 0} positive`,
    `${counts.drawback ?? 0} drawback`,
    `${counts.special ?? 0} special`,
  ].join(" / ");
}

function formatRollValue(roll) {
  if (roll.isSpecial) {
    return roll.label;
  }
  const sign = roll.value > 0 ? "+" : roll.value < 0 ? "-" : "";
  const abs = Math.abs(roll.value);
  if (roll.valueKind === VALUE_KINDS.PERCENT || roll.valueKind === VALUE_KINDS.CHANCE) {
    return `${sign}${Math.round(abs * 100)}% ${roll.label}`;
  }
  return `${sign}${abs} ${roll.label}`;
}

function rollMetadataRows(roll) {
  const range = roll.rawRange[0] === roll.rawRange[1]
    ? formatRangeValue(roll.rawRange[0], roll.valueKind)
    : `${formatRangeValue(roll.rawRange[0], roll.valueKind)}-${formatRangeValue(roll.rawRange[1], roll.valueKind)}`;
  const rows = [
    ["ID", roll.statId],
    ["Category", capitalize(roll.category)],
    ["Weight", `w${roll.poolWeight}`],
    ["Range", range],
    ["Rarity", `${roll.rarityMultiplier.toFixed(2)}x`],
    ["Manual", `${roll.valueScale.toFixed(2)}x`],
    ["Depth", `${roll.depthMultiplier.toFixed(2)}x`],
  ];
  if (roll.chaosOutcome) {
    rows.push(["Chaos", roll.chaosOutcome.replaceAll("_", " ")]);
  }
  return rows;
}

function formatRangeValue(value, kind) {
  if (kind === VALUE_KINDS.PERCENT || kind === VALUE_KINDS.CHANCE) {
    return `${Math.round(value * 100)}%`;
  }
  return String(value);
}

function getNextRerollCost(rerollCount) {
  return state.config.rerollCostBase + rerollCount * state.config.rerollCostStep;
}

function markCustomPreset() {
  state.config.activePreset = "custom";
  elements.simulationPreset.value = "custom";
}

function startNewSession(options = {}) {
  const refreshRandomSeed = options?.refreshRandomSeed !== false;
  const note = options?.note ?? "Generated a Phase 5 shop from visible inputs.";
  applyCurrentInputs();
  if (state.config.randomSeed && refreshRandomSeed) {
    state.config.seed = createRandomSeed();
    elements.seedInput.value = state.config.seed;
  }
  state.shopIndex = 0;
  state.rerollCount = 0;
  state.currentGold = state.config.startingGold;
  state.goldSpent = 0;
  state.seenItems = [];
  state.notableItem = null;
  rollCurrentShop(note);
}

function rerollShop() {
  applyCurrentInputs();
  const cost = getNextRerollCost(state.rerollCount);
  if (state.currentGold < cost) {
    elements.shopNote.textContent = `Need ${cost}g for the next reroll.`;
    render();
    return;
  }
  state.currentGold -= cost;
  state.goldSpent += cost;
  state.rerollCount += 1;
  state.shopIndex += 1;
  rollCurrentShop(`Rerolled for ${cost}g.`);
}

function rollCurrentShop(note) {
  state.shopItems = generateShop(state.config, state.shopIndex, state.rerollCount);
  state.seenItems.push(...state.shopItems);
  for (const item of state.shopItems) {
    if (!state.notableItem || item.score > state.notableItem.score) {
      state.notableItem = item;
    }
  }
  elements.shopNote.textContent = note;
  render();
}

function renderSliderControls(container, entries, weights, labelFor, onChange) {
  container.innerHTML = "";
  for (const entry of entries) {
    const row = document.createElement("label");
    row.className = "slider-row";
    row.innerHTML = `
      <span class="slider-label"><strong>${escapeHtml(labelFor(entry))}</strong><span>${escapeHtml(entry)}</span></span>
      <input type="range" min="0" max="100" step="1" value="${weights[entry] ?? 0}">
      <input class="weight-number" type="number" min="0" max="100" step="1" value="${weights[entry] ?? 0}">
      <span class="probability-readout" data-probability-for="${escapeHtml(entry)}">0.0%</span>
    `;
    const slider = row.querySelector("input[type='range']");
    const number = row.querySelector("input[type='number']");
    const update = (value) => {
      const next = clampNumber(value, 0, 100, weights[entry] ?? 0);
      weights[entry] = next;
      slider.value = String(next);
      number.value = String(next);
      onChange();
    };
    slider.addEventListener("input", () => update(slider.value));
    number.addEventListener("input", () => update(number.value));
    container.append(row);
  }
}

function renderProbabilityReadouts(container, weights) {
  const total = sumWeights(weights);
  for (const readout of container.querySelectorAll("[data-probability-for]")) {
    const key = readout.dataset.probabilityFor;
    const weight = Number(weights[key] || 0);
    readout.textContent = total > 0 ? formatPercent(weight / total) : "0.0%";
  }
}

function setupControls() {
  renderSliderControls(elements.tierControls, proceduralRarities, state.config.rarityWeights, (rarity) => rarityLabels[rarity], () => {
    markCustomPreset();
    render();
  });
  renderSliderControls(elements.slotControls, gearSlots, state.config.slotWeights, (slot) => `${slotLabels[slot]} / ${rogueFamilies[slot]}`, () => {
    markCustomPreset();
    render();
  });
  renderBoundaryReadout();
}

function renderBoundaryReadout() {
  elements.affixControls.innerHTML = `
    <div class="boundary-list">
      <span>Crude: starter Dagger only</span>
      <span>Lucky Coin: fixed Tavern Charm</span>
      <span>Legendary: fixed catalog, P5M10 tuning</span>
      <span>Compatibility gear: excluded</span>
    </div>
  `;
}

function render() {
  applyCurrentInputs();
  elements.seedInput.disabled = state.config.randomSeed;
  elements.seedReadout.textContent = `${state.config.randomSeed ? "Random seed" : "Seed"} ${state.config.seed} / Depth ${state.config.contractDepth}`;
  renderPresetReadout();
  elements.currentGold.textContent = String(state.currentGold);
  elements.rerollCount.textContent = String(state.rerollCount);
  elements.goldSpent.textContent = String(state.goldSpent);
  const nextCost = getNextRerollCost(state.rerollCount);
  elements.nextRerollCost.textContent = `${nextCost}g`;
  elements.rerollButton.textContent = `Reroll ${nextCost}g`;
  elements.rerollButton.disabled = state.currentGold < nextCost;
  elements.amazingSeen.textContent = String(state.seenItems.filter((item) => item.flags.hasDrawback || item.flags.hasSpecial).length);
  elements.tierTotal.textContent = `${sumWeights(effectiveRarityWeights(state.config))} total`;
  elements.slotTotal.textContent = `${sumWeights(state.config.slotWeights)} total`;
  elements.affixTotal.textContent = "fixed boundaries";
  elements.rarityCurvePreset.disabled = state.config.rarityMode === "manual";
  renderProbabilityReadouts(elements.tierControls, effectiveRarityWeights(state.config));
  renderProbabilityReadouts(elements.slotControls, state.config.slotWeights);
  renderCurveReadout();
  renderValueReadout();
  renderShop();
  renderNotableItem();
  renderDistribution();
}

function renderPresetReadout() {
  const preset = quickSimulationPresets[state.config.activePreset];
  if (!preset) {
    elements.presetReadout.innerHTML = `
      <strong>Custom setup</strong>
      <span>Visible controls define this run.</span>
    `;
    return;
  }
  elements.presetReadout.innerHTML = `
    <strong>${escapeHtml(preset.label)}</strong>
    <span>Depth ${preset.contractDepth} / ${capitalize(preset.rarityCurvePreset)} curve / ${preset.valueScale.toFixed(2)}x manual value / ${preset.batchSize} shops</span>
  `;
}

function renderValueReadout() {
  const depthScale = contractDepthValueScale(state.config.contractDepth);
  const combinedScale = combinedValueScale(state.config);
  const examples = valueScaleRows(state.config);
  elements.valueReadout.innerHTML = `
    <strong>Value scaling</strong>
    <div class="value-scale-grid">
      <span>Manual</span><b>${state.config.valueScale.toFixed(2)}x</b>
      <span>Depth</span><b>${depthScale.toFixed(2)}x</b>
      <span>Combined</span><b>${combinedScale.toFixed(2)}x</b>
    </div>
    <div class="value-example-list">
      ${examples.map((example) => `
        <span>${escapeHtml(example.label)}</span>
        <b>${escapeHtml(formatScaledRange(example.scaled, example.valueKind))}</b>
      `).join("")}
    </div>
  `;
}

function renderCurveReadout() {
  const modeLabel = state.config.rarityMode === "manual"
    ? "Manual weights"
    : `${capitalize(state.config.rarityCurvePreset)} curve / depth ${state.config.contractDepth}`;
  const rows = rarityProbabilityRows(state.config);
  elements.curveReadout.innerHTML = `
    <strong>${escapeHtml(modeLabel)}</strong>
    <div class="curve-grid">
      ${rows.map((row) => `
        <span>${escapeHtml(row.label)}</span>
        <b>${row.weight}</b>
        <em>${formatPercent(row.configured)}</em>
      `).join("")}
    </div>
  `;
}

function renderShop() {
  elements.shopGrid.innerHTML = "";
  for (const item of state.shopItems) {
    elements.shopGrid.append(createItemCard(item));
  }
}

function createItemCard(item, compact = false) {
  const card = document.createElement("article");
  card.className = `item-card tier-${item.rarity} slot-${item.slot}`;
  card.innerHTML = `
    <div class="item-card-header">
      <h4>${escapeHtml(item.name)}</h4>
      <span class="slot-badge slot-badge-${item.slot}">${escapeHtml(slotLabels[item.slot])}</span>
    </div>
    <div class="item-meta-line">
      <strong class="tier-badge tier-badge-${item.rarity}">${escapeHtml(rarityLabels[item.rarity])}</strong>
      <span>${escapeHtml(item.family)} / ${escapeHtml(slotLabels[item.slot])}</span>
    </div>
    <div class="affix-list">${renderRollGroups(item.rolls, compact)}</div>
    <span class="score-badge">Lab score ${item.score}</span>
  `;
  return card;
}

function renderRollGroups(rolls, compact) {
  const groups = [
    { marker: "positive" },
    { marker: "drawback" },
    { marker: "special" },
    { marker: "invalid" },
  ];
  return groups.map((group) => {
    const groupRolls = rolls.filter((roll) => roll.marker === group.marker);
    if (!groupRolls.length) {
      return "";
    }
    return `
      <section class="roll-group roll-group-${group.marker}">
        ${groupRolls.map((roll) => renderRollPill(roll, compact)).join("")}
      </section>
    `;
  }).join("");
}

function renderRollPill(roll, compact) {
  return `
    <div class="affix-pill affix-${roll.marker}">
      <div class="roll-mainline">
        <strong>${escapeHtml(formatRollValue(roll))}</strong>
        <span>${escapeHtml(capitalize(roll.category))}</span>
      </div>
    </div>
  `;
}

function renderNotableItem() {
  elements.bestScore.textContent = `Notable ${state.notableItem?.score ?? 0}`;
  elements.bestItem.innerHTML = "";
  if (!state.notableItem) {
    elements.bestItem.className = "best-item empty-note";
    elements.bestItem.textContent = "No shop generated yet.";
    return;
  }
  elements.bestItem.className = "best-item";
  elements.bestItem.append(createItemCard(state.notableItem, true));
}

function renderDistribution() {
  elements.totalItemsSeen.textContent = `${state.seenItems.length} items`;
  if (!state.seenItems.length) {
    elements.distribution.innerHTML = '<p class="empty-note">Generate shops to see Phase 5 distribution.</p>';
    return;
  }
  const aggregate = aggregateItems(state.seenItems);
  elements.distribution.innerHTML = [
    renderBarGroup("Rarity", proceduralRarities, aggregate.rarityCounts, rarityLabels),
    renderBarGroup("Slot", gearSlots, aggregate.slotCounts, slotLabels),
    renderBarGroup("Roll Markers", ["positive", "drawback", "special"], aggregate.markerCounts, markerLabels()),
    renderBarGroup("Categories", [CATEGORIES.BASIC, CATEGORIES.RARE, CATEGORIES.SPECIAL], aggregate.categoryCounts, categoryLabels()),
    renderTopList("Top Stats", aggregate.statCounts, statLabelMap(), 6),
    renderTopList("Drawbacks", aggregate.drawbackStatCounts, statLabelMap(), 4),
    renderTopList("Specials", aggregate.specialStatCounts, statLabelMap(), 4),
    renderBarGroup("Chaos Outcomes", ["basic_positive", "rare_positive", "basic_drawback"], aggregate.chaosOutcomeCounts, chaosOutcomeLabels()),
    renderRiskSummary("Cursed View", cursedSummaryRows(aggregate.cursedSummary)),
    renderRiskSummary("Chaos View", chaosSummaryRows(aggregate.chaosSummary)),
    renderRiskSummary("Retrigger Watch", retriggerSummaryRows(aggregate.retriggerSummary)),
  ].join("");
}

function renderBarGroup(title, keys, counts, labels) {
  const max = Math.max(...keys.map((key) => counts[key] ?? 0), 1);
  const total = keys.reduce((sum, key) => sum + (counts[key] ?? 0), 0) || 1;
  return `
    <h3 class="mini-heading">${escapeHtml(title)}</h3>
    ${keys.map((key) => {
      const count = counts[key] ?? 0;
      const percent = Math.round((count / total) * 100);
      return `
        <div class="bar-row">
          <div class="bar-label"><span>${escapeHtml(labels[key] ?? key)}</span><span>${count} / ${percent}%</span></div>
          <div class="bar-track"><div class="bar-fill" style="width: ${(count / max) * 100}%"></div></div>
        </div>
      `;
    }).join("")}
  `;
}

function renderTopList(title, counts, labels, limit = 5) {
  const rows = topEntries(counts, limit);
  if (!rows.length) {
    return `
      <h3 class="mini-heading">${escapeHtml(title)}</h3>
      <p class="empty-note compact-note">No rolls yet.</p>
    `;
  }
  const total = Object.values(counts).reduce((sum, count) => sum + count, 0) || 1;
  return `
    <h3 class="mini-heading">${escapeHtml(title)}</h3>
    <div class="top-list">
      ${rows.map(([key, count]) => `
        <div><span>${escapeHtml(labels[key] ?? key)}</span><strong>${count} / ${formatPercent(count / total)}</strong></div>
      `).join("")}
    </div>
  `;
}

function renderRiskSummary(title, rows) {
  return `
    <h3 class="mini-heading">${escapeHtml(title)}</h3>
    <div class="risk-summary">
      ${rows.map(([label, value]) => `
        <div><span>${escapeHtml(label)}</span><strong>${escapeHtml(value)}</strong></div>
      `).join("")}
    </div>
  `;
}

function runSimulation() {
  applyCurrentInputs();
  const shopCount = state.config.batchSize;
  const items = [];
  for (let shopIndex = 0; shopIndex < shopCount; shopIndex += 1) {
    items.push(...generateShop(state.config, shopIndex, 0));
  }
  const aggregate = aggregateItems(items);
  const rarityRows = rarityProbabilityRows(state.config, aggregate.rarityCounts, items.length);
  const uniqueSpecialTotal = sumCounts(aggregate.uniqueSpecialCounts);
  elements.simulationResults.className = "simulation-results";
  elements.simulationResults.innerHTML = [
    simLine("Curve input", `${state.config.rarityMode} / ${state.config.rarityCurvePreset} / depth ${state.config.contractDepth}`),
    simLine("Value input", `manual ${state.config.valueScale.toFixed(2)}x / depth ${contractDepthValueScale(state.config.contractDepth).toFixed(2)}x / combined ${combinedValueScale(state.config).toFixed(2)}x`),
    simLine("Items rolled", String(items.length)),
    simLine("Rolls counted", String(aggregate.rollCount)),
    simLine("Configured rarity odds", rarityRows.map((row) => `${row.label} ${formatPercent(row.configured)}`).join(" / ")),
    simLine("Observed rarity odds", rarityRows.map((row) => `${row.label} ${formatPercent(row.observed)}`).join(" / ")),
    simLine("Observed slot odds", formatCountsInline(aggregate.slotCounts, slotLabels, items.length)),
    simLine("Roll marker mix", formatCountsInline(aggregate.markerCounts, markerLabels(), aggregate.rollCount)),
    simLine("Category mix", formatCountsInline(aggregate.categoryCounts, categoryLabels(), aggregate.rollCount)),
    simLine("Top stats", formatTopInline(aggregate.statCounts, statLabelMap(), 5)),
    simLine("Drawback stats", formatTopInline(aggregate.drawbackStatCounts, statLabelMap(), 4)),
    simLine("Special stats", formatTopInline(aggregate.specialStatCounts, statLabelMap(), 4)),
    simLine("Unique special rate", formatPercent(uniqueSpecialTotal / Math.max(1, items.length))),
    simLine("Chaos outcome mix", formatCountsInline(aggregate.chaosOutcomeCounts, chaosOutcomeLabels(), Math.max(1, sumCounts(aggregate.chaosOutcomeCounts)))),
    simLine("Cursed shape", `${aggregate.cursedOutcomeCounts.items} items / ${aggregate.cursedOutcomeCounts.positiveRolls} positive / ${aggregate.cursedOutcomeCounts.rareRolls} rare / ${aggregate.cursedOutcomeCounts.drawbackRolls} drawback`),
    simLine("Cursed balance", cursedSummaryRows(aggregate.cursedSummary).map(([label, value]) => `${label} ${value}`).join(" / ")),
    simLine("Chaos classifications", formatCountsInline(aggregate.chaosSummary.classificationCounts, chaosClassificationLabels(), Math.max(1, aggregate.chaosSummary.itemCount))),
    simLine("Chaos balance", chaosSummaryRows(aggregate.chaosSummary).map(([label, value]) => `${label} ${value}`).join(" / ")),
    simLine("Retrigger watch", retriggerSummaryRows(aggregate.retriggerSummary).map(([label, value]) => `${label} ${value}`).join(" / ")),
    simLine("Quality bands", formatCountsInline(aggregate.qualityCounts, qualityLabels(), items.length)),
    simLine("Avg positive magnitude", formatAverageMagnitude(aggregate.valueSummary.positiveAverageAbs)),
    simLine("Avg drawback magnitude", formatAverageMagnitude(aggregate.valueSummary.drawbackAverageAbs)),
    simLine("Retrigger appearances", String(aggregate.retriggerValues.length)),
    simLine("Top rarity", topCountLabel(aggregate.rarityCounts, rarityLabels)),
    simLine("Top slot", topCountLabel(aggregate.slotCounts, slotLabels)),
  ].join("");
}

function cursedSummaryRows(summary) {
  return [
    ["Items", `${summary.itemCount} / ${formatPercent(summary.itemRate)}`],
    ["Valid Shape", `${summary.validShapeItems} / ${formatPercent(summary.validShapeRate)}`],
    ["Positive Rolls", String(summary.positiveRollCount)],
    ["Drawback Rolls", String(summary.drawbackRollCount)],
    ["Avg Positive", formatAverageMagnitude(summary.positiveAverageAbs)],
    ["Avg Drawback", formatAverageMagnitude(summary.drawbackAverageAbs)],
    ["Top Positive", formatTopInline(summary.topPositiveStats, statLabelMap(), 3)],
    ["Top Drawback", formatTopInline(summary.topDrawbackStats, statLabelMap(), 3)],
  ];
}

function chaosSummaryRows(summary) {
  return [
    ["Items", `${summary.itemCount} / ${formatPercent(summary.itemRate)}`],
    ["All Positive", formatPercent(summary.classificationRates.all_positive ?? 0)],
    ["Mixed", formatPercent(summary.classificationRates.mixed ?? 0)],
    ["All Drawback", formatPercent(summary.classificationRates.all_drawback ?? 0)],
    ["Outcome Mix", formatCountsInline(summary.outcomeCounts, chaosOutcomeLabels(), Math.max(1, sumCounts(summary.outcomeCounts)))],
    ["Avg Positive", formatAverageMagnitude(summary.positiveAverageAbs)],
    ["Avg Drawback", formatAverageMagnitude(summary.drawbackAverageAbs)],
    ["Top Drawback", formatTopInline(summary.topDrawbackStats, statLabelMap(), 3)],
  ];
}

function retriggerSummaryRows(summary) {
  return [
    ["Items", `${summary.itemCount} / ${formatPercent(summary.itemRate)}`],
    ["Value Min/Avg/Max", `${formatPercent(summary.minValue)} / ${formatPercent(summary.averageValue)} / ${formatPercent(summary.maxValue)}`],
    ["Top 5 Stack", `${formatPercent(summary.topFiveStack)} of 100% cap`],
    ["Cap Proximity", formatPercent(summary.capProximity)],
    ["Multi-Item Shops", String(summary.multiRetriggerShopCount)],
    ["Slot Mix", formatCountsInline(summary.slotCounts, slotLabels, Math.max(1, summary.itemCount))],
    ["Rarity Mix", formatCountsInline(summary.rarityCounts, rarityLabels, Math.max(1, summary.itemCount))],
  ];
}

function formatScaledRange(range, kind) {
  const formatted = range.map((value) => formatRangeValue(value, kind));
  return formatted[0] === formatted[1] ? formatted[0] : `${formatted[0]}-${formatted[1]}`;
}

function formatAverageMagnitude(value) {
  return Number.isFinite(value) && value > 0 ? value.toFixed(2) : "none";
}

function countBy(values, keyFor) {
  const counts = {};
  for (const value of values) {
    const key = keyFor(value);
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return counts;
}

function sumCounts(counts) {
  return Object.values(counts).reduce((sum, count) => sum + Number(count || 0), 0);
}

function topEntries(counts, limit = 5) {
  return Object.entries(counts)
    .filter(([, count]) => Number(count) > 0)
    .sort((a, b) => b[1] - a[1] || String(a[0]).localeCompare(String(b[0])))
    .slice(0, limit);
}

function topCountLabel(counts, labels) {
  const entries = topEntries(counts, 1);
  if (!entries.length) {
    return "none";
  }
  return `${labels[entries[0][0]] ?? entries[0][0]} (${entries[0][1]})`;
}

function formatTopInline(counts, labels, limit = 5) {
  const rows = topEntries(counts, limit);
  if (!rows.length) {
    return "none";
  }
  return rows.map(([key, count]) => `${labels[key] ?? key} ${count}`).join(" / ");
}

function formatCountsInline(counts, labels, total = sumCounts(counts)) {
  const denominator = Math.max(1, total);
  const rows = Object.keys(labels)
    .filter((key) => counts[key] !== undefined)
    .map((key) => `${labels[key]} ${counts[key]} (${formatPercent(counts[key] / denominator)})`);
  return rows.length ? rows.join(" / ") : "none";
}

function statLabelMap() {
  return Object.fromEntries(Object.entries(statDefinitions).map(([statId, definition]) => [statId, definition.label]));
}

function markerLabels() {
  return {
    positive: "Positive",
    drawback: "Drawback",
    special: "Special",
    invalid: "Invalid",
  };
}

function categoryLabels() {
  return {
    basic: "Basic",
    rare: "Rare",
    special: "Special",
  };
}

function chaosOutcomeLabels() {
  return {
    basic_positive: "Basic Positive",
    rare_positive: "Rare Positive",
    basic_drawback: "Basic Drawback",
  };
}

function chaosClassificationLabels() {
  return {
    all_positive: "All Positive",
    mixed: "Mixed",
    all_drawback: "All Drawback",
  };
}

function qualityLabels() {
  return {
    standout: "Standout",
    strong: "Strong",
    risky: "Risky",
    baseline: "Baseline",
  };
}

function simLine(label, value) {
  return `<div class="sim-line"><span>${escapeHtml(label)}</span><strong>${escapeHtml(value)}</strong></div>`;
}

function formatPercent(value) {
  return `${(value * 100).toFixed(1)}%`;
}

function sumWeights(weights) {
  return Object.values(weights).reduce((sum, value) => sum + Number(value || 0), 0);
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function capitalize(value) {
  const text = String(value);
  return text ? `${text.charAt(0).toUpperCase()}${text.slice(1)}` : text;
}

function stableStringify(value) {
  if (Array.isArray(value)) {
    return `[${value.map(stableStringify).join(",")}]`;
  }
  if (value && typeof value === "object") {
    return `{${Object.keys(value).sort().map((key) => `${JSON.stringify(key)}:${stableStringify(value[key])}`).join(",")}}`;
  }
  return JSON.stringify(value);
}

function resetBaseline() {
  startNewSession({
    refreshRandomSeed: false,
    note: "Reset session from current visible inputs.",
  });
}

function syncInputsFromConfig() {
  elements.seedInput.value = state.config.seed;
  elements.randomSeed.checked = Boolean(state.config.randomSeed);
  elements.simulationPreset.value = state.config.activePreset;
  elements.contractDepth.value = String(state.config.contractDepth);
  elements.startingGold.value = String(state.config.startingGold);
  elements.shopSize.value = String(state.config.shopSize);
  elements.valueScale.value = String(state.config.valueScale);
  elements.batchSize.value = String(state.config.batchSize);
  elements.rerollCostBase.value = String(state.config.rerollCostBase);
  elements.rerollCostStep.value = String(state.config.rerollCostStep);
  elements.rarityMode.value = state.config.rarityMode;
  elements.rarityCurvePreset.value = state.config.rarityCurvePreset;
}

elements.generateButton.addEventListener("click", startNewSession);
elements.resetButton.addEventListener("click", resetBaseline);
elements.rerollButton.addEventListener("click", rerollShop);
elements.simulateButton.addEventListener("click", runSimulation);
elements.simulationPreset.addEventListener("change", () => {
  applyQuickSimulationPreset(elements.simulationPreset.value);
});
elements.rarityMode.addEventListener("change", () => {
  markCustomPreset();
  render();
});
elements.rarityCurvePreset.addEventListener("change", () => {
  markCustomPreset();
  render();
});
for (const input of [
  elements.seedInput,
  elements.randomSeed,
  elements.contractDepth,
  elements.startingGold,
  elements.shopSize,
  elements.valueScale,
  elements.batchSize,
  elements.rerollCostBase,
  elements.rerollCostStep,
]) {
  const eventName = input === elements.randomSeed ? "change" : "input";
  input.addEventListener(eventName, () => {
    markCustomPreset();
    render();
  });
}

setupControls();
resetBaseline();

const shopLabTestingApi = {
  baseline,
  gearSlots,
  proceduralRarities,
  rogueFamilies,
  quickSimulationPresets,
  applyQuickSimulationPreset,
  deterministicKeys,
  createRandomSeed,
  effectiveRarityWeights,
  interpolatedRarityCurve,
  rarityProbabilityRows,
  contractDepthValueScale,
  combinedValueScale,
  valueScaleRows,
  summarizeRollValues,
  aggregateItems,
  summarizeCursedItems,
  summarizeChaosItems,
  chaosOutcomes,
  chaosRollCount,
  summarizeRetriggerRisk,
  chaosClassification,
  generateShop,
  normalizedOfferSnapshot,
  batchSummarySnapshot,
  deterministicSelfCheck,
  readabilitySnapshot,
  sampleItemForReadability,
  stableStringify,
};

if (typeof window !== "undefined") {
  window.ShopLabTesting = shopLabTestingApi;
}

if (typeof module !== "undefined") {
  module.exports = shopLabTestingApi;
}
