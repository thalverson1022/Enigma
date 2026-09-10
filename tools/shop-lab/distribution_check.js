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

const config = structuredClone(shopLab.baseline);
config.batchSize = 128;
config.shopSize = 5;
config.contractDepth = 12;
config.rarityCurvePreset = "highVariance";

const summary = shopLab.batchSummarySnapshot(config);

assert(summary.itemCount === config.batchSize * config.shopSize, "item count does not match batch size and shop size");
assert(summary.rollCount > summary.itemCount, "roll count should exceed item count");
assert(sum(summary.rarityCounts) === summary.itemCount, "rarity counts do not reconcile to item count");
assert(sum(summary.slotCounts) === summary.itemCount, "slot counts do not reconcile to item count");
assert(sum(summary.markerCounts) === summary.rollCount, "marker counts do not reconcile to roll count");
assert(sum(summary.categoryCounts) === summary.rollCount, "category counts do not reconcile to roll count");
assert(sum(summary.statCounts) === summary.rollCount, "stat counts do not reconcile to roll count");
assert(sum(summary.qualityCounts) === summary.itemCount, "quality counts do not reconcile to item count");

for (const rarity of ["basic", "master", "epic", "cursed", "chaos", "unique"]) {
  assert(summary.rarityCounts[rarity] !== undefined, `missing rarity bucket: ${rarity}`);
}

for (const slot of ["weapon", "helm", "armor", "trinket", "charm"]) {
  assert(summary.slotCounts[slot] !== undefined, `missing slot bucket: ${slot}`);
}

for (const marker of ["positive", "drawback", "special"]) {
  assert(summary.markerCounts[marker] !== undefined, `missing marker bucket: ${marker}`);
}

for (const category of ["basic", "rare", "special"]) {
  assert(summary.categoryCounts[category] !== undefined, `missing category bucket: ${category}`);
}

assert(Object.keys(summary.statCounts).length >= 10, "stat frequency bucket is too sparse");
assert(summary.cursedOutcomeCounts.items === summary.rarityCounts.cursed, "cursed item count mismatch");
assert(summary.cursedOutcomeCounts.drawbackRolls === summary.rarityCounts.cursed, "cursed drawback count mismatch");
assert(sum(summary.uniqueSpecialCounts) === summary.rarityCounts.unique, "unique special count mismatch");
assert(sum(summary.chaosOutcomeCounts) === (summary.rarityCounts.chaos ?? 0) * shopLab.chaosRollCount, "chaos outcome count mismatch");
assert(Array.isArray(summary.retriggerValues), "retrigger values should be an array");
assert(summary.valueSummary.positiveAverageAbs > 0, "positive magnitude summary missing");

console.log(
  `distribution ok: ${summary.itemCount} items, ${summary.rollCount} rolls, ${Object.keys(summary.statCounts).length} stat buckets`,
);

function sum(counts) {
  return Object.values(counts).reduce((total, count) => total + Number(count || 0), 0);
}
