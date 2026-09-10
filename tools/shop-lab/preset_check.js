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

const expected = {
  earlyRun: { contractDepth: 2, rarityCurvePreset: "early", valueScale: 0.95, batchSize: 400, shopSize: 4 },
  midRun: { contractDepth: 6, rarityCurvePreset: "mid", valueScale: 1, batchSize: 700, shopSize: 4 },
  lateRun: { contractDepth: 10, rarityCurvePreset: "late", valueScale: 1.08, batchSize: 1000, shopSize: 5 },
  highVariance: { contractDepth: 12, rarityCurvePreset: "highVariance", valueScale: 1.15, batchSize: 1200, shopSize: 5 },
};

assert(Object.keys(shopLab.quickSimulationPresets).length === Object.keys(expected).length, "unexpected preset count");

for (const [presetId, values] of Object.entries(expected)) {
  const applied = shopLab.applyQuickSimulationPreset(presetId);
  assert(applied.activePreset === presetId, `${presetId} did not become active`);
  assert(applied.rarityMode === "curve", `${presetId} should use curve mode`);
  for (const [key, value] of Object.entries(values)) {
    assert(applied[key] === value, `${presetId} did not apply ${key}`);
  }
  const weights = shopLab.effectiveRarityWeights(applied);
  const directWeights = shopLab.interpolatedRarityCurve(values.rarityCurvePreset, values.contractDepth);
  assert(shopLab.stableStringify(weights) === shopLab.stableStringify(directWeights), `${presetId} curve weights drifted`);
  const first = shopLab.batchSummarySnapshot(applied);
  const second = shopLab.batchSummarySnapshot(applied);
  assert(first.itemCount === values.batchSize * values.shopSize, `${presetId} item count does not match batch/shop size`);
  assert(shopLab.stableStringify(first) === shopLab.stableStringify(second), `${presetId} batch is not deterministic`);
}

const fallback = shopLab.applyQuickSimulationPreset("missingPreset");
assert(fallback === null, "unknown presets should return null");

console.log(`presets ok: ${Object.keys(expected).join(", ")}`);
