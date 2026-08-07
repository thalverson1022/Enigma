"use strict";

const gearSlots = ["weapon", "trinket", "charm"];
const gearTiers = ["basic", "master", "cursed", "legendary"];

const tierLabels = {
  basic: "Basic",
  master: "Master",
  cursed: "Cursed",
  legendary: "Legendary",
};

const slotLabels = {
  weapon: "Weapon",
  trinket: "Trinket",
  charm: "Charm",
};

const baseTypes = {
  weapon: "Dagger",
  trinket: "Ring",
  charm: "Necklace",
};

const affixNameParts = {
  "affix.attack_speed": { prefix: "Swift", suffix: "Speed" },
  "affix.crit_chance": { prefix: "Sharp", suffix: "Sharpness" },
  "affix.crit_multiplier": { prefix: "Savage", suffix: "Savagery" },
  "affix.physical_skill_damage": { prefix: "Brutal", suffix: "Brutality" },
  "affix.poison_damage_per_tick": { prefix: "Lethal", suffix: "Lethality" },
  "affix.poison_stacks_applied": { prefix: "Poison", suffix: "Poisoning" },
  "affix.armor_reduction": { prefix: "Bloody", suffix: "Rending" },
  "affix.gold_rewards": { prefix: "Greedy", suffix: "Avarice" },
};

const gearAffixDefinitions = [
  {
    id: "affix.attack_speed",
    name: "Attack Speed",
    valueTable: { basic: 0.08, master: 0.1, cursedAmplified: 0.2, cursedDownside: -0.08 },
    score: 13,
  },
  {
    id: "affix.crit_chance",
    name: "Crit Chance",
    valueTable: { basic: 0.05, master: 0.06, cursedAmplified: 0.12, cursedDownside: -0.05 },
    score: 14,
  },
  {
    id: "affix.crit_multiplier",
    name: "Crit Multiplier",
    valueTable: { basic: 0.2, master: 0.25, cursedAmplified: 0.5, cursedDownside: -0.2 },
    score: 13,
  },
  {
    id: "affix.poison_damage_per_tick",
    name: "Poison Damage",
    valueTable: { basic: 4, master: 6, cursedAmplified: 12, cursedDownside: -4 },
    score: 13,
  },
  {
    id: "affix.physical_skill_damage",
    name: "Phys Dmg",
    valueTable: { basic: 1.08, master: 1.1, cursedAmplified: 1.2, cursedDownside: 0.92 },
    score: 15,
  },
  {
    id: "affix.poison_stacks_applied",
    name: "Poison Stacks Applied",
    valueTable: { basic: 1, master: 1, cursedAmplified: 2, cursedDownside: -1 },
    score: 15,
  },
  {
    id: "affix.armor_reduction",
    name: "Armor Reduction",
    valueTable: { basic: 10, master: 15, cursedAmplified: 30 },
    score: 12,
  },
  {
    id: "affix.gold_rewards",
    name: "Gold Rewards",
    valueTable: { basic: 0.5, master: 0.75, cursedAmplified: 1.5, cursedDownside: -0.5 },
    score: 10,
  },
];

const legendaryGearItems = [
  {
    id: "gear.weapon.legendary.wyvern_kriss",
    slot: "weapon",
    tier: "legendary",
    name: "Wyvern Kriss",
    affixes: ["Poison stacks +2", "Poison damage x1.4", "Poison ticks twice as fast"],
    score: 78,
  },
  {
    id: "gear.weapon.legendary.bandit_blade",
    slot: "weapon",
    tier: "legendary",
    name: "Bandit Blade",
    affixes: ["20% phys dmg", "20% crit chance", "+1 physical damage per 10 gold"],
    score: 74,
  },
  {
    id: "gear.weapon.legendary.umbral_stiletto",
    slot: "weapon",
    tier: "legendary",
    name: "Umbral Stiletto",
    affixes: ["10% crit chance", "+100% crit multiplier", "Unlocks Killer's Mark"],
    score: 76,
  },
  {
    id: "gear.weapon.legendary.mithril_karambit",
    slot: "weapon",
    tier: "legendary",
    name: "Mithril Karambit",
    affixes: ["20% attack speed", "10% crit chance", "20% repeat strike triggers"],
    score: 80,
  },
  {
    id: "gear.weapon.legendary.bejeweled_push_dagger",
    slot: "weapon",
    tier: "legendary",
    name: "Bejeweled Push Dagger",
    affixes: ["20% phys dmg", "40% crit chance", "20% minimum attack time casts"],
    score: 82,
  },
];

const baseline = {
  startingGold: 80,
  shopSize: 4,
  amazingThreshold: 58,
  tierWeights: { basic: 58, master: 25, cursed: 12, legendary: 5 },
  slotWeights: { weapon: 34, trinket: 33, charm: 33 },
  affixWeights: {
    "affix.attack_speed": 13,
    "affix.crit_chance": 13,
    "affix.crit_multiplier": 12,
    "affix.physical_skill_damage": 14,
    "affix.poison_damage_per_tick": 13,
    "affix.poison_stacks_applied": 12,
    "affix.armor_reduction": 11,
    "affix.gold_rewards": 12,
  },
};

const state = {
  config: structuredClone(baseline),
  seed: 1001,
  currentGold: baseline.startingGold,
  rerollCount: 0,
  goldSpent: 0,
  shopItems: [],
  seenItems: [],
  bestItem: null,
};

const elements = {
  resetButton: document.querySelector("#reset-button"),
  generateButton: document.querySelector("#generate-button"),
  rerollButton: document.querySelector("#reroll-button"),
  simulateButton: document.querySelector("#simulate-button"),
  startingGold: document.querySelector("#starting-gold"),
  shopSize: document.querySelector("#shop-size"),
  amazingThreshold: document.querySelector("#amazing-threshold"),
  tierControls: document.querySelector("#tier-controls"),
  slotControls: document.querySelector("#slot-controls"),
  affixControls: document.querySelector("#affix-controls"),
  tierTotal: document.querySelector("#tier-total"),
  slotTotal: document.querySelector("#slot-total"),
  affixTotal: document.querySelector("#affix-total"),
  seedReadout: document.querySelector("#seed-readout"),
  shopNote: document.querySelector("#shop-note"),
  currentGold: document.querySelector("#current-gold"),
  rerollCount: document.querySelector("#reroll-count"),
  goldSpent: document.querySelector("#gold-spent"),
  nextRerollCost: document.querySelector("#next-reroll-cost"),
  amazingSeen: document.querySelector("#amazing-seen"),
  shopGrid: document.querySelector("#shop-grid"),
  bestScore: document.querySelector("#best-score"),
  bestItem: document.querySelector("#best-item"),
  distribution: document.querySelector("#distribution"),
  totalItemsSeen: document.querySelector("#total-items-seen"),
  simulationResults: document.querySelector("#simulation-results"),
};

function createMulberry32(seed) {
  let stateValue = seed >>> 0;
  return () => {
    stateValue = (stateValue + 0x6d2b79f5) >>> 0;
    let value = stateValue;
    value = Math.imul(value ^ (value >>> 15), value | 1);
    value ^= value + Math.imul(value ^ (value >>> 7), value | 61);
    return ((value ^ (value >>> 14)) >>> 0) / 4294967296;
  };
}

function hashSeed(seed) {
  const seedText = String(seed);
  let hash = 2166136261;
  for (let index = 0; index < seedText.length; index += 1) {
    hash ^= seedText.charCodeAt(index);
    hash = Math.imul(hash, 16777619);
  }
  return hash >>> 0;
}

function rngFrom(seed) {
  return createMulberry32(hashSeed(seed));
}

function pickWeighted(entries, random) {
  const total = entries.reduce((sum, entry) => sum + Math.max(0, entry.weight), 0);
  if (total <= 0) {
    return entries[0].value;
  }
  let roll = random() * total;
  for (const entry of entries) {
    roll -= Math.max(0, entry.weight);
    if (roll <= 0) {
      return entry.value;
    }
  }
  return entries[entries.length - 1].value;
}

function pickManyWeighted(values, count, random, weightsById) {
  const remaining = [...values];
  const picked = [];
  for (let index = 0; index < count && remaining.length > 0; index += 1) {
    const definition = pickWeighted(
      remaining.map((candidate) => ({
        value: candidate,
        weight: weightsById[candidate.id] ?? 1,
      })),
      random,
    );
    picked.push(definition);
    remaining.splice(remaining.indexOf(definition), 1);
  }
  return picked;
}

function getPositiveAffixDefinitions() {
  return gearAffixDefinitions;
}

function getDownsideAffixDefinitions() {
  return gearAffixDefinitions.filter((definition) => definition.valueTable.cursedDownside !== undefined);
}

function selectGeneratedAffixes(tier, random, config) {
  const positives = getPositiveAffixDefinitions();
  if (tier === "basic") {
    return [
      {
        definition: pickManyWeighted(positives, 1, random, config.affixWeights)[0],
        polarity: "positive",
        valueTier: "basic",
      },
    ];
  }
  if (tier === "master") {
    return pickManyWeighted(positives, 2, random, config.affixWeights).map((definition) => ({
      definition,
      polarity: "positive",
      valueTier: "master",
    }));
  }

  const amplified = pickManyWeighted(positives, 1, random, config.affixWeights)[0];
  const normalPool = positives.filter((definition) => definition.id !== amplified.id);
  const normal = pickManyWeighted(normalPool, 1, random, config.affixWeights)[0];
  const downsidePool = getDownsideAffixDefinitions().filter(
    (definition) => definition.id !== amplified.id && definition.id !== normal.id,
  );
  const downside = pickManyWeighted(downsidePool, 1, random, config.affixWeights)[0];
  return [
    { definition: amplified, polarity: "positive", valueTier: "cursedAmplified" },
    { definition: normal, polarity: "positive", valueTier: "master" },
    { definition: downside, polarity: "downside", valueTier: "cursedDownside" },
  ];
}

function formatGeneratedGearTitle(item) {
  const positiveAffixes = item.affixes.filter((affix) => affix.polarity === "positive");
  const prefixAffix = positiveAffixes[0];
  if (!prefixAffix) {
    return item.name;
  }
  const prefix = affixNameParts[prefixAffix.definition.id].prefix;
  const suffixAffix = positiveAffixes[1];
  if (!suffixAffix) {
    return `${prefix} ${baseTypes[item.slot]}`;
  }
  return `${prefix} ${baseTypes[item.slot]} of ${affixNameParts[suffixAffix.definition.id].suffix}`;
}

function formatAffixValue(affix) {
  const value = affix.definition.valueTable[affix.valueTier];
  const abs = Math.abs(value);
  const sign = value > 0 ? "+" : value < 0 ? "-" : "";
  if (affix.definition.id === "affix.physical_skill_damage") {
    const percentage = Math.round(Math.abs(value - 1) * 100);
    return `${value >= 1 ? "+" : "-"}${percentage}% physical damage`;
  }
  if (affix.definition.id === "affix.attack_speed" || affix.definition.id === "affix.crit_chance" || affix.definition.id === "affix.crit_multiplier" || affix.definition.id === "affix.gold_rewards") {
    return `${sign}${Math.round(abs * 100)}% ${affix.definition.name.toLowerCase()}`;
  }
  return `${sign}${abs} ${affix.definition.name.toLowerCase()}`;
}

function scoreGeneratedItem(tier, affixes) {
  const tierScore = { basic: 10, master: 28, cursed: 42, legendary: 70 }[tier];
  const affixScore = affixes.reduce((sum, affix) => {
    const base = affix.definition.score;
    if (affix.polarity === "downside") {
      return sum - Math.round(base * 0.72);
    }
    if (affix.valueTier === "cursedAmplified") {
      return sum + Math.round(base * 1.55);
    }
    if (affix.valueTier === "master") {
      return sum + Math.round(base * 1.15);
    }
    return sum + base;
  }, 0);
  const positiveIds = new Set(
    affixes.filter((affix) => affix.polarity === "positive").map((affix) => affix.definition.id),
  );
  let synergy = 0;
  if (positiveIds.has("affix.crit_chance") && positiveIds.has("affix.crit_multiplier")) {
    synergy += 8;
  }
  if (positiveIds.has("affix.poison_damage_per_tick") && positiveIds.has("affix.poison_stacks_applied")) {
    synergy += 8;
  }
  if (positiveIds.has("affix.attack_speed") && positiveIds.has("affix.physical_skill_damage")) {
    synergy += 5;
  }
  return tierScore + affixScore + synergy;
}

function priceForItem(item) {
  if (item.tier === "legendary") {
    return 65 + Math.round(item.score / 4);
  }
  const base = { basic: 18, master: 32, cursed: 40 }[item.tier];
  return base + Math.max(0, Math.round((item.score - 45) / 5));
}

function generateItem(seed, index, config) {
  const random = rngFrom(`${seed}|${index}`);
  const tier = pickWeighted(
    gearTiers.map((tierId) => ({ value: tierId, weight: config.tierWeights[tierId] })),
    random,
  );
  if (tier === "legendary") {
    const legendary = pickWeighted(
      legendaryGearItems.map((item) => ({ value: item, weight: item.slot === "weapon" ? config.slotWeights.weapon : 1 })),
      random,
    );
    return {
      ...legendary,
      id: `${legendary.id}.${seed}.${index}`,
      price: priceForItem(legendary),
      isAmazing: legendary.score >= config.amazingThreshold,
      displayAffixes: legendary.affixes,
      scoreBreakdown: "Legendary authored payoff item.",
    };
  }

  const slot = pickWeighted(
    gearSlots.map((slotId) => ({ value: slotId, weight: config.slotWeights[slotId] })),
    random,
  );
  const affixes = selectGeneratedAffixes(tier, random, config);
  const item = {
    id: `gear.generated.${seed}.${index}`,
    slot,
    tier,
    affixes,
    name: "",
    score: scoreGeneratedItem(tier, affixes),
  };
  item.name = formatGeneratedGearTitle(item);
  item.price = priceForItem(item);
  item.isAmazing = item.score >= config.amazingThreshold;
  item.displayAffixes = affixes.map(formatAffixValue);
  item.scoreBreakdown = createScoreBreakdown(item);
  return item;
}

function createScoreBreakdown(item) {
  const positiveCount = item.affixes.filter((affix) => affix.polarity === "positive").length;
  const downsideCount = item.affixes.filter((affix) => affix.polarity === "downside").length;
  return `${tierLabels[item.tier]} base, ${positiveCount} positive affix${positiveCount === 1 ? "" : "es"}${downsideCount ? `, ${downsideCount} downside` : ""}.`;
}

function generateShop(seed, config) {
  return Array.from({ length: config.shopSize }, (_, index) => generateItem(seed, index, config));
}

function getNextRerollCost(rerollCount) {
  return (rerollCount + 1) * 5;
}

function applyCurrentInputs() {
  state.config.startingGold = clampNumber(elements.startingGold.value, 0, 9999, baseline.startingGold);
  state.config.shopSize = clampNumber(elements.shopSize.value, 1, 12, baseline.shopSize);
  state.config.amazingThreshold = clampNumber(elements.amazingThreshold.value, 1, 200, baseline.amazingThreshold);
}

function clampNumber(value, min, max, fallback) {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) {
    return fallback;
  }
  return Math.min(max, Math.max(min, parsed));
}

function startNewSession() {
  applyCurrentInputs();
  state.seed += 1;
  state.currentGold = state.config.startingGold;
  state.rerollCount = 0;
  state.goldSpent = 0;
  state.seenItems = [];
  state.bestItem = null;
  rollCurrentShop("Generated a fresh shop.");
}

function rerollShop() {
  applyCurrentInputs();
  const cost = getNextRerollCost(state.rerollCount);
  if (state.currentGold < cost) {
    elements.shopNote.textContent = `Need ${cost}g for the next reroll.`;
    render();
    return;
  }
  state.currentGold -= cost;
  state.goldSpent += cost;
  state.rerollCount += 1;
  state.seed += 1;
  rollCurrentShop(`Rerolled for ${cost}g.`);
}

function rollCurrentShop(note) {
  state.shopItems = generateShop(state.seed, state.config);
  state.seenItems.push(...state.shopItems);
  for (const item of state.shopItems) {
    if (!state.bestItem || item.score > state.bestItem.score) {
      state.bestItem = item;
    }
  }
  elements.shopNote.textContent = note;
  render();
}

function renderSliderControls(container, entries, weights, labelFor, onChange) {
  container.innerHTML = "";
  for (const entry of entries) {
    const row = document.createElement("label");
    row.className = "slider-row";
    row.innerHTML = `
      <span class="slider-label"><strong>${labelFor(entry)}</strong><span>${entry}</span></span>
      <input type="range" min="0" max="100" step="1" value="${weights[entry] ?? 0}">
      <input class="weight-number" type="number" min="0" max="100" step="1" value="${weights[entry] ?? 0}">
      <span class="probability-readout" data-probability-for="${entry}">0.0%</span>
    `;
    const slider = row.querySelector("input[type='range']");
    const number = row.querySelector("input[type='number']");
    const update = (value) => {
      const next = clampNumber(value, 0, 100, weights[entry] ?? 0);
      weights[entry] = next;
      slider.value = String(next);
      number.value = String(next);
      onChange();
    };
    slider.addEventListener("input", () => update(slider.value));
    number.addEventListener("input", () => update(number.value));
    container.append(row);
  }
}

function renderProbabilityReadouts(container, weights) {
  const total = sumWeights(weights);
  for (const readout of container.querySelectorAll("[data-probability-for]")) {
    const key = readout.dataset.probabilityFor;
    const weight = Number(weights[key] || 0);
    readout.textContent = total > 0 ? formatPercent(weight / total) : "0.0%";
  }
}

function setupControls() {
  renderSliderControls(elements.tierControls, gearTiers, state.config.tierWeights, (tier) => tierLabels[tier], render);
  renderSliderControls(elements.slotControls, gearSlots, state.config.slotWeights, (slot) => slotLabels[slot], render);
  renderSliderControls(
    elements.affixControls,
    gearAffixDefinitions.map((definition) => definition.id),
    state.config.affixWeights,
    (affixId) => gearAffixDefinitions.find((definition) => definition.id === affixId).name,
    render,
  );
}

function render() {
  applyCurrentInputs();
  elements.seedReadout.textContent = `Seed ${state.seed}`;
  elements.currentGold.textContent = String(state.currentGold);
  elements.rerollCount.textContent = String(state.rerollCount);
  elements.goldSpent.textContent = String(state.goldSpent);
  const nextCost = getNextRerollCost(state.rerollCount);
  elements.nextRerollCost.textContent = `${nextCost}g`;
  elements.rerollButton.textContent = `Reroll ${nextCost}g`;
  elements.rerollButton.disabled = state.currentGold < nextCost;
  elements.amazingSeen.textContent = String(state.seenItems.filter((item) => item.isAmazing).length);
  elements.tierTotal.textContent = `${sumWeights(state.config.tierWeights)} total`;
  elements.slotTotal.textContent = `${sumWeights(state.config.slotWeights)} total`;
  elements.affixTotal.textContent = `${sumWeights(state.config.affixWeights)} total`;
  renderProbabilityReadouts(elements.tierControls, state.config.tierWeights);
  renderProbabilityReadouts(elements.slotControls, state.config.slotWeights);
  renderProbabilityReadouts(elements.affixControls, state.config.affixWeights);
  renderShop();
  renderBestItem();
  renderDistribution();
}

function renderShop() {
  elements.shopGrid.innerHTML = "";
  for (const item of state.shopItems) {
    elements.shopGrid.append(createItemCard(item));
  }
}

function createItemCard(item, compact = false) {
  const card = document.createElement("article");
  card.className = `item-card tier-${item.tier} slot-${item.slot}`;
  const affixHtml = item.displayAffixes
    .map((label, index) => {
      const affix = item.affixes?.[index];
      const kind = item.tier === "legendary" ? "legendary" : affix?.polarity ?? "positive";
      return `<span class="affix-pill affix-${kind}">${escapeHtml(label)}</span>`;
    })
    .join("");
  card.innerHTML = `
    <div class="item-card-header">
      <h4>${escapeHtml(item.name)}</h4>
      <span class="slot-badge slot-badge-${item.slot}">${slotLabels[item.slot]}</span>
    </div>
    <strong class="tier-badge tier-badge-${item.tier}">${tierLabels[item.tier]}</strong>
    <div class="affix-list">${affixHtml}</div>
    <span class="score-badge ${item.isAmazing ? "amazing" : ""}">Score ${item.score}</span>
    <div class="item-footer">
      <span class="price">${item.price}g</span>
      <span>${escapeHtml(item.scoreBreakdown)}</span>
      ${item.isAmazing ? '<span class="amazing-tag">Amazing</span>' : ""}
    </div>
  `;
  if (compact) {
    card.querySelector(".item-footer span:nth-child(2)")?.remove();
  }
  return card;
}

function renderBestItem() {
  elements.bestScore.textContent = `Best ${state.bestItem?.score ?? 0}`;
  elements.bestItem.innerHTML = "";
  if (!state.bestItem) {
    elements.bestItem.className = "best-item empty-note";
    elements.bestItem.textContent = "No shop generated yet.";
    return;
  }
  elements.bestItem.className = "best-item";
  elements.bestItem.append(createItemCard(state.bestItem, true));
}

function renderDistribution() {
  elements.totalItemsSeen.textContent = `${state.seenItems.length} items`;
  if (!state.seenItems.length) {
    elements.distribution.innerHTML = '<p class="empty-note">Generate shops to see item type distribution.</p>';
    return;
  }
  const counts = Object.fromEntries(gearTiers.map((tier) => [tier, 0]));
  for (const item of state.seenItems) {
    counts[item.tier] += 1;
  }
  const max = Math.max(...Object.values(counts), 1);
  elements.distribution.innerHTML = gearTiers
    .map((tier) => {
      const count = counts[tier];
      const percent = Math.round((count / state.seenItems.length) * 100);
      return `
        <div class="bar-row">
          <div class="bar-label"><span>${tierLabels[tier]}</span><span>${count} / ${percent}%</span></div>
          <div class="bar-track"><div class="bar-fill" style="width: ${(count / max) * 100}%"></div></div>
        </div>
      `;
    })
    .join("");
}

function runSimulation() {
  applyCurrentInputs();
  const shopCount = 1000;
  let amazingShops = 0;
  let affordableAmazingShops = 0;
  let totalAmazingItems = 0;
  let firstAmazingGoldCosts = [];
  const tierCounts = Object.fromEntries(gearTiers.map((tier) => [tier, 0]));

  for (let shopIndex = 0; shopIndex < shopCount; shopIndex += 1) {
    const shop = generateShop(`sim|${state.seed}|${shopIndex}`, state.config);
    const amazingItems = shop.filter((item) => item.isAmazing);
    const affordableAmazingItems = amazingItems.filter((item) => item.price <= state.config.startingGold);
    if (amazingItems.length) {
      amazingShops += 1;
      totalAmazingItems += amazingItems.length;
      firstAmazingGoldCosts.push(estimateGoldToShop(shopIndex));
    }
    if (affordableAmazingItems.length) {
      affordableAmazingShops += 1;
    }
    for (const item of shop) {
      tierCounts[item.tier] += 1;
    }
  }

  const sortedCosts = firstAmazingGoldCosts.sort((a, b) => a - b);
  elements.simulationResults.className = "simulation-results";
  elements.simulationResults.innerHTML = [
    simLine("Amazing shop rate", `${formatPercent(amazingShops / shopCount)}`),
    simLine("Affordable amazing rate", `${formatPercent(affordableAmazingShops / shopCount)}`),
    simLine("Amazing items per shop", (totalAmazingItems / shopCount).toFixed(2)),
    simLine("Median gold to amazing", sortedCosts.length ? `${percentile(sortedCosts, 0.5)}g` : "none"),
    simLine("P90 gold to amazing", sortedCosts.length ? `${percentile(sortedCosts, 0.9)}g` : "none"),
    simLine("Legendary item rate", formatPercent(tierCounts.legendary / (shopCount * state.config.shopSize))),
  ].join("");
}

function estimateGoldToShop(shopIndex) {
  let total = 0;
  for (let reroll = 0; reroll < shopIndex; reroll += 1) {
    total += getNextRerollCost(reroll);
  }
  return total;
}

function simLine(label, value) {
  return `<div class="sim-line"><span>${label}</span><strong>${value}</strong></div>`;
}

function percentile(values, fraction) {
  if (!values.length) {
    return 0;
  }
  const index = Math.min(values.length - 1, Math.floor((values.length - 1) * fraction));
  return values[index];
}

function formatPercent(value) {
  return `${(value * 100).toFixed(1)}%`;
}

function sumWeights(weights) {
  return Object.values(weights).reduce((sum, value) => sum + Number(value || 0), 0);
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function resetBaseline() {
  state.config = structuredClone(baseline);
  elements.startingGold.value = String(state.config.startingGold);
  elements.shopSize.value = String(state.config.shopSize);
  elements.amazingThreshold.value = String(state.config.amazingThreshold);
  setupControls();
  startNewSession();
}

elements.generateButton.addEventListener("click", startNewSession);
elements.resetButton.addEventListener("click", resetBaseline);
elements.rerollButton.addEventListener("click", rerollShop);
elements.simulateButton.addEventListener("click", runSimulation);
for (const input of [elements.startingGold, elements.shopSize, elements.amazingThreshold]) {
  input.addEventListener("input", render);
}

setupControls();
startNewSession();
