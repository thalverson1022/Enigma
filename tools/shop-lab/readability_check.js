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

const snapshots = shopLab.readabilitySnapshot(shopLab.baseline);
assert(snapshots.length === 30, "readability snapshot should cover every rarity/slot pair");

for (const snapshot of snapshots) {
  assert(snapshot.name && snapshot.name.includes(snapshot.family), `missing family in name for ${snapshot.rarity}/${snapshot.slot}`);
  assert(snapshot.badges.includes(snapshot.family), `missing family badge for ${snapshot.rarity}/${snapshot.slot}`);
  assert(snapshot.badges.some((badge) => badge.toLowerCase() === snapshot.rarity), `missing rarity badge for ${snapshot.rarity}/${snapshot.slot}`);
  assert(snapshot.labels.every((label) => label && label !== "Invalid Roll"), `invalid or missing label for ${snapshot.rarity}/${snapshot.slot}`);
  assert(snapshot.metadataRows.every((rows) => rows.includes("ID") && rows.includes("Category") && rows.includes("Weight") && rows.includes("Range")), `missing metadata rows for ${snapshot.rarity}/${snapshot.slot}`);
  assert(snapshot.html.includes("roll-group-positive"), `missing positive group in rendered card for ${snapshot.rarity}/${snapshot.slot}`);
  assert(!snapshot.html.includes("Positive Stats"), `rendered card still shows positive group label for ${snapshot.rarity}/${snapshot.slot}`);
  assert(!snapshot.html.includes("readability-badges"), `rendered card still shows redundant badge row for ${snapshot.rarity}/${snapshot.slot}`);
  if (snapshot.rarity === "cursed") {
    assert(snapshot.groups.drawback === 1, `cursed item missing exactly one drawback for ${snapshot.slot}`);
    assert(snapshot.html.includes("roll-group-drawback"), `cursed card missing drawback group for ${snapshot.slot}`);
    assert(!snapshot.html.includes("Drawbacks"), `cursed card still shows drawback group label for ${snapshot.slot}`);
  }
  if (snapshot.rarity === "unique") {
    assert(snapshot.groups.special === 1, `unique item missing exactly one special for ${snapshot.slot}`);
    assert(snapshot.html.includes("roll-group-special"), `unique card missing special group for ${snapshot.slot}`);
    assert(!snapshot.html.includes("Specials"), `unique card still shows special group label for ${snapshot.slot}`);
  }
  if (snapshot.rarity === "chaos") {
    assert(Object.values(snapshot.groups).reduce((sum, count) => sum + count, 0) === 4, `chaos item missing four rolls for ${snapshot.slot}`);
  }
}

console.log(`readability ok: ${snapshots.length} rarity/slot cards`);
