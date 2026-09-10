"use strict";

class FakeElement {
  constructor() {
    this.checked = false;
    this.className = "";
    this.dataset = {};
    this.disabled = false;
    this.innerHTML = "";
    this.textContent = "";
    this.value = "";
  }

  addEventListener() {}

  append() {}

  querySelector() {
    return new FakeElement();
  }

  querySelectorAll() {
    return [];
  }
}

global.document = {
  createElement() {
    return new FakeElement();
  },
  querySelector(selector) {
    const element = new FakeElement();
    const defaults = {
      "#seed-input": "1001",
      "#simulation-preset": "custom",
      "#contract-depth": "1",
      "#starting-gold": "80",
      "#shop-size": "4",
      "#value-scale": "1",
      "#batch-size": "1000",
      "#reroll-cost-base": "5",
      "#reroll-cost-step": "5",
      "#rarity-mode": "curve",
      "#rarity-curve-preset": "early",
    };
    element.value = defaults[selector] ?? "";
    return element;
  },
};

const shopLab = require("./app.js");

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

const expectedSlots = ["weapon", "helm", "armor", "trinket", "charm"];
const expectedFamilies = {
  weapon: "Dagger",
  helm: "Hood",
  armor: "Doublet",
  trinket: "Ring",
  charm: "Necklace",
};
const expectedRarities = ["basic", "master", "epic", "cursed", "chaos", "unique"];
const excludedRarities = new Set(["crude", "legendary"]);
const excludedTerms = [/lucky coin/i, /compatibility/i];

assert(
  shopLab.stableStringify(shopLab.gearSlots) === shopLab.stableStringify(expectedSlots),
  "Shop Lab slots drifted from the Phase 5 five-slot model",
);
assert(
  shopLab.stableStringify(shopLab.proceduralRarities) === shopLab.stableStringify(expectedRarities),
  "Shop Lab procedural rarities drifted from the Phase 5 model",
);
for (const [slot, family] of Object.entries(expectedFamilies)) {
  assert(shopLab.rogueFamilies[slot] === family, `${slot} no longer maps to Rogue family ${family}`);
}

const config = structuredClone(shopLab.baseline);
config.rarityMode = "manual";
config.rarityWeights = { basic: 20, master: 20, epic: 20, cursed: 15, chaos: 15, unique: 10 };
config.shopSize = 12;
config.batchSize = 180;
config.slotWeights = { weapon: 20, helm: 20, armor: 20, trinket: 20, charm: 20 };

const items = [];
for (let shopIndex = 0; shopIndex < config.batchSize; shopIndex += 1) {
  items.push(...shopLab.generateShop(config, shopIndex, 0));
}

const seenSlots = new Set();
const seenFamilies = new Set();
const seenRarities = new Set();
for (const item of items) {
  assert(expectedSlots.includes(item.slot), `generated unexpected slot ${item.slot}`);
  assert(expectedRarities.includes(item.rarity), `generated unexpected rarity ${item.rarity}`);
  assert(!excludedRarities.has(item.rarity), `generated excluded rarity ${item.rarity}`);
  assert(item.family === expectedFamilies[item.slot], `generated ${item.slot} item with family ${item.family}`);
  const searchableText = `${item.id} ${item.name} ${item.summary} ${item.family} ${item.rarity}`;
  assert(excludedTerms.every((pattern) => !pattern.test(searchableText)), `generated excluded boundary item text: ${searchableText}`);
  seenSlots.add(item.slot);
  seenFamilies.add(item.family);
  seenRarities.add(item.rarity);
}

for (const slot of expectedSlots) {
  assert(seenSlots.has(slot), `batch did not exercise slot ${slot}`);
}
for (const family of Object.values(expectedFamilies)) {
  assert(seenFamilies.has(family), `batch did not exercise Rogue family ${family}`);
}
for (const rarity of expectedRarities) {
  assert(seenRarities.has(rarity), `batch did not exercise rarity ${rarity}`);
}

console.log(`phase5 shape ok: ${seenSlots.size} slots, ${seenRarities.size} rarities, ${seenFamilies.size} Rogue families`);
