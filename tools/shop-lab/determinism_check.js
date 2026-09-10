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

const baseline = structuredClone(shopLab.baseline);
baseline.batchSize = 64;

const firstOffers = shopLab.normalizedOfferSnapshot(baseline, 0, 0);
const secondOffers = shopLab.normalizedOfferSnapshot(baseline, 0, 0);
assert(
  shopLab.stableStringify(firstOffers) === shopLab.stableStringify(secondOffers),
  "same seed/settings did not reproduce identical offers",
);

const firstBatch = shopLab.batchSummarySnapshot(baseline);
const secondBatch = shopLab.batchSummarySnapshot(baseline);
assert(
  shopLab.stableStringify(firstBatch) === shopLab.stableStringify(secondBatch),
  "same seed/settings did not reproduce identical batch summaries",
);

const rerollOffers = shopLab.normalizedOfferSnapshot(baseline, 1, 1);
assert(
  shopLab.stableStringify(firstOffers) !== shopLab.stableStringify(rerollOffers),
  "reroll path did not produce a distinct deterministic offer set",
);

const depthChanged = structuredClone(baseline);
depthChanged.contractDepth = 2;
assert(
  shopLab.stableStringify(firstOffers) !== shopLab.stableStringify(shopLab.normalizedOfferSnapshot(depthChanged, 0, 0)),
  "contract depth did not affect the deterministic output path",
);

const valueChanged = structuredClone(baseline);
valueChanged.valueScale = 1.5;
assert(
  shopLab.stableStringify(firstOffers) !== shopLab.stableStringify(shopLab.normalizedOfferSnapshot(valueChanged, 0, 0)),
  "value scale did not affect generated roll values/signatures",
);

const selfCheck = shopLab.deterministicSelfCheck(baseline);
assert(selfCheck.ok, `self-check failed: ${JSON.stringify(selfCheck)}`);

console.log(`determinism ok: ${firstOffers.length} offers, ${firstBatch.itemCount} batch items`);
