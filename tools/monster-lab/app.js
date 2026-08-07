"use strict";

const mechanics = window.MonsterLabMechanics;
const archetypes = window.MonsterLabArchetypes;
const difficultyBands = window.MonsterLabDifficultyBands;

const baseline = {
  seed: 4001,
  archetypeA: "stonewall",
  archetypeB: "venomproof",
  difficulty: 3,
  monsterKind: "normal",
  sprite: {
    dataUrl: "",
    fileName: "",
    scale: 100,
    floorOffset: 0,
    idlePreset: "idle-bob",
    hitPreset: "hit-jiggle",
  },
};

const scalingProfiles = {
  flat: { label: "Flat", exponent: 0, floor: 1 },
  gentle: { label: "Gentle", exponent: 0.72, floor: 0.24 },
  standard: { label: "Standard", exponent: 1, floor: 0.14 },
  steep: { label: "Steep", exponent: 1.55, floor: 0.06 },
};

const state = {
  seed: baseline.seed,
  monster: null,
  lockedMechanicIds: [],
  sprite: structuredClone(baseline.sprite),
  activeCustomSlot: "custom_a",
  customArchetypes: {
    custom_a: createDefaultCustomArchetype("custom_a", "My Archetype A", ["armor", "resistance"]),
    custom_b: createDefaultCustomArchetype("custom_b", "My Archetype B", ["shielded_hide", "enrage"]),
  },
};

const elements = {
  resetButton: document.querySelector("#reset-button"),
  generateButton: document.querySelector("#generate-button"),
  seedReadout: document.querySelector("#seed-readout"),
  archetypeA: document.querySelector("#archetype-a"),
  archetypeB: document.querySelector("#archetype-b"),
  difficulty: document.querySelector("#difficulty"),
  monsterKind: document.querySelector("#monster-kind"),
  monsterName: document.querySelector("#monster-name"),
  editCustomA: document.querySelector("#edit-custom-a"),
  editCustomB: document.querySelector("#edit-custom-b"),
  customArchetypeName: document.querySelector("#custom-archetype-name"),
  customHpBias: document.querySelector("#custom-hp-bias"),
  customMechanics: document.querySelector("#custom-mechanics"),
  statControls: document.querySelector("#stat-controls"),
  lockMechanics: document.querySelector("#lock-mechanics"),
  monsterTitle: document.querySelector("#monster-title"),
  monsterNote: document.querySelector("#monster-note"),
  difficultyScore: document.querySelector("#difficulty-score"),
  hpReadout: document.querySelector("#hp-readout"),
  ehpReadout: document.querySelector("#ehp-readout"),
  dpsReadout: document.querySelector("#dps-readout"),
  budgetReadout: document.querySelector("#budget-readout"),
  mechanicsCount: document.querySelector("#mechanics-count"),
  mechanicsGrid: document.querySelector("#mechanics-grid"),
  budgetBars: document.querySelector("#budget-bars"),
  pressureGrid: document.querySelector("#pressure-grid"),
  warningCount: document.querySelector("#warning-count"),
  warnings: document.querySelector("#warnings"),
  exportJson: document.querySelector("#export-json"),
  copyJson: document.querySelector("#copy-json"),
  downloadJson: document.querySelector("#download-json"),
  spriteInput: document.querySelector("#sprite-input"),
  spriteActor: document.querySelector("#sprite-actor"),
  spriteImage: document.querySelector("#sprite-image"),
  spriteScale: document.querySelector("#sprite-scale"),
  spriteOffset: document.querySelector("#sprite-offset"),
  idlePreset: document.querySelector("#idle-preset"),
  hitPreset: document.querySelector("#hit-preset"),
  previewHit: document.querySelector("#preview-hit"),
  clearSprite: document.querySelector("#clear-sprite"),
};

function createDefaultCustomArchetype(id, name, enabledIds) {
  return {
    id,
    name,
    tone: "custom enemy pressure profile",
    baseHpBias: 1,
    mechanicWeights: Object.fromEntries(enabledIds.map((mechanicId) => [mechanicId, 50])),
    mechanicConfigs: Object.fromEntries(
      mechanics.map((mechanic) => {
        const range = mechanic.curves[3] ?? [mechanic.min, mechanic.max];
        return [
          mechanic.id,
          {
            enabled: enabledIds.includes(mechanic.id),
            weight: enabledIds.includes(mechanic.id) ? 50 : 0,
            min: range[0],
            max: range[1],
            scaling: "standard",
          },
        ];
      }),
    ),
    nameParts: {
      prefixes: ["Custom", "Marked", "Named"],
      nouns: ["Monster", "Threat", "Enemy"],
    },
  };
}

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

function randomInt(random, min, max) {
  return Math.round(min + random() * (max - min));
}

function pickWeighted(entries, random) {
  const total = entries.reduce((sum, entry) => sum + Math.max(0, entry.weight), 0);
  if (total <= 0) {
    return entries[0]?.value;
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

function setupControls() {
  refreshArchetypeSelects();
  elements.archetypeB.innerHTML = elements.archetypeA.innerHTML;
  elements.difficulty.innerHTML = difficultyBands
    .map((band) => `<option value="${band.id}">${band.id}. ${escapeHtml(band.name)}</option>`)
    .join("");

  elements.archetypeA.value = baseline.archetypeA;
  elements.archetypeB.value = baseline.archetypeB;
  elements.difficulty.value = String(baseline.difficulty);
  elements.monsterKind.value = baseline.monsterKind;
  elements.spriteScale.value = String(baseline.sprite.scale);
  elements.spriteOffset.value = String(baseline.sprite.floorOffset);
  elements.idlePreset.value = baseline.sprite.idlePreset;
  elements.hitPreset.value = baseline.sprite.hitPreset;

  for (const input of [
    elements.archetypeA,
    elements.archetypeB,
    elements.difficulty,
    elements.monsterKind,
  ]) {
    input.addEventListener("change", generateMonster);
  }
  elements.monsterName.addEventListener("input", applyNameOverride);
  elements.editCustomA.addEventListener("click", () => setActiveCustomSlot("custom_a"));
  elements.editCustomB.addEventListener("click", () => setActiveCustomSlot("custom_b"));
  elements.customArchetypeName.addEventListener("input", updateActiveCustomArchetype);
  elements.customHpBias.addEventListener("input", updateActiveCustomArchetype);
  elements.generateButton.addEventListener("click", () => {
    state.seed += 1;
    generateMonster();
  });
  elements.resetButton.addEventListener("click", resetLab);
  elements.lockMechanics.addEventListener("change", () => {
    state.lockedMechanicIds = elements.lockMechanics.checked
      ? state.monster.mechanics.map((entry) => entry.id)
      : [];
  });
  elements.spriteInput.addEventListener("change", loadSpriteFile);
  elements.spriteScale.addEventListener("input", updateSpriteConfig);
  elements.spriteOffset.addEventListener("input", updateSpriteConfig);
  elements.idlePreset.addEventListener("change", updateSpriteConfig);
  elements.hitPreset.addEventListener("change", updateSpriteConfig);
  elements.previewHit.addEventListener("click", previewHit);
  elements.clearSprite.addEventListener("click", clearSprite);
  elements.copyJson.addEventListener("click", copyJson);
  elements.downloadJson.addEventListener("click", downloadJson);
}

function refreshArchetypeSelects() {
  const selectedA = elements.archetypeA.value;
  const selectedB = elements.archetypeB.value;
  const options = [
    ...Object.values(state.customArchetypes).map((archetype) => ({
      id: archetype.id,
      name: archetype.name,
      group: "Custom",
    })),
    ...archetypes.map((archetype) => ({
      id: archetype.id,
      name: archetype.name,
      group: "Built-in",
    })),
  ];
  elements.archetypeA.innerHTML = options
    .map((option) => `<option value="${option.id}">${escapeHtml(option.group)} - ${escapeHtml(option.name)}</option>`)
    .join("");
  elements.archetypeB.innerHTML = elements.archetypeA.innerHTML;
  const ids = new Set(options.map((option) => option.id));
  if (ids.has(selectedA)) {
    elements.archetypeA.value = selectedA;
  }
  if (ids.has(selectedB)) {
    elements.archetypeB.value = selectedB;
  }
}

function setActiveCustomSlot(slotId) {
  state.activeCustomSlot = slotId;
  elements.editCustomA.classList.toggle("active-tab", slotId === "custom_a");
  elements.editCustomB.classList.toggle("active-tab", slotId === "custom_b");
  renderCustomArchetypeEditor();
}

function updateActiveCustomArchetype() {
  const custom = state.customArchetypes[state.activeCustomSlot];
  custom.name = elements.customArchetypeName.value.trim() || (state.activeCustomSlot === "custom_a" ? "My Archetype A" : "My Archetype B");
  custom.baseHpBias = clampNumber(elements.customHpBias.value, 70, 150, 100) / 100;
  custom.nameParts.prefixes = [custom.name.split(/\s+/)[0] || "Custom"];
  refreshArchetypeSelects();
  restoreSelectedArchetypes();
  generateMonster();
}

function renderCustomArchetypeEditor() {
  const custom = state.customArchetypes[state.activeCustomSlot];
  elements.customArchetypeName.value = custom.name;
  elements.customHpBias.value = String(Math.round(custom.baseHpBias * 100));
  elements.customMechanics.innerHTML = "";
  for (const mechanic of mechanics) {
    const config = custom.mechanicConfigs[mechanic.id];
    const card = document.createElement("article");
    card.className = "custom-mechanic";
    card.innerHTML = `
      <div class="custom-mechanic-header">
        <label>
          <input type="checkbox" data-field="enabled" ${config.enabled ? "checked" : ""}>
          <span>${escapeHtml(mechanic.name)}</span>
        </label>
        <span>${escapeHtml(mechanic.valueLabel)}</span>
      </div>
      <div class="custom-mechanic-fields">
        <label class="mini-field">
          <span>Weight</span>
          <input type="number" min="0" max="100" step="1" value="${config.weight}" data-field="weight">
        </label>
        <label class="mini-field">
          <span>Low</span>
          <input type="number" min="${mechanic.min}" max="${mechanic.max}" step="1" value="${config.min}" data-field="min">
        </label>
        <label class="mini-field">
          <span>High</span>
          <input type="number" min="${mechanic.min}" max="${mechanic.max}" step="1" value="${config.max}" data-field="max">
        </label>
        <label class="mini-field">
          <span>Scaling</span>
          <select data-field="scaling">
            ${Object.entries(scalingProfiles)
              .map(([id, profile]) => `<option value="${id}" ${config.scaling === id ? "selected" : ""}>${profile.label}</option>`)
              .join("")}
          </select>
        </label>
      </div>
    `;
    for (const input of card.querySelectorAll("input, select")) {
      input.addEventListener("input", () => updateCustomMechanic(mechanic.id, card));
      input.addEventListener("change", () => updateCustomMechanic(mechanic.id, card));
    }
    elements.customMechanics.append(card);
  }
}

function updateCustomMechanic(mechanicId, card) {
  const custom = state.customArchetypes[state.activeCustomSlot];
  const mechanic = getMechanic(mechanicId);
  const config = custom.mechanicConfigs[mechanicId];
  const enabled = card.querySelector("[data-field='enabled']").checked;
  const weight = clampNumber(card.querySelector("[data-field='weight']").value, 0, 100, config.weight);
  const min = clampNumber(card.querySelector("[data-field='min']").value, mechanic.min, mechanic.max, config.min);
  const max = clampNumber(card.querySelector("[data-field='max']").value, mechanic.min, mechanic.max, config.max);
  config.enabled = enabled;
  config.weight = enabled ? Math.max(1, weight) : weight;
  config.min = Math.min(min, max);
  config.max = Math.max(min, max);
  config.scaling = card.querySelector("[data-field='scaling']").value;
  if (enabled) {
    custom.mechanicWeights[mechanicId] = config.weight;
  } else {
    delete custom.mechanicWeights[mechanicId];
  }
  if (elements.lockMechanics.checked) {
    state.lockedMechanicIds = state.monster.mechanics.map((entry) => entry.id);
  }
  generateMonster();
}

function restoreSelectedArchetypes() {
  const ids = new Set([...Object.keys(state.customArchetypes), ...archetypes.map((archetype) => archetype.id)]);
  if (!ids.has(elements.archetypeA.value)) {
    elements.archetypeA.value = baseline.archetypeA;
  }
  if (!ids.has(elements.archetypeB.value)) {
    elements.archetypeB.value = baseline.archetypeB;
  }
}

function resetLab() {
  state.seed = baseline.seed;
  state.lockedMechanicIds = [];
  state.sprite = structuredClone(baseline.sprite);
  state.customArchetypes = {
    custom_a: createDefaultCustomArchetype("custom_a", "My Archetype A", ["armor", "resistance"]),
    custom_b: createDefaultCustomArchetype("custom_b", "My Archetype B", ["shielded_hide", "enrage"]),
  };
  refreshArchetypeSelects();
  elements.archetypeA.value = baseline.archetypeA;
  elements.archetypeB.value = baseline.archetypeB;
  elements.difficulty.value = String(baseline.difficulty);
  elements.monsterKind.value = baseline.monsterKind;
  elements.lockMechanics.checked = false;
  elements.spriteInput.value = "";
  elements.spriteScale.value = String(baseline.sprite.scale);
  elements.spriteOffset.value = String(baseline.sprite.floorOffset);
  elements.idlePreset.value = baseline.sprite.idlePreset;
  elements.hitPreset.value = baseline.sprite.hitPreset;
  setActiveCustomSlot("custom_a");
  generateMonster();
}

function generateMonster() {
  const random = rngFrom(`${state.seed}|monster`);
  const archetypeA = getArchetype(elements.archetypeA.value);
  const archetypeB = getArchetype(elements.archetypeB.value);
  const band = getDifficultyBand(Number(elements.difficulty.value));
  const kind = elements.monsterKind.value;
  const kindMultiplier = getKindMultiplier(kind);
  const hpBase = randomInt(random, band.baseHp[0], band.baseHp[1]);
  const hp = Math.round(hpBase * ((archetypeA.baseHpBias + archetypeB.baseHpBias) / 2) * kindMultiplier.hp);
  const budget = Math.round(band.budget * kindMultiplier.budget);
  const mechanicsForMonster = selectMechanics(random, archetypeA, archetypeB, band, kind);
  const values = mechanicsForMonster.map((entry) => createMechanicValue(random, entry.mechanic, band, entry.config));
  const name = createMonsterName(random, archetypeA, archetypeB);

  state.monster = {
    id: slugify(name),
    name,
    kind,
    seed: state.seed,
    archetypes: [archetypeA.id, archetypeB.id],
    archetypeNames: [archetypeA.name, archetypeB.name],
    difficulty: band.id,
    difficultyName: band.name,
    duration: Math.round(band.duration * kindMultiplier.duration),
    targetDps: band.targetDps,
    hp,
    mechanics: values,
    budget,
    sprite: structuredClone(state.sprite),
  };
  finishMonsterModel();
  elements.monsterName.value = state.monster.name;
  render();
}

function getKindMultiplier(kind) {
  if (kind === "elite") {
    return { hp: 1.18, budget: 1.2, duration: 1.05, extraMechanics: 1 };
  }
  if (kind === "boss") {
    return { hp: 1.42, budget: 1.48, duration: 1.16, extraMechanics: 2 };
  }
  if (kind === "bespoke") {
    return { hp: 1, budget: 1, duration: 1, extraMechanics: 0 };
  }
  return { hp: 1, budget: 1, duration: 1, extraMechanics: 0 };
}

function selectMechanics(random, archetypeA, archetypeB, band, kind) {
  if (elements.lockMechanics.checked && state.lockedMechanicIds.length) {
    return state.lockedMechanicIds
      .map((mechanicId) => ({
        mechanic: getMechanic(mechanicId),
        config: getMergedMechanicConfig(mechanicId, [archetypeA, archetypeB]),
      }))
      .filter((entry) => entry.mechanic);
  }
  const kindMultiplier = getKindMultiplier(kind);
  const count = Math.min(
    mechanics.length,
    randomInt(random, band.mechanicCount[0], band.mechanicCount[1]) + kindMultiplier.extraMechanics,
  );
  const mergedWeights = {};
  for (const archetype of [archetypeA, archetypeB]) {
    for (const [mechanicId, weight] of Object.entries(archetype.mechanicWeights)) {
      mergedWeights[mechanicId] = (mergedWeights[mechanicId] ?? 0) + weight;
    }
  }

  const selected = [];
  const remaining = mechanics.filter((mechanic) => mergedWeights[mechanic.id]);
  while (selected.length < count && remaining.length) {
    const candidate = pickWeighted(
      remaining.map((mechanic) => ({ value: mechanic, weight: mergedWeights[mechanic.id] })),
      random,
    );
    selected.push({
      mechanic: candidate,
      config: getMergedMechanicConfig(candidate.id, [archetypeA, archetypeB]),
    });
    remaining.splice(remaining.indexOf(candidate), 1);
  }
  return selected;
}

function getMergedMechanicConfig(mechanicId, selectedArchetypes) {
  const configs = selectedArchetypes
    .map((archetype) => archetype.mechanicConfigs?.[mechanicId])
    .filter((config) => config?.enabled);
  if (!configs.length) {
    return null;
  }
  return {
    min: Math.round(configs.reduce((sum, config) => sum + config.min, 0) / configs.length),
    max: Math.round(configs.reduce((sum, config) => sum + config.max, 0) / configs.length),
    scaling: configs[0].scaling,
  };
}

function createMechanicValue(random, mechanic, band, config = null) {
  const range = config ? getScaledCustomRange(config, mechanic, band.id) : mechanic.curves[band.id] ?? [mechanic.min, mechanic.max];
  const value = randomInt(random, range[0], range[1]);
  return {
    id: mechanic.id,
    name: mechanic.name,
    shortName: mechanic.shortName,
    description: mechanic.description,
    tags: mechanic.tags,
    valueLabel: mechanic.valueLabel,
    value,
    range,
    scaling: config?.scaling ?? "built-in",
    cost: scoreMechanicCost(mechanic, value),
  };
}

function getScaledCustomRange(config, mechanic, difficultyId) {
  const profile = scalingProfiles[config.scaling] ?? scalingProfiles.standard;
  if (profile.exponent === 0) {
    return [
      clampNumber(config.min, mechanic.min, mechanic.max, mechanic.min),
      clampNumber(config.max, mechanic.min, mechanic.max, mechanic.max),
    ];
  }
  const t = Math.pow((difficultyId - 1) / Math.max(1, difficultyBands.length - 1), profile.exponent);
  const spread = Math.max(1, config.max - config.min);
  const high = config.min + spread * Math.max(profile.floor, t);
  const low = config.min + spread * Math.max(0, t - 0.22);
  return [
    Math.round(clampNumber(low, mechanic.min, mechanic.max, config.min)),
    Math.round(clampNumber(high, mechanic.min, mechanic.max, config.max)),
  ];
}

function finishMonsterModel() {
  const monster = state.monster;
  const mechanicCost = monster.mechanics.reduce((sum, entry) => sum + entry.cost, 0);
  const hpCost = Math.round(monster.hp / 8);
  const synergyCost = calculateSynergyCost(monster.mechanics);
  const totalCost = hpCost + mechanicCost + synergyCost;
  const mitigationMultiplier = monster.mechanics.reduce((multiplier, entry) => {
    const mechanic = getMechanic(entry.id);
    return multiplier + mechanic.effectiveHpPerValue * entry.value;
  }, 1);
  const shieldHp = monster.mechanics
    .filter((entry) => entry.id === "shielded_hide")
    .reduce((sum, entry) => sum + entry.value, 0);
  const effectiveHp = Math.round(monster.hp * mitigationMultiplier + shieldHp);
  const requiredDps = effectiveHp / monster.duration;
  const pressure = calculatePressure(monster, requiredDps);
  const warnings = createWarnings(monster, totalCost, pressure);

  monster.model = {
    hpCost,
    mechanicCost,
    synergyCost,
    totalCost,
    budgetDelta: totalCost - monster.budget,
    effectiveHp,
    requiredDps,
    pressure,
    warnings,
  };
}

function calculateSynergyCost(selectedMechanics) {
  const ids = new Set(selectedMechanics.map((entry) => entry.id));
  let cost = 0;
  if (ids.has("armor") && ids.has("resistance")) {
    cost += 12;
  }
  if (ids.has("regeneration") && ids.has("shielded_hide")) {
    cost += 10;
  }
  if (ids.has("resistance") && ids.has("poison_cleanse")) {
    cost += 16;
  }
  if (ids.has("evasion") && ids.has("thorns")) {
    cost += 10;
  }
  if (ids.has("enrage") && ids.has("regeneration")) {
    cost += 8;
  }
  return cost;
}

function calculatePressure(monster, requiredDps) {
  const band = getDifficultyBand(monster.difficulty);
  const baseRatio = requiredDps / band.targetDps;
  const modifiers = monster.mechanics.reduce(
    (totals, entry) => {
      const mechanic = getMechanic(entry.id);
      const scale = entry.value / Math.max(1, mechanic.max);
      totals.poison += mechanic.poisonModifier * scale;
      totals.burst += mechanic.burstModifier * scale;
      totals.sustained += mechanic.sustainedModifier * scale;
      return totals;
    },
    { poison: 0, burst: 0, sustained: 0 },
  );
  return {
    poison: clampPressure(baseRatio - modifiers.poison),
    burst: clampPressure(baseRatio - modifiers.burst),
    sustained: clampPressure(baseRatio - modifiers.sustained),
  };
}

function clampPressure(value) {
  return Math.max(0.2, Math.min(2.4, value));
}

function createWarnings(monster, totalCost, pressure) {
  const warnings = [];
  const ids = new Set(monster.mechanics.map((entry) => entry.id));
  if (totalCost > monster.budget * 1.12) {
    warnings.push({
      title: "Over Budget",
      body: "This monster is likely above the selected difficulty band. Consider lowering HP, dropping a mechanic, or marking it elite/boss.",
    });
  }
  if (ids.has("armor") && ids.has("resistance")) {
    warnings.push({
      title: "Double Mitigation",
      body: "Armor and resistance together can flatten too many builds unless the monster is meant to be a hard defensive check.",
    });
  }
  if (ids.has("resistance") && ids.has("poison_cleanse")) {
    warnings.push({
      title: "Poison Suppression",
      body: "Resistance plus cleanse may invalidate poison routes. Keep this rare or attach a clear monster identity to it.",
    });
  }
  if (pressure.poison > 1.45) {
    warnings.push({
      title: "Poison Pressure High",
      body: "The heuristic model expects poison-heavy builds to struggle more than the selected band target.",
    });
  }
  if (pressure.burst > 1.45) {
    warnings.push({
      title: "Burst Pressure High",
      body: "The monster asks for more direct burst reliability than this band usually expects.",
    });
  }
  if (monster.mechanics.length >= 4 && monster.kind === "normal") {
    warnings.push({
      title: "Busy Normal Monster",
      body: "Four or more mechanics on a normal enemy may be harder to read than the fight needs.",
    });
  }
  return warnings;
}

function scoreMechanicCost(mechanic, value) {
  return Math.round(mechanic.baseCost + value * mechanic.costPerValue);
}

function createMonsterName(random, archetypeA, archetypeB) {
  const prefixPool = [...archetypeA.nameParts.prefixes, ...archetypeB.nameParts.prefixes];
  const nounPool = [...archetypeA.nameParts.nouns, ...archetypeB.nameParts.nouns];
  const prefix = prefixPool[Math.floor(random() * prefixPool.length)];
  const noun = nounPool[Math.floor(random() * nounPool.length)];
  return `${prefix} ${noun}`;
}

function applyNameOverride() {
  if (!state.monster) {
    return;
  }
  const name = elements.monsterName.value.trim() || "Unnamed Monster";
  state.monster.name = name;
  state.monster.id = slugify(name);
  render(false);
}

function render(rebuildControls = true) {
  if (!state.monster) {
    return;
  }
  const monster = state.monster;
  elements.seedReadout.textContent = `Seed ${state.seed}`;
  elements.monsterTitle.textContent = monster.name;
  elements.monsterNote.textContent = `${monster.archetypeNames.join(" + ")} - ${monster.difficultyName} - ${titleCase(monster.kind)}`;
  elements.difficultyScore.textContent = `Score ${monster.model.totalCost}`;
  elements.hpReadout.textContent = formatNumber(monster.hp);
  elements.ehpReadout.textContent = formatNumber(monster.model.effectiveHp);
  elements.dpsReadout.textContent = monster.model.requiredDps.toFixed(1);
  elements.budgetReadout.textContent = `${monster.model.totalCost} / ${monster.budget}`;
  elements.mechanicsCount.textContent = `${monster.mechanics.length} selected`;
  elements.warningCount.textContent = `${monster.model.warnings.length} flags`;

  if (rebuildControls) {
    renderStatControls();
  }
  renderMechanics();
  renderBudget();
  renderPressure();
  renderWarnings();
  renderSprite();
  renderExport();
}

function renderStatControls() {
  elements.statControls.innerHTML = "";
  elements.statControls.append(createNumberSlider("HP", state.monster.hp, 40, 1400, 5, (value) => {
    state.monster.hp = value;
    finishMonsterModel();
    render(false);
  }));

  for (const entry of state.monster.mechanics) {
    const mechanic = getMechanic(entry.id);
    elements.statControls.append(
      createNumberSlider(mechanic.shortName, entry.value, mechanic.min, mechanic.max, 1, (value) => {
        entry.value = value;
        entry.cost = scoreMechanicCost(mechanic, value);
        finishMonsterModel();
        render(false);
      }),
    );
  }
}

function createNumberSlider(label, value, min, max, step, onChange) {
  const row = document.createElement("label");
  row.className = "slider-row";
  row.innerHTML = `
    <span class="slider-label"><strong>${escapeHtml(label)}</strong><span>${value}</span></span>
    <input type="range" min="${min}" max="${max}" step="${step}" value="${value}">
    <input class="weight-number" type="number" min="${min}" max="${max}" step="${step}" value="${value}">
  `;
  const labelValue = row.querySelector(".slider-label span");
  const slider = row.querySelector("input[type='range']");
  const number = row.querySelector("input[type='number']");
  const update = (raw) => {
    const next = clampNumber(raw, min, max, value);
    slider.value = String(next);
    number.value = String(next);
    labelValue.textContent = String(next);
    onChange(next);
  };
  slider.addEventListener("input", () => update(slider.value));
  number.addEventListener("input", () => update(number.value));
  return row;
}

function renderMechanics() {
  elements.mechanicsGrid.innerHTML = "";
  for (const entry of state.monster.mechanics) {
    const card = document.createElement("article");
    card.className = "mechanic-card";
    card.innerHTML = `
      <div class="mechanic-meta">
        <h3>${escapeHtml(entry.name)}</h3>
        <strong>${entry.value} ${escapeHtml(entry.valueLabel)}</strong>
      </div>
      <p>${escapeHtml(entry.description)}</p>
      <div class="tag-row">${entry.tags.map((tag) => `<span class="tag">${escapeHtml(tag)}</span>`).join("")}</div>
      <div class="mechanic-meta"><span>Range ${entry.range[0]}-${entry.range[1]} / ${entry.scaling}</span><strong>Cost ${entry.cost}</strong></div>
    `;
    elements.mechanicsGrid.append(card);
  }
}

function renderBudget() {
  const rows = [
    ["HP", state.monster.model.hpCost, "#77d9d0"],
    ["Mechanics", state.monster.model.mechanicCost, "#f0c36b"],
    ["Synergy", state.monster.model.synergyCost, "#b86a9c"],
  ];
  elements.budgetBars.innerHTML = rows
    .map(([label, value, color]) => {
      const width = Math.min(100, (value / Math.max(1, state.monster.budget)) * 100);
      return `
        <div class="bar-row">
          <div class="bar-label"><span>${label}</span><span>${value}</span></div>
          <div class="bar-track"><div class="bar-fill" style="width: ${width}%; background: ${color};"></div></div>
        </div>
      `;
    })
    .join("");
}

function renderPressure() {
  const pressure = state.monster.model.pressure;
  elements.pressureGrid.innerHTML = [
    pressureCard("Poison Builds", pressure.poison),
    pressureCard("Burst Builds", pressure.burst),
    pressureCard("Sustained DPS", pressure.sustained),
  ].join("");
}

function pressureCard(label, value) {
  const className = value >= 1.35 ? "pressure-high" : value >= 1.05 ? "pressure-mid" : "pressure-low";
  const text = value >= 1.35 ? "Punished" : value >= 1.05 ? "Checked" : "Favored";
  return `
    <article class="pressure-card ${className}">
      <span>${label}</span>
      <strong>${text} ${value.toFixed(2)}x</strong>
    </article>
  `;
}

function renderWarnings() {
  if (!state.monster.model.warnings.length) {
    elements.warnings.innerHTML = '<p class="empty-note">No balance warnings for this candidate.</p>';
    return;
  }
  elements.warnings.innerHTML = state.monster.model.warnings
    .map(
      (warning) => `
        <article class="warning-card">
          <span>${escapeHtml(warning.title)}</span>
          <p>${escapeHtml(warning.body)}</p>
        </article>
      `,
    )
    .join("");
}

function updateSpriteConfig() {
  state.sprite.scale = clampNumber(elements.spriteScale.value, 60, 170, 100);
  state.sprite.floorOffset = clampNumber(elements.spriteOffset.value, -40, 40, 0);
  state.sprite.idlePreset = elements.idlePreset.value;
  state.sprite.hitPreset = elements.hitPreset.value;
  if (state.monster) {
    state.monster.sprite = structuredClone(state.sprite);
  }
  renderSprite();
  renderExport();
}

function loadSpriteFile() {
  const file = elements.spriteInput.files[0];
  if (!file) {
    return;
  }
  const reader = new FileReader();
  reader.addEventListener("load", () => {
    state.sprite.dataUrl = String(reader.result);
    state.sprite.fileName = file.name;
    if (state.monster) {
      state.monster.sprite = structuredClone(state.sprite);
    }
    renderSprite();
    renderExport();
  });
  reader.readAsDataURL(file);
}

function clearSprite() {
  state.sprite.dataUrl = "";
  state.sprite.fileName = "";
  elements.spriteInput.value = "";
  if (state.monster) {
    state.monster.sprite = structuredClone(state.sprite);
  }
  renderSprite();
  renderExport();
}

function renderSprite() {
  const sprite = state.sprite;
  elements.spriteActor.classList.remove("idle-bob", "idle-breathe", "idle-heavy", "idle-still");
  elements.spriteActor.classList.add(sprite.idlePreset);
  elements.spriteActor.style.setProperty("--sprite-scale", String(sprite.scale / 100));
  elements.spriteActor.style.bottom = `${45 + sprite.floorOffset}px`;
  if (sprite.dataUrl) {
    elements.spriteImage.src = sprite.dataUrl;
    elements.spriteActor.classList.add("has-image");
  } else {
    elements.spriteImage.removeAttribute("src");
    elements.spriteActor.classList.remove("has-image");
  }
}

function previewHit() {
  const preset = state.sprite.hitPreset;
  elements.spriteActor.classList.remove("hit-jiggle", "hit-flash", "hit-armor", "hit-poison");
  void elements.spriteActor.offsetWidth;
  elements.spriteActor.classList.add(preset);
  window.setTimeout(() => {
    elements.spriteActor.classList.remove(preset);
  }, 560);
}

function renderExport() {
  const exportModel = {
    project: "DawnBringer",
    tool: "Monster Lab",
    monster: {
      id: state.monster.id,
      name: state.monster.name,
      kind: state.monster.kind,
      difficulty: state.monster.difficulty,
      difficulty_name: state.monster.difficultyName,
      archetypes: state.monster.archetypes,
      hp: state.monster.hp,
      duration: state.monster.duration,
      mechanics: state.monster.mechanics.map((entry) => ({
        id: entry.id,
        value: entry.value,
        range: entry.range,
        scaling: entry.scaling,
        value_label: entry.valueLabel,
        tags: entry.tags,
      })),
      archetype_definitions: state.monster.archetypes
        .map(getArchetype)
        .filter((archetype) => archetype.id.startsWith("custom_"))
        .map((archetype) => ({
          id: archetype.id,
          name: archetype.name,
          base_hp_bias: archetype.baseHpBias,
          mechanics: Object.entries(archetype.mechanicConfigs)
            .filter(([, config]) => config.enabled)
            .map(([mechanicId, config]) => ({
              id: mechanicId,
              weight: config.weight,
              min: config.min,
              max: config.max,
              scaling: config.scaling,
            })),
        })),
      presentation: {
        sprite_file: state.sprite.fileName || "",
        scale: state.sprite.scale / 100,
        floor_offset: state.sprite.floorOffset,
        idle: state.sprite.idlePreset,
        hit: state.sprite.hitPreset,
      },
      balance_model: {
        budget: state.monster.budget,
        total_cost: state.monster.model.totalCost,
        budget_delta: state.monster.model.budgetDelta,
        effective_hp: state.monster.model.effectiveHp,
        required_dps: Number(state.monster.model.requiredDps.toFixed(2)),
        pressure: {
          poison: Number(state.monster.model.pressure.poison.toFixed(2)),
          burst: Number(state.monster.model.pressure.burst.toFixed(2)),
          sustained: Number(state.monster.model.pressure.sustained.toFixed(2)),
        },
        warnings: state.monster.model.warnings.map((warning) => warning.title),
      },
    },
  };
  elements.exportJson.value = JSON.stringify(exportModel, null, 2);
}

async function copyJson() {
  try {
    await navigator.clipboard.writeText(elements.exportJson.value);
    elements.copyJson.textContent = "Copied";
    window.setTimeout(() => {
      elements.copyJson.textContent = "Copy JSON";
    }, 900);
  } catch {
    elements.exportJson.select();
    document.execCommand("copy");
  }
}

function downloadJson() {
  const blob = new Blob([elements.exportJson.value], { type: "application/json" });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = `${state.monster.id || "monster"}.json`;
  link.click();
  URL.revokeObjectURL(link.href);
}

function getArchetype(id) {
  return state.customArchetypes[id] ?? archetypes.find((archetype) => archetype.id === id) ?? archetypes[0];
}

function getMechanic(id) {
  return mechanics.find((mechanic) => mechanic.id === id);
}

function getDifficultyBand(id) {
  return difficultyBands.find((band) => band.id === id) ?? difficultyBands[0];
}

function clampNumber(value, min, max, fallback) {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) {
    return fallback;
  }
  return Math.min(max, Math.max(min, parsed));
}

function titleCase(value) {
  return String(value).replace(/(^|\s)\w/g, (match) => match.toUpperCase());
}

function slugify(value) {
  return String(value)
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
}

function formatNumber(value) {
  return new Intl.NumberFormat("en-US").format(value);
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

setupControls();
renderCustomArchetypeEditor();
generateMonster();
