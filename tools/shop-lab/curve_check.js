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

const earlyDepth = structuredClone(shopLab.baseline);
earlyDepth.contractDepth = 1;
earlyDepth.rarityMode = "curve";
earlyDepth.rarityCurvePreset = "late";

const lateDepth = structuredClone(earlyDepth);
lateDepth.contractDepth = 12;

const earlyWeights = shopLab.effectiveRarityWeights(earlyDepth);
const lateWeights = shopLab.effectiveRarityWeights(lateDepth);
assert(earlyWeights.basic > lateWeights.basic, "curve mode did not reduce Basic weight at late depth");
assert(lateWeights.epic > earlyWeights.epic, "curve mode did not increase Epic weight at late depth");
assert(lateWeights.unique > earlyWeights.unique, "curve mode did not increase Unique weight at late depth");
assert(shopLab.stableStringify(earlyWeights) !== shopLab.stableStringify(lateWeights), "curve weights did not change by depth");

const firstLateOffers = shopLab.normalizedOfferSnapshot(lateDepth, 0, 0);
const secondLateOffers = shopLab.normalizedOfferSnapshot(lateDepth, 0, 0);
assert(
  shopLab.stableStringify(firstLateOffers) === shopLab.stableStringify(secondLateOffers),
  "same curve depth/settings did not reproduce identical offers",
);

const manualDepthOne = structuredClone(shopLab.baseline);
manualDepthOne.rarityMode = "manual";
manualDepthOne.rarityWeights = { basic: 10, master: 20, epic: 30, cursed: 15, chaos: 15, unique: 10 };
manualDepthOne.contractDepth = 1;

const manualDepthTwelve = structuredClone(manualDepthOne);
manualDepthTwelve.contractDepth = 12;

assert(
  shopLab.stableStringify(shopLab.effectiveRarityWeights(manualDepthOne)) ===
    shopLab.stableStringify(shopLab.effectiveRarityWeights(manualDepthTwelve)),
  "manual rarity weights changed with contract depth",
);

const rows = shopLab.rarityProbabilityRows(lateDepth);
assert(rows.length === 6, "rarity readout did not include every procedural rarity");
assert(rows.every((row) => Number.isFinite(row.configured)), "rarity readout has invalid configured odds");

const expectedEarlyOverrides = {
  1: { basic: 65, master: 23, epic: 6, cursed: 2, chaos: 3, unique: 1 },
  6: { basic: 54, master: 26, epic: 10, cursed: 4, chaos: 4, unique: 2 },
  12: { basic: 41, master: 29, epic: 15, cursed: 7, chaos: 5, unique: 3 },
};
for (const [depth, expectedWeights] of Object.entries(expectedEarlyOverrides)) {
  const config = structuredClone(shopLab.baseline);
  config.rarityMode = "curve";
  config.rarityCurvePreset = "early";
  config.contractDepth = Number(depth);
  assert(
    shopLab.stableStringify(shopLab.effectiveRarityWeights(config)) === shopLab.stableStringify(expectedWeights),
    `early curve depth ${depth} override drifted`,
  );
}

console.log(
  `curve ok: late depth Basic ${earlyWeights.basic}->${lateWeights.basic}, Unique ${earlyWeights.unique}->${lateWeights.unique}`,
);
