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

const depthOne = structuredClone(shopLab.baseline);
depthOne.contractDepth = 1;
depthOne.batchSize = 32;

const depthTwelve = structuredClone(depthOne);
depthTwelve.contractDepth = 12;

assert(shopLab.contractDepthValueScale(1) === 1, "depth 1 scale should be neutral");
assert(shopLab.contractDepthValueScale(12) === 1.35, "depth 12 scale should be 1.35x");
assert(
  shopLab.contractDepthValueScale(12) > shopLab.contractDepthValueScale(1),
  "depth scaling did not increase across the contract range",
);

const depthOneExamples = shopLab.valueScaleRows(depthOne);
const depthTwelveExamples = shopLab.valueScaleRows(depthTwelve);
assert(
  shopLab.stableStringify(depthOneExamples) !== shopLab.stableStringify(depthTwelveExamples),
  "value range examples did not change with contract depth",
);

const valueOneOffers = shopLab.normalizedOfferSnapshot(depthOne, 0, 0);
const valueOneRepeat = shopLab.normalizedOfferSnapshot(depthOne, 0, 0);
assert(
  shopLab.stableStringify(valueOneOffers) === shopLab.stableStringify(valueOneRepeat),
  "same value settings did not reproduce identical offers",
);

const valueScaled = structuredClone(depthOne);
valueScaled.valueScale = 1.5;
const scaledOffers = shopLab.normalizedOfferSnapshot(valueScaled, 0, 0);
assert(
  shopLab.stableStringify(valueOneOffers) !== shopLab.stableStringify(scaledOffers),
  "manual value scale did not affect offer values/signatures",
);

const depthScaledOffers = shopLab.normalizedOfferSnapshot(depthTwelve, 0, 0);
assert(
  shopLab.stableStringify(valueOneOffers) !== shopLab.stableStringify(depthScaledOffers),
  "contract depth value scale did not affect offer values/signatures",
);

const summary = shopLab.batchSummarySnapshot(valueScaled);
assert(summary.depthValueScale === 1, "depth 1 batch summary should report neutral depth scaling");
assert(summary.combinedValueScale === 1.5, "batch summary did not report combined value scaling");
assert(summary.valueSummary.positiveAverageAbs > 0, "batch value summary did not compute positive magnitude");

console.log(
  `value ok: depth ${shopLab.contractDepthValueScale(1).toFixed(2)}x->${shopLab.contractDepthValueScale(12).toFixed(2)}x, combined ${summary.combinedValueScale.toFixed(2)}x`,
);
