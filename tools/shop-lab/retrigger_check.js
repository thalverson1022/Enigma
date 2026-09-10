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
config.seed = "retrigger-watch";
config.shopSize = 8;
config.batchSize = 160;
config.contractDepth = 12;
config.valueScale = 1.5;
config.rarityMode = "manual";
config.rarityWeights = { basic: 0, master: 0, epic: 25, cursed: 25, chaos: 25, unique: 25 };
config.slotWeights = { weapon: 50, helm: 0, armor: 0, trinket: 50, charm: 0 };

const summary = shopLab.batchSummarySnapshot(config);
const retrigger = summary.retriggerSummary;

assert(retrigger.itemCount > 0, "forced retrigger batch did not generate retrigger items");
assert(retrigger.rollCount >= retrigger.itemCount, "retrigger roll count should include every retrigger item, with Chaos allowed to stack repeats");
assert(retrigger.values.length === retrigger.rollCount, "retrigger value list does not match roll count");
assert(retrigger.minValue > 0, "retrigger min value should be positive");
assert(retrigger.maxValue <= 0.50, "retrigger max value exceeded expected scaled range");
assert(retrigger.averageValue >= retrigger.minValue, "average should be at least min");
assert(retrigger.averageValue <= retrigger.maxValue, "average should be at most max");
assert(retrigger.topFiveStack >= retrigger.maxValue, "top-five stack should include max value");
assert(retrigger.capProximity <= 1, "cap proximity should clamp to 100%");
assert(retrigger.multiRetriggerShopCount > 0, "forced batch should reveal multi-retrigger shops");
assert((retrigger.slotCounts.weapon ?? 0) + (retrigger.slotCounts.trinket ?? 0) === retrigger.itemCount, "retrigger appeared outside Weapon/Trinket slots");
assert(Object.keys(retrigger.rarityCounts).length > 0, "retrigger rarity mix missing");

const repeated = shopLab.batchSummarySnapshot(config).retriggerSummary;
assert(
  shopLab.stableStringify(retrigger) === shopLab.stableStringify(repeated),
  "retrigger summary is not deterministic for identical settings",
);

console.log(
  `retrigger ok: ${retrigger.itemCount} items, top5 ${Math.round(retrigger.topFiveStack * 100)}%, multi shops ${retrigger.multiRetriggerShopCount}`,
);
