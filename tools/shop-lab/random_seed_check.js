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

const seeds = Array.from({ length: 8 }, () => shopLab.createRandomSeed());
assert(seeds.every((seed) => /^random-[a-z0-9]+-[a-z0-9]+$/.test(seed)), "random seeds should use a readable stable prefix");
assert(new Set(seeds).size > 1, "random seed helper did not produce varied seeds");

const preset = shopLab.applyQuickSimulationPreset("earlyRun");
assert(preset.randomSeed === false, "quick presets should remain deterministic fixed-seed setups");

console.log(`random seed ok: ${new Set(seeds).size} variants`);
