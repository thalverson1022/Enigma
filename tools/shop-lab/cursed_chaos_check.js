"use strict";

class FakeElement {
  constructor() {
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

const cursedConfig = forcedRarityConfig("cursed");
const cursedItems = generateItems(cursedConfig, 80);
const cursedAggregate = shopLab.aggregateItems(cursedItems);

assert(cursedItems.every((item) => item.rarity === "cursed"), "forced Cursed batch generated another rarity");
assert(cursedAggregate.cursedSummary.itemCount === cursedItems.length, "Cursed summary item count mismatch");
assert(cursedAggregate.cursedSummary.validShapeItems === cursedItems.length, "Cursed items did not all satisfy 2 Basic + 1 Rare + 1 drawback");
assert(cursedAggregate.cursedSummary.drawbackRollCount === cursedItems.length, "Cursed drawback count mismatch");
assert(cursedAggregate.cursedSummary.positiveRollCount === cursedItems.length * 3, "Cursed positive count mismatch");
assert(cursedAggregate.cursedSummary.positiveAverageAbs > 0, "Cursed positive magnitude missing");
assert(cursedAggregate.cursedSummary.drawbackAverageAbs > 0, "Cursed drawback magnitude missing");
assert(Object.keys(cursedAggregate.cursedSummary.topDrawbackStats).length > 0, "Cursed drawback stat distribution missing");

const chaosConfig = forcedRarityConfig("chaos");
const chaosItems = generateItems(chaosConfig, 240);
const chaosAggregate = shopLab.aggregateItems(chaosItems);
const chaosClasses = chaosAggregate.chaosSummary.classificationCounts;
const chaosOutcomeWeights = shopLab.chaosOutcomes.reduce((result, outcome) => {
  result[outcome.outcome] = outcome.weight;
  return result;
}, {});

assert(chaosItems.every((item) => item.rarity === "chaos"), "forced Chaos batch generated another rarity");
assert(chaosAggregate.chaosSummary.itemCount === chaosItems.length, "Chaos summary item count mismatch");
assert(sum(chaosAggregate.chaosSummary.outcomeCounts) === chaosItems.length * 4, "Chaos outcomes should reconcile to four rolls per item");
assert(chaosOutcomeWeights.rare_positive === 4, "Chaos Rare outcome should be weighted 20% below Basic");
assert(chaosOutcomeWeights.basic_positive === 5, "Chaos Basic positive outcome should use baseline weight 5");
assert((chaosClasses.all_positive ?? 0) > 0, "Chaos batch did not show all-positive outcomes");
assert((chaosClasses.mixed ?? 0) > 0, "Chaos batch did not show mixed outcomes");
assert((chaosClasses.all_drawback ?? 0) > 0, "Chaos batch did not show all-drawback outcomes");
assert(chaosAggregate.chaosSummary.positiveAverageAbs > 0, "Chaos positive magnitude missing");
assert(chaosAggregate.chaosSummary.drawbackAverageAbs > 0, "Chaos drawback magnitude missing");
assert(chaosItems.some(hasDuplicateStat), "Chaos batch did not allow duplicate stat IDs");

for (const item of chaosItems) {
  const classification = shopLab.chaosClassification(item);
  const drawbackCount = item.rolls.filter((roll) => roll.marker === "drawback").length;
  if (classification === "all_positive") {
    assert(drawbackCount === 0, "all-positive Chaos classification has a drawback");
  }
  if (classification === "all_drawback") {
    assert(drawbackCount === item.rolls.length, "all-drawback Chaos classification has a positive");
  }
  if (classification === "mixed") {
    assert(drawbackCount > 0 && drawbackCount < item.rolls.length, "mixed Chaos classification is not mixed");
  }
}

function hasDuplicateStat(item) {
  const seen = new Set();
  for (const roll of item.rolls) {
    if (seen.has(roll.statId)) {
      return true;
    }
    seen.add(roll.statId);
  }
  return false;
}

console.log(
  `risk ok: ${cursedItems.length} cursed valid, chaos ${chaosClasses.all_positive}/${chaosClasses.mixed}/${chaosClasses.all_drawback}`,
);

function forcedRarityConfig(rarity) {
  const config = structuredClone(shopLab.baseline);
  config.seed = `risk-${rarity}`;
  config.shopSize = 5;
  config.rarityMode = "manual";
  config.rarityWeights = { basic: 0, master: 0, epic: 0, cursed: 0, chaos: 0, unique: 0 };
  config.rarityWeights[rarity] = 100;
  config.slotWeights = { weapon: 20, helm: 20, armor: 20, trinket: 20, charm: 20 };
  return config;
}

function generateItems(config, shopCount) {
  const items = [];
  for (let shopIndex = 0; shopIndex < shopCount; shopIndex += 1) {
    items.push(...shopLab.generateShop(config, shopIndex, 0));
  }
  return items;
}

function sum(counts) {
  return Object.values(counts).reduce((total, count) => total + Number(count || 0), 0);
}
