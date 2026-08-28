"use strict";

const mechanics = window.MonsterLabMechanics;
const archetypes = window.MonsterLabArchetypes;
const difficultyBands = window.MonsterLabDifficultyBands;
const archetypeStorageKey = "dawnbringer.monsterLab.archetypes.v1";
const archetypeLibraryNameStorageKey = "dawnbringer.monsterLab.archetypeLibraryName.v1";

const baseline = {
  seed: 4001,
  archetypeLibraryName: "DawnBringer Monster Archetypes",
  archetypeA: "stonewall",
  archetypeB: "venomproof",
  difficulty: 2,
  tempoProfile: "standard",
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
  flat: { label: "Flat", growth: 0, exponent: 1 },
  gentle: { label: "Gentle", growth: 0.35, exponent: 1 },
  standard: { label: "Standard", growth: 1, exponent: 1 },
  steep: { label: "Steep", growth: 3, exponent: 1.8 },
};

const state = {
  seed: baseline.seed,
  monster: null,
  candidates: [],
  selectedCandidateIndex: 0,
  lockedMechanicIds: [],
  sprite: structuredClone(baseline.sprite),
  archetypeLibraryName: loadSavedArchetypeLibraryName(),
  archetypeCatalog: loadSavedArchetypeCatalog(),
  activeArchetypeId: baseline.archetypeA,
  activeArchetypeDraft: null,
  pendingDeleteArchetypeId: "",
};

const tempoProfiles = [
  {
    id: "burst",
    name: "Burst",
    description: "Short fight window for monsters that should resolve fast.",
    durationRange: [11, 16],
  },
  {
    id: "standard",
    name: "Standard",
    description: "Normal fight window for the selected pressure band.",
    durationRange: [18, 24],
  },
  {
    id: "extended",
    name: "Extended",
    description: "Longer pressure test without changing the difficulty band.",
    durationRange: [26, 34],
  },
  {
    id: "endurance",
    name: "Endurance",
    description: "Long attrition window without increasing the monster's budget.",
    durationRange: [38, 52],
  },
];

const canonicalGodotFields = new Set([
  "armor",
  "poison_resistance",
  "dodge_chance",
  "crit_negation",
  "block",
  "absorb",
  "cleanse_threshold",
  "suppress",
  "slow",
  "stun_duration_ms",
  "interrupt_skip_count",
]);

const elements = {
  resetButton: document.querySelector("#reset-button"),
  generateButton: document.querySelector("#generate-button"),
  generateBatchButton: document.querySelector("#generate-batch-button"),
  seedReadout: document.querySelector("#seed-readout"),
  archetypeA: document.querySelector("#archetype-a"),
  archetypeB: document.querySelector("#archetype-b"),
  secondaryScale: document.querySelector("#secondary-scale"),
  secondaryScaleReadout: document.querySelector("#secondary-scale-readout"),
  difficulty: document.querySelector("#difficulty"),
  tempoProfile: document.querySelector("#tempo-profile"),
  monsterKind: document.querySelector("#monster-kind"),
  batchSize: document.querySelector("#batch-size"),
  monsterName: document.querySelector("#monster-name"),
  archetypeLibraryName: document.querySelector("#archetype-library-name"),
  archetypeEditorSelect: document.querySelector("#archetype-editor-select"),
  archetypeSaveState: document.querySelector("#archetype-save-state"),
  newArchetypeButton: document.querySelector("#new-archetype-button"),
  saveArchetypeButton: document.querySelector("#save-archetype-button"),
  deleteArchetypeButton: document.querySelector("#delete-archetype-button"),
  customArchetypeName: document.querySelector("#custom-archetype-name"),
  customHpBias: document.querySelector("#custom-hp-bias"),
  archetypeTags: document.querySelector("#archetype-tags"),
  archetypeUnlockDifficulty: document.querySelector("#archetype-unlock-difficulty"),
  archetypeRouteWeight: document.querySelector("#archetype-route-weight"),
  archetypeKindNormal: document.querySelector("#archetype-kind-normal"),
  archetypeKindElite: document.querySelector("#archetype-kind-elite"),
  archetypeKindBoss: document.querySelector("#archetype-kind-boss"),
  exportArchetypesButton: document.querySelector("#export-archetypes-button"),
  importArchetypesButton: document.querySelector("#import-archetypes-button"),
  importArchetypesInput: document.querySelector("#import-archetypes-input"),
  customMechanics: document.querySelector("#custom-mechanics"),
  statControls: document.querySelector("#stat-controls"),
  lockMechanics: document.querySelector("#lock-mechanics"),
  monsterTitle: document.querySelector("#monster-title"),
  monsterNote: document.querySelector("#monster-note"),
  difficultyScore: document.querySelector("#difficulty-score"),
  hpReadout: document.querySelector("#hp-readout"),
  ehpReadout: document.querySelector("#ehp-readout"),
  durationReadout: document.querySelector("#duration-readout"),
  targetDpsReadout: document.querySelector("#target-dps-readout"),
  dpsReadout: document.querySelector("#dps-readout"),
  budgetReadout: document.querySelector("#budget-readout"),
  mechanicsCount: document.querySelector("#mechanics-count"),
  candidateCount: document.querySelector("#candidate-count"),
  candidateSummary: document.querySelector("#candidate-summary"),
  candidateList: document.querySelector("#candidate-list"),
  generatorMechanics: document.querySelector("#generator-mechanics"),
  mechanicsGrid: document.querySelector("#mechanics-grid"),
  matchupPreview: document.querySelector("#matchup-preview"),
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
    tags: [],
    unlockDifficulty: 1,
    allowedKinds: ["normal", "elite", "boss"],
    routeWeight: 80,
    baseHpBias: 1,
    mechanicWeights: Object.fromEntries(enabledIds.map((mechanicId) => [mechanicId, 50])),
    mechanicConfigs: Object.fromEntries(
      mechanics.map((mechanic) => {
        const range = mechanic.curves[3] ?? [mechanic.min, mechanic.max];
        return [
          mechanic.id,
          {
            enabled: enabledIds.includes(mechanic.id),
            required: false,
            weight: enabledIds.includes(mechanic.id) ? 50 : 0,
            min: range[0],
            max: range[1],
            scaling: "standard",
            extras: defaultMechanicExtras(mechanic),
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

function hydrateArchetype(source) {
  const enabledIds = Object.keys(source.mechanicWeights ?? {});
  const hydrated = createDefaultCustomArchetype(source.id, source.name, enabledIds);
  hydrated.tone = source.tone ?? hydrated.tone;
  hydrated.tags = normalizeTags(source.tags ?? []);
  hydrated.unlockDifficulty = normalizeDifficultyId(source.unlockDifficulty ?? source.unlock_difficulty ?? hydrated.unlockDifficulty);
  hydrated.allowedKinds = normalizeAllowedKinds(source.allowedKinds ?? source.allowed_kinds ?? hydrated.allowedKinds);
  hydrated.routeWeight = clampNumber(source.routeWeight ?? source.route_weight, 0, 200, hydrated.routeWeight);
  hydrated.baseHpBias = source.baseHpBias ?? source.base_hp_bias ?? hydrated.baseHpBias;
  hydrated.mechanicWeights = { ...(source.mechanicWeights ?? hydrated.mechanicWeights) };
  hydrated.nameParts = structuredClone(source.nameParts ?? hydrated.nameParts);
  for (const mechanic of mechanics) {
    const config = hydrated.mechanicConfigs[mechanic.id];
    const range = mechanic.curves[3] ?? [mechanic.min, mechanic.max];
    config.enabled = Object.hasOwn(hydrated.mechanicWeights, mechanic.id);
    config.required = Boolean(source.mechanicConfigs?.[mechanic.id]?.required);
    config.weight = config.enabled ? hydrated.mechanicWeights[mechanic.id] : 0;
    config.min = range[0];
    config.max = range[1];
    config.scaling = "standard";
    config.extras = normalizeMechanicExtras(mechanic, source.mechanicConfigs?.[mechanic.id]?.extras ?? config.extras);
  }
  return hydrated;
}

function loadSavedArchetypeCatalog() {
  return [];
}

function loadSavedArchetypeLibraryName() {
  try {
    const saved = window.localStorage?.getItem(archetypeLibraryNameStorageKey);
    return saved?.trim() || baseline.archetypeLibraryName;
  } catch {
    return baseline.archetypeLibraryName;
  }
}

function restoreMissingBuiltInArchetypes(savedCatalog) {
  const savedIds = new Set(savedCatalog.map((entry) => entry.id));
  const missingBuiltIns = archetypes
    .filter((entry) => !savedIds.has(entry.id))
    .map(hydrateArchetype);
  return [...missingBuiltIns, ...savedCatalog];
}

function saveArchetypeCatalog() {
  try {
    window.localStorage?.setItem(archetypeStorageKey, JSON.stringify(state.archetypeCatalog));
    window.localStorage?.setItem(archetypeLibraryNameStorageKey, state.archetypeLibraryName);
  } catch {
    elements.archetypeSaveState.textContent = "Saved this session";
  }
}

function clearSavedArchetypeCatalog() {
  try {
    window.localStorage?.removeItem(archetypeStorageKey);
    window.localStorage?.removeItem(archetypeLibraryNameStorageKey);
  } catch {
    // Local storage is optional; the in-memory reset still succeeds.
  }
}

function normalizeImportedArchetype(entry) {
  const fallback = hydrateArchetype(entry);
  fallback.mechanicConfigs = Object.fromEntries(
    mechanics.map((mechanic) => {
      const imported = entry.mechanicConfigs?.[mechanic.id] ?? {};
      const range = mechanic.curves[3] ?? [mechanic.min, mechanic.max];
      const required = Boolean(imported.required);
      const enabled = required || Boolean(imported.enabled ?? Object.hasOwn(fallback.mechanicWeights, mechanic.id));
      return [
        mechanic.id,
        {
          enabled,
          required,
          weight: clampNumber(imported.weight, 0, 100, enabled ? fallback.mechanicWeights[mechanic.id] ?? 50 : 0),
          min: clampNumber(imported.min, mechanic.min, mechanic.max, range[0]),
          max: clampNumber(imported.max, mechanic.min, mechanic.max, range[1]),
          scaling: scalingProfiles[imported.scaling] ? imported.scaling : "standard",
          extras: normalizeMechanicExtras(mechanic, imported.extras),
        },
      ];
    }),
  );
  normalizeArchetypeDraft(fallback);
  return fallback;
}

function cloneArchetype(archetype) {
  return structuredClone(archetype);
}

function normalizeArchetypeDraft(draft) {
  draft.name = draft.name.trim() || "Unnamed Archetype";
  draft.id = slugify(draft.name) || `archetype_${Date.now()}`;
  draft.tags = normalizeTags(draft.tags);
  draft.unlockDifficulty = normalizeDifficultyId(draft.unlockDifficulty);
  draft.allowedKinds = normalizeAllowedKinds(draft.allowedKinds);
  draft.routeWeight = clampNumber(draft.routeWeight, 0, 200, 80);
  draft.baseHpBias = clampNumber(draft.baseHpBias, 0.7, 1.5, 1);
  draft.nameParts.prefixes = [draft.name.split(/\s+/)[0] || "Named"];
  draft.mechanicWeights = {};
  for (const [mechanicId, config] of Object.entries(draft.mechanicConfigs)) {
    const mechanic = getMechanic(mechanicId);
    config.extras = normalizeMechanicExtras(mechanic, config.extras);
    if (config.enabled || config.required) {
      config.enabled = true;
      draft.mechanicWeights[mechanicId] = Math.max(1, Number(config.weight) || 1);
    }
  }
  return draft;
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

function randomFloat(random, min, max) {
  return min + random() * (max - min);
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
  validateCanonicalMechanics();
  elements.difficulty.innerHTML = difficultyBands
    .map((band) => `<option value="${band.id}">${band.id}. ${escapeHtml(band.name)}</option>`)
    .join("");
  elements.archetypeUnlockDifficulty.innerHTML = difficultyBands
    .map((band) => `<option value="${band.id}">${escapeHtml(band.name)}</option>`)
    .join("");
  elements.tempoProfile.innerHTML = tempoProfiles
    .map((profile) => `<option value="${profile.id}">${escapeHtml(tempoProfileLabel(profile, getDifficultyBand(baseline.difficulty)))}</option>`)
    .join("");
  refreshArchetypeSelects();

  elements.archetypeA.value = "";
  elements.archetypeB.value = "";
  elements.archetypeLibraryName.value = state.archetypeLibraryName;
  elements.secondaryScale.value = "10";
  elements.secondaryScaleReadout.textContent = "10";
  elements.difficulty.value = String(baseline.difficulty);
  elements.tempoProfile.value = baseline.tempoProfile;
  elements.monsterKind.value = baseline.monsterKind;
  elements.batchSize.value = "8";
  elements.spriteScale.value = String(baseline.sprite.scale);
  elements.spriteOffset.value = String(baseline.sprite.floorOffset);
  elements.idlePreset.value = baseline.sprite.idlePreset;
  elements.hitPreset.value = baseline.sprite.hitPreset;

  for (const input of [
    elements.archetypeA,
    elements.archetypeB,
    elements.secondaryScale,
    elements.difficulty,
    elements.tempoProfile,
    elements.monsterKind,
    elements.batchSize,
  ]) {
    input.addEventListener("change", stageGeneratorSettings);
  }
  elements.secondaryScale.addEventListener("input", () => {
    elements.secondaryScaleReadout.textContent = elements.secondaryScale.value;
    renderGeneratorMechanics();
  });
  elements.monsterName.addEventListener("input", applyNameOverride);
  elements.archetypeLibraryName.addEventListener("input", updateArchetypeLibraryName);
  elements.archetypeEditorSelect.addEventListener("change", () => loadArchetypeDraft(elements.archetypeEditorSelect.value));
  elements.customArchetypeName.addEventListener("input", updateActiveArchetypeDraft);
  elements.customHpBias.addEventListener("input", updateActiveArchetypeDraft);
  elements.archetypeTags.addEventListener("input", updateActiveArchetypeDraft);
  elements.archetypeUnlockDifficulty.addEventListener("change", updateActiveArchetypeDraft);
  elements.archetypeRouteWeight.addEventListener("input", updateActiveArchetypeDraft);
  for (const input of [elements.archetypeKindNormal, elements.archetypeKindElite, elements.archetypeKindBoss]) {
    input.addEventListener("change", updateActiveArchetypeDraft);
  }
  elements.newArchetypeButton.addEventListener("click", createNewArchetypeDraft);
  elements.saveArchetypeButton.addEventListener("click", saveActiveArchetypeDraft);
  elements.deleteArchetypeButton.addEventListener("click", deleteActiveArchetype);
  elements.exportArchetypesButton.addEventListener("click", () => {
    exportArchetypeCatalog();
  });
  elements.importArchetypesButton.addEventListener("click", () => elements.importArchetypesInput.click());
  elements.importArchetypesInput.addEventListener("change", importArchetypeCatalog);
  elements.generateButton.addEventListener("click", () => {
    state.seed += 1;
    generateCandidateBatch();
  });
  elements.generateBatchButton.addEventListener("click", () => {
    state.seed += 1;
    generateCandidateBatch();
  });
  elements.resetButton.addEventListener("click", resetLab);
  elements.lockMechanics.addEventListener("change", () => {
    state.lockedMechanicIds = elements.lockMechanics.checked
      ? state.monster?.mechanics.map((entry) => entry.id) ?? []
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
  const selectedEditor = elements.archetypeEditorSelect.value || state.activeArchetypeId;
  const editorOptions = state.archetypeCatalog.map((archetype) => ({
    id: archetype.id,
    name: archetype.name,
  }));
  const generatorOptions = getAvailableGeneratorArchetypes().map((archetype) => ({
    id: archetype.id,
    name: archetype.name,
  }));
  const optionHtml = editorOptions
    .map((option) => `<option value="${option.id}">${escapeHtml(option.name)}</option>`)
    .join("");
  const generatorOptionHtml = generatorOptions
    .map((option) => `<option value="${option.id}">${escapeHtml(option.name)}</option>`)
    .join("");
  elements.archetypeEditorSelect.innerHTML = optionHtml || '<option value="">No library loaded</option>';
  elements.archetypeA.innerHTML = generatorOptionHtml || '<option value="">No archetypes available</option>';
  elements.archetypeB.innerHTML = `<option value="">None</option>${generatorOptionHtml || optionHtml}`;
  const ids = new Set(editorOptions.map((option) => option.id));
  const generatorIds = new Set((generatorOptions.length ? generatorOptions : editorOptions).map((option) => option.id));
  if (ids.has(selectedEditor)) {
    elements.archetypeEditorSelect.value = selectedEditor;
  }
  if (generatorIds.has(selectedA)) {
    elements.archetypeA.value = selectedA;
  }
  if (generatorIds.has(selectedB)) {
    elements.archetypeB.value = selectedB;
  } else if (selectedB === "") {
    elements.archetypeB.value = "";
  }
  updateLibraryActionState();
}

function updateLibraryActionState() {
  const hasLibrary = state.archetypeCatalog.length > 0;
  const hasDraft = state.activeArchetypeDraft != null;
  const canGenerate = getArchetype(elements.archetypeA.value) != null;
  elements.archetypeEditorSelect.disabled = !hasLibrary;
  elements.saveArchetypeButton.disabled = !hasDraft;
  elements.deleteArchetypeButton.disabled = !hasDraft;
  elements.exportArchetypesButton.disabled = !hasLibrary;
  elements.generateButton.disabled = !canGenerate;
  elements.generateBatchButton.disabled = !canGenerate;
}

function getAvailableGeneratorArchetypes() {
  const difficultyId = normalizeDifficultyId(elements.difficulty.value || baseline.difficulty);
  const kind = elements.monsterKind.value === "bespoke" ? "normal" : elements.monsterKind.value || baseline.monsterKind;
  return state.archetypeCatalog.filter((archetype) => {
    const unlockDifficulty = normalizeDifficultyId(archetype.unlockDifficulty);
    const allowedKinds = normalizeAllowedKinds(archetype.allowedKinds);
    return unlockDifficulty <= difficultyId && allowedKinds.includes(kind);
  });
}

function loadArchetypeDraft(archetypeId) {
  const archetype = getArchetype(archetypeId);
  if (!archetype) {
    state.activeArchetypeId = "";
    state.activeArchetypeDraft = null;
    elements.archetypeSaveState.textContent = "Import or create";
    renderArchetypeEditor();
    updateLibraryActionState();
    return;
  }
  state.activeArchetypeId = archetype.id;
  state.activeArchetypeDraft = cloneArchetype(archetype);
  state.pendingDeleteArchetypeId = "";
  updateDeleteButtonState();
  elements.archetypeSaveState.textContent = "Loaded";
  refreshArchetypeSelects();
  renderArchetypeEditor();
}

function updateActiveArchetypeDraft() {
  const draft = state.activeArchetypeDraft;
  if (!draft) {
    return;
  }
  state.pendingDeleteArchetypeId = "";
  updateDeleteButtonState();
  draft.name = elements.customArchetypeName.value.trim() || "Unnamed Archetype";
  draft.baseHpBias = clampNumber(elements.customHpBias.value, 70, 150, 100) / 100;
  draft.tags = normalizeTags(elements.archetypeTags.value);
  draft.unlockDifficulty = normalizeDifficultyId(elements.archetypeUnlockDifficulty.value);
  draft.routeWeight = clampNumber(elements.archetypeRouteWeight.value, 0, 200, 80);
  draft.allowedKinds = selectedAllowedKinds();
  draft.nameParts.prefixes = [draft.name.split(/\s+/)[0] || "Named"];
  elements.archetypeSaveState.textContent = "Unsaved";
}

function updateArchetypeLibraryName() {
  state.archetypeLibraryName = elements.archetypeLibraryName.value.trim() || baseline.archetypeLibraryName;
  saveArchetypeCatalog();
  elements.archetypeSaveState.textContent = "Library named";
}

function renderArchetypeEditor() {
  const custom = state.activeArchetypeDraft;
  if (!custom) {
    elements.customArchetypeName.value = "";
    elements.customHpBias.value = "100";
    elements.archetypeTags.value = "";
    elements.archetypeUnlockDifficulty.value = String(baseline.difficulty);
    elements.archetypeRouteWeight.value = "80";
    elements.archetypeKindNormal.checked = true;
    elements.archetypeKindElite.checked = true;
    elements.archetypeKindBoss.checked = true;
    elements.customMechanics.innerHTML = '<p class="empty-note">Import a monster library or create a new archetype to begin.</p>';
    updateLibraryActionState();
    return;
  }
  elements.customArchetypeName.value = custom.name;
  elements.customHpBias.value = String(Math.round(custom.baseHpBias * 100));
  elements.archetypeTags.value = normalizeTags(custom.tags).join(", ");
  elements.archetypeUnlockDifficulty.value = String(normalizeDifficultyId(custom.unlockDifficulty));
  elements.archetypeRouteWeight.value = String(clampNumber(custom.routeWeight, 0, 200, 80));
  const allowedKinds = normalizeAllowedKinds(custom.allowedKinds);
  elements.archetypeKindNormal.checked = allowedKinds.includes("normal");
  elements.archetypeKindElite.checked = allowedKinds.includes("elite");
  elements.archetypeKindBoss.checked = allowedKinds.includes("boss");
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
      <label class="required-row">
        <input type="checkbox" data-field="required" ${config.required ? "checked" : ""}>
        <span>Required</span>
      </label>
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
      ${renderMechanicExtraFields(mechanic, config)}
    `;
    for (const input of card.querySelectorAll("input, select")) {
      input.addEventListener("input", () => updateDraftMechanic(mechanic.id, card));
      input.addEventListener("change", () => updateDraftMechanic(mechanic.id, card));
    }
    elements.customMechanics.append(card);
  }
}

function updateDraftMechanic(mechanicId, card) {
  const custom = state.activeArchetypeDraft;
  state.pendingDeleteArchetypeId = "";
  updateDeleteButtonState();
  const mechanic = getMechanic(mechanicId);
  const config = custom.mechanicConfigs[mechanicId];
  const enabled = card.querySelector("[data-field='enabled']").checked;
  const required = card.querySelector("[data-field='required']").checked;
  const weight = clampNumber(card.querySelector("[data-field='weight']").value, 0, 100, config.weight);
  const min = clampNumber(card.querySelector("[data-field='min']").value, mechanic.min, mechanic.max, config.min);
  const max = clampNumber(card.querySelector("[data-field='max']").value, mechanic.min, mechanic.max, config.max);
  config.enabled = enabled || required;
  config.required = required;
  config.weight = enabled ? Math.max(1, weight) : weight;
  config.min = Math.min(min, max);
  config.max = Math.max(min, max);
  config.scaling = card.querySelector("[data-field='scaling']").value;
  config.extras = readMechanicExtraFields(mechanic, card);
  if (enabled) {
    custom.mechanicWeights[mechanicId] = config.weight;
  } else {
    delete custom.mechanicWeights[mechanicId];
  }
  if (elements.lockMechanics.checked) {
    state.lockedMechanicIds = state.monster?.mechanics.map((entry) => entry.id) ?? [];
  }
  elements.archetypeSaveState.textContent = "Unsaved";
}

function createNewArchetypeDraft() {
  const nextNumber = state.archetypeCatalog.length + 1;
  state.pendingDeleteArchetypeId = "";
  updateDeleteButtonState();
  state.activeArchetypeDraft = createDefaultCustomArchetype(`new_archetype_${nextNumber}`, `New Archetype ${nextNumber}`, []);
  state.activeArchetypeId = state.activeArchetypeDraft.id;
  elements.archetypeSaveState.textContent = "New unsaved";
  renderArchetypeEditor();
}

function saveActiveArchetypeDraft() {
  if (!state.activeArchetypeDraft) {
    elements.archetypeSaveState.textContent = "Nothing to save";
    return;
  }
  const saved = normalizeArchetypeDraft(cloneArchetype(state.activeArchetypeDraft));
  state.pendingDeleteArchetypeId = "";
  updateDeleteButtonState();
  const existingIndex = state.archetypeCatalog.findIndex((archetype) => archetype.id === state.activeArchetypeId);
  const duplicateIndex = state.archetypeCatalog.findIndex((archetype) => archetype.id === saved.id);
  if (duplicateIndex >= 0 && duplicateIndex !== existingIndex) {
    saved.id = uniqueArchetypeId(saved.id);
  }
  if (existingIndex >= 0) {
    state.archetypeCatalog[existingIndex] = saved;
  } else {
    state.archetypeCatalog.push(saved);
  }
  state.activeArchetypeId = saved.id;
  state.activeArchetypeDraft = cloneArchetype(saved);
  saveArchetypeCatalog();
  refreshArchetypeSelects();
  elements.archetypeEditorSelect.value = saved.id;
  elements.archetypeA.value = saved.id;
  restoreSelectedArchetypes();
  elements.archetypeSaveState.textContent = "Saved";
  renderArchetypeEditor();
  stageGeneratorSettings();
}

function deleteActiveArchetype() {
  if (!state.activeArchetypeDraft) {
    elements.archetypeSaveState.textContent = "Nothing to delete";
    return;
  }
  if (state.archetypeCatalog.length <= 1) {
    state.pendingDeleteArchetypeId = "";
    updateDeleteButtonState();
    elements.archetypeSaveState.textContent = "Cannot delete last";
    return;
  }
  const deleteIndex = state.archetypeCatalog.findIndex((archetype) => archetype.id === state.activeArchetypeId);
  if (deleteIndex < 0) {
    createNewArchetypeDraft();
    return;
  }
  if (state.pendingDeleteArchetypeId !== state.activeArchetypeId) {
    state.pendingDeleteArchetypeId = state.activeArchetypeId;
    updateDeleteButtonState();
    elements.archetypeSaveState.textContent = "Click Delete again";
    return;
  }
  state.pendingDeleteArchetypeId = "";
  updateDeleteButtonState();
  state.archetypeCatalog.splice(deleteIndex, 1);
  saveArchetypeCatalog();
  const next = state.archetypeCatalog[Math.max(0, deleteIndex - 1)];
  state.activeArchetypeId = next.id;
  refreshArchetypeSelects();
  restoreSelectedArchetypes();
  loadArchetypeDraft(next.id);
  stageGeneratorSettings();
}

function updateDeleteButtonState() {
  if (!elements.deleteArchetypeButton) {
    return;
  }
  const pending = state.pendingDeleteArchetypeId === state.activeArchetypeId && state.pendingDeleteArchetypeId !== "";
  elements.deleteArchetypeButton.textContent = pending ? "Confirm Delete" : "Delete";
  elements.deleteArchetypeButton.classList.toggle("danger-action", pending);
}

function uniqueArchetypeId(baseId) {
  const ids = new Set(state.archetypeCatalog.map((archetype) => archetype.id));
  let index = 2;
  let candidate = `${baseId}_${index}`;
  while (ids.has(candidate)) {
    index += 1;
    candidate = `${baseId}_${index}`;
  }
  return candidate;
}

function restoreSelectedArchetypes() {
  if (!state.archetypeCatalog.length) {
    elements.archetypeA.value = "";
    elements.archetypeB.value = "";
    return;
  }
  const ids = new Set(state.archetypeCatalog.map((archetype) => archetype.id));
  if (!ids.has(elements.archetypeA.value)) {
    elements.archetypeA.value = state.archetypeCatalog[0].id;
  }
  if (!ids.has(elements.archetypeB.value)) {
    elements.archetypeB.value = "";
  }
}

function resetLab() {
  state.seed = baseline.seed;
  state.candidates = [];
  state.selectedCandidateIndex = 0;
  state.lockedMechanicIds = [];
  state.sprite = structuredClone(baseline.sprite);
  state.archetypeCatalog = [];
  state.archetypeLibraryName = baseline.archetypeLibraryName;
  clearSavedArchetypeCatalog();
  state.activeArchetypeId = "";
  state.activeArchetypeDraft = null;
  refreshArchetypeSelects();
  renderArchetypeEditor();
  elements.archetypeA.value = "";
  elements.archetypeB.value = "";
  elements.archetypeLibraryName.value = state.archetypeLibraryName;
  elements.difficulty.value = String(baseline.difficulty);
  elements.monsterKind.value = baseline.monsterKind;
  refreshTempoOptions();
  elements.tempoProfile.value = baseline.tempoProfile;
  elements.batchSize.value = "8";
  elements.secondaryScale.value = "10";
  elements.secondaryScaleReadout.textContent = "10";
  elements.lockMechanics.checked = false;
  elements.spriteInput.value = "";
  elements.spriteScale.value = String(baseline.sprite.scale);
  elements.spriteOffset.value = String(baseline.sprite.floorOffset);
  elements.idlePreset.value = baseline.sprite.idlePreset;
  elements.hitPreset.value = baseline.sprite.hitPreset;
  stageGeneratorSettings();
  renderEmptyMonsterState();
}

function stageGeneratorSettings() {
  refreshTempoOptions();
  refreshArchetypeSelects();
  restoreSelectedArchetypes();
  elements.secondaryScale.value = String(clampNumber(elements.secondaryScale.value, 1, 10, 10));
  elements.secondaryScaleReadout.textContent = elements.secondaryScale.value;
  renderGeneratorMechanics();
  updateLibraryActionState();
}

function generateCandidateBatch() {
  refreshArchetypeSelects();
  restoreSelectedArchetypes();
  if (!getArchetype(elements.archetypeA.value)) {
    state.candidates = [];
    state.monster = null;
    state.selectedCandidateIndex = 0;
    renderEmptyMonsterState();
    renderGeneratorMechanics();
    return;
  }
  const count = clampNumber(elements.batchSize.value, 3, 16, 8);
  elements.batchSize.value = String(count);
  elements.secondaryScale.value = String(clampNumber(elements.secondaryScale.value, 1, 10, 10));
  elements.secondaryScaleReadout.textContent = elements.secondaryScale.value;
  state.candidates = [];
  for (let index = 0; index < count; index += 1) {
    const candidate = createMonsterCandidate(state.seed + index, index);
    if (candidate) {
      state.candidates.push(candidate);
    }
  }
  selectCandidate(Math.min(state.selectedCandidateIndex, state.candidates.length - 1));
  renderGeneratorMechanics();
}

function createMonsterCandidate(seed, batchIndex) {
  const random = rngFrom(`${seed}|monster|${batchIndex}`);
  const archetypeA = getArchetype(elements.archetypeA.value);
  if (!archetypeA) {
    return null;
  }
  const archetypeB = getSecondaryArchetype();
  const band = getDifficultyBand(Number(elements.difficulty.value));
  const tempoProfile = getTempoProfile(elements.tempoProfile.value);
  const kind = elements.monsterKind.value;
  const kindMultiplier = getKindMultiplier(kind);
  const budget = Math.round(band.budget * kindMultiplier.budget);
  const mechanicsForMonster = selectMechanics(random, archetypeA, archetypeB, band, kind);
  const values = mechanicsForMonster.map((entry) => createMechanicValue(random, entry.mechanic, band, entry.config));
  const duration = calculateTempoDuration(random, kindMultiplier, tempoProfile);
  const targetDps = rollTargetDps(random, band, kindMultiplier);
  const hpBias = archetypeB == null ? archetypeA.baseHpBias : blendedSecondaryScaleValue(archetypeA.baseHpBias, archetypeB.baseHpBias);
  const mitigationMultiplier = calculateMitigationMultiplier(values);
  const hp = Math.max(1, Math.round((targetDps * duration * hpBias * kindMultiplier.hp) / mitigationMultiplier));
  const name = `Monster ${batchIndex + 1}`;

  const monster = {
    id: slugify(name),
    name,
    kind,
    seed,
    archetypes: [archetypeA.id, archetypeB?.id].filter(Boolean),
    archetypeNames: [archetypeA.name, archetypeB?.name].filter(Boolean),
    difficulty: band.id,
    difficultyName: band.name,
    tempo: tempoProfile.id,
    tempoName: tempoProfile.name,
    tempoDescription: tempoProfile.description,
    duration,
    targetDps,
    targetDpsRange: adjustedTargetDpsRange(band, kindMultiplier),
    dpsTolerance: band.dpsTolerance,
    hp,
    mechanics: values,
    budget,
    sprite: structuredClone(state.sprite),
  };
  finishMonsterModel(monster);
  return monster;
}

function selectCandidate(index) {
  state.selectedCandidateIndex = Math.max(0, Math.min(index, state.candidates.length - 1));
  state.monster = state.candidates[state.selectedCandidateIndex] ?? null;
  if (!state.monster) {
    renderEmptyMonsterState();
    return;
  }
  elements.monsterName.value = state.monster.name;
  render();
}

function getKindMultiplier(kind) {
  if (kind === "elite") {
    return { hp: 1.18, budget: 1.2, duration: 1.05, targetDps: 1.08, extraMechanics: 1 };
  }
  if (kind === "boss") {
    return { hp: 1.42, budget: 1.48, duration: 1.16, targetDps: 1.16, extraMechanics: 2 };
  }
  if (kind === "bespoke") {
    return { hp: 1, budget: 1, duration: 1, targetDps: 1, extraMechanics: 0 };
  }
  return { hp: 1, budget: 1, duration: 1, targetDps: 1, extraMechanics: 0 };
}

function getTempoProfile(id) {
  return tempoProfiles.find((profile) => profile.id === id) ?? tempoProfiles.find((profile) => profile.id === baseline.tempoProfile);
}

function calculateTempoDuration(random = Math.random, kindMultiplier, profile = getTempoProfile(elements.tempoProfile.value)) {
  const range = profile.durationRange ?? [18, 24];
  return Math.round(randomInt(random, range[0], range[1]) * kindMultiplier.duration);
}

function rollTargetDps(random, band, kindMultiplier) {
  const range = adjustedTargetDpsRange(band, kindMultiplier);
  return randomFloat(random, range[0], range[1]);
}

function adjustedTargetDpsRange(band, kindMultiplier) {
  const multiplier = kindMultiplier.targetDps ?? 1;
  return [
    Number((band.targetDpsRange[0] * multiplier).toFixed(2)),
    Number((band.targetDpsRange[1] * multiplier).toFixed(2)),
  ];
}

function tempoProfileLabel(profile, band = getDifficultyBand(Number(elements.difficulty?.value ?? baseline.difficulty))) {
  const kindMultiplier = getKindMultiplier(elements.monsterKind?.value ?? baseline.monsterKind);
  const range = profile.durationRange ?? [18, 24];
  const min = Math.round(range[0] * kindMultiplier.duration);
  const max = Math.round(range[1] * kindMultiplier.duration);
  return `${profile.name} (${min}-${max}s)`;
}

function refreshTempoOptions() {
  const selected = elements.tempoProfile.value || baseline.tempoProfile;
  const band = getDifficultyBand(Number(elements.difficulty.value));
  elements.tempoProfile.innerHTML = tempoProfiles
    .map((profile) => `<option value="${profile.id}">${escapeHtml(tempoProfileLabel(profile, band))}</option>`)
    .join("");
  elements.tempoProfile.value = tempoProfiles.some((profile) => profile.id === selected) ? selected : baseline.tempoProfile;
}

function getSecondaryScaleFactor() {
  return clampNumber(elements.secondaryScale.value, 1, 10, 10) / 10;
}

function combinedMechanicWeights(archetypeA, archetypeB) {
  if (!archetypeA) {
    return {};
  }
  const secondaryScale = getSecondaryScaleFactor();
  const weights = {};
  for (const [mechanicId, weight] of Object.entries(archetypeA.mechanicWeights)) {
    weights[mechanicId] = (weights[mechanicId] ?? 0) + Math.max(0, weight);
  }
  if (archetypeB != null) {
    for (const [mechanicId, weight] of Object.entries(archetypeB.mechanicWeights)) {
      weights[mechanicId] = (weights[mechanicId] ?? 0) + Math.max(0, weight) * secondaryScale;
    }
  }
  return weights;
}

function blendedSecondaryScaleValue(primaryValue, secondaryValue) {
  const secondaryScale = getSecondaryScaleFactor();
  return (primaryValue + secondaryValue * secondaryScale) / (1 + secondaryScale);
}

function rankedGeneratorMechanics() {
  const archetypeA = getArchetype(elements.archetypeA.value);
  if (!archetypeA) {
    return [];
  }
  const archetypeB = getSecondaryArchetype();
  const secondaryScale = getSecondaryScaleFactor();
  const combined = combinedMechanicWeights(archetypeA, archetypeB);
  return Object.entries(combined)
    .map(([mechanicId, totalWeight]) => {
      const mechanic = getMechanic(mechanicId);
      const aWeight = Math.max(0, archetypeA.mechanicWeights[mechanicId] ?? 0);
      const bBaseWeight = Math.max(0, archetypeB?.mechanicWeights[mechanicId] ?? 0);
      const bScaledWeight = bBaseWeight * secondaryScale;
      const requiredByA = archetypeA.mechanicConfigs?.[mechanicId]?.required === true;
      const requiredByB = archetypeB?.mechanicConfigs?.[mechanicId]?.required === true;
      return {
        id: mechanicId,
        name: mechanic?.name ?? mechanicId,
        totalWeight,
        aWeight,
        bScaledWeight,
        bBaseWeight,
        requiredByA,
        requiredByB,
      };
    })
    .filter((entry) => entry.totalWeight > 0)
    .sort((a, b) => b.totalWeight - a.totalWeight || a.name.localeCompare(b.name));
}

function renderGeneratorMechanics() {
  if (!elements.generatorMechanics) {
    return;
  }
  const ranked = rankedGeneratorMechanics();
  const total = ranked.reduce((sum, entry) => sum + entry.totalWeight, 0);
  if (!ranked.length) {
    elements.generatorMechanics.innerHTML = '<p class="empty-note">No mechanics available from this archetype pair.</p>';
    return;
  }
  elements.generatorMechanics.innerHTML = ranked
    .map((entry) => {
      const pct = total > 0 ? (entry.totalWeight / total) * 100 : 0;
      const bText = getSecondaryArchetype() == null ? "B None" : (entry.bBaseWeight > 0 ? `B ${formatWeight(entry.bScaledWeight)} (${formatWeight(entry.bBaseWeight)} base)` : "B -");
      const requiredText = [entry.requiredByA ? "A" : "", entry.requiredByB ? "B" : ""].filter(Boolean).join("+");
      return `
        <article class="generator-mechanic-row${requiredText ? " required-generator-mechanic" : ""}">
          <div>
            <strong>${escapeHtml(entry.name)}${requiredText ? ` <small>REQ ${escapeHtml(requiredText)}</small>` : ""}</strong>
            <span>A ${formatWeight(entry.aWeight)} | ${escapeHtml(bText)}</span>
          </div>
          <b>${formatWeight(entry.totalWeight)}</b>
          <em style="--weight-width: ${pct.toFixed(1)}%"></em>
        </article>
      `;
    })
    .join("");
}

function selectMechanics(random, archetypeA, archetypeB, band, kind) {
  if (elements.lockMechanics.checked && state.lockedMechanicIds.length) {
    return state.lockedMechanicIds
      .map((mechanicId) => ({
        mechanic: getMechanic(mechanicId),
        config: getMergedMechanicConfig(mechanicId, activeArchetypePair(archetypeA, archetypeB)),
      }))
      .filter((entry) => entry.mechanic);
  }
  const kindMultiplier = getKindMultiplier(kind);
  const mergedWeights = combinedMechanicWeights(archetypeA, archetypeB);
  const count = Math.min(
    mechanics.length,
    randomInt(random, band.mechanicCount[0], band.mechanicCount[1]) + kindMultiplier.extraMechanics,
  );

  const selected = [];
  const requiredIds = requiredMechanicIds(archetypeA, archetypeB);
  for (const mechanicId of requiredIds) {
    const mechanic = getMechanic(mechanicId);
    if (!mechanic) {
      continue;
    }
    selected.push({
      mechanic,
      config: getMergedMechanicConfig(mechanicId, activeArchetypePair(archetypeA, archetypeB)),
    });
  }
  const remaining = mechanics.filter((mechanic) => mergedWeights[mechanic.id] && !requiredIds.has(mechanic.id));
  while (selected.length < count && remaining.length) {
    const candidate = pickWeighted(
      remaining.map((mechanic) => ({ value: mechanic, weight: mergedWeights[mechanic.id] })),
      random,
    );
    selected.push({
      mechanic: candidate,
      config: getMergedMechanicConfig(candidate.id, activeArchetypePair(archetypeA, archetypeB)),
    });
    remaining.splice(remaining.indexOf(candidate), 1);
  }
  return selected;
}

function requiredMechanicIds(archetypeA, archetypeB) {
  const ids = new Set();
  for (const archetype of activeArchetypePair(archetypeA, archetypeB)) {
    for (const [mechanicId, config] of Object.entries(archetype.mechanicConfigs ?? {})) {
      if (config.required) {
        ids.add(mechanicId);
      }
    }
  }
  return ids;
}

function activeArchetypePair(archetypeA, archetypeB) {
  return [archetypeA, archetypeB].filter((archetype) => archetype != null);
}

function getMergedMechanicConfig(mechanicId, selectedArchetypes) {
  const secondaryScale = getSecondaryScaleFactor();
  const configs = selectedArchetypes
    .map((archetype, index) => ({
      config: archetype.mechanicConfigs?.[mechanicId],
      weight: index === 0 ? 1 : secondaryScale,
      source: index === 0 ? "A" : "B",
    }))
    .filter((entry) => entry.config?.enabled);
  if (!configs.length) {
    return null;
  }
  const totalWeight = configs.reduce((sum, entry) => sum + entry.weight, 0);
  return {
    min: Math.round(configs.reduce((sum, entry) => sum + entry.config.min * entry.weight, 0) / totalWeight),
    max: Math.round(configs.reduce((sum, entry) => sum + entry.config.max * entry.weight, 0) / totalWeight),
    scaling: configs[0].config.scaling,
    extras: mergeMechanicExtras(mechanicId, configs),
    required: configs.some((entry) => entry.config.required),
    requiredBy: configs
      .map((entry) => entry.config.required ? entry.source : "")
      .filter(Boolean),
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
    extras: normalizeMechanicExtras(mechanic, config?.extras),
    required: config?.required === true,
    requiredBy: config?.requiredBy ?? [],
    cost: scoreMechanicCost(mechanic, value),
  };
}

function getScaledCustomRange(config, mechanic, difficultyId) {
  const profile = scalingProfiles[config.scaling] ?? scalingProfiles.standard;
  const baseLow = clampNumber(config.min, mechanic.min, mechanic.max, mechanic.min);
  const baseHigh = clampNumber(config.max, mechanic.min, mechanic.max, mechanic.max);
  const multiplier = getScalingMultiplier(profile, difficultyId);
  if (mechanic.invertCost) {
    const low = Math.max(mechanic.min, Math.round(baseLow / multiplier));
    const high = Math.max(mechanic.min, Math.round(baseHigh / multiplier));
    return [Math.min(low, high), Math.max(low, high)];
  }
  const low = Math.round(baseLow * multiplier);
  const high = Math.round(baseHigh * multiplier);
  return [
    Math.min(low, high),
    Math.max(low, high),
  ];
}

function getScalingMultiplier(profile, difficultyId) {
  const difficultyProgress = (difficultyId - 1) / Math.max(1, difficultyBands.length - 1);
  return 1 + profile.growth * Math.pow(difficultyProgress, profile.exponent);
}

function finishMonsterModel(monster = state.monster) {
  if (!monster) {
    return;
  }
  const mechanicCost = monster.mechanics.reduce((sum, entry) => sum + entry.cost, 0);
  const hpCost = Math.round(monster.hp / 8);
  const synergyCost = calculateSynergyCost(monster.mechanics);
  const totalCost = hpCost + mechanicCost + synergyCost;
  const majorDefenseCount = countMajorDefenses(monster);
  const mitigationMultiplier = calculateMitigationMultiplier(monster.mechanics);
  const effectiveHp = Math.round(monster.hp * mitigationMultiplier);
  const requiredDps = effectiveHp / monster.duration;
  const pressure = calculatePressure(monster, requiredDps);
  const pressureStatus = calculatePressureStatus(monster, requiredDps);
  const warnings = createWarnings(monster, totalCost, pressure, pressureStatus, majorDefenseCount);
  const matchupPreview = createMatchupPreview(monster, pressure, pressureStatus);

  monster.model = {
    hpCost,
    mechanicCost,
    synergyCost,
    majorDefenseCount,
    totalCost,
    budgetDelta: totalCost - monster.budget,
    effectiveHp,
    requiredDps,
    pressureStatus,
    targetDpsDelta: requiredDps - monster.targetDps,
    pressure,
    matchupPreview,
    warnings,
  };
}

function createMatchupPreview(monster, pressure, pressureStatus) {
  const rankedMechanics = [...monster.mechanics].sort((a, b) => b.cost - a.cost);
  const primaryMechanics = rankedMechanics.slice(0, 2);
  const archetypeDefinitions = monster.archetypes.map(getArchetype).filter(Boolean);
  const archetypeNames = monster.archetypeNames.length ? monster.archetypeNames : ["Custom"];
  const topMechanicNames = primaryMechanics.map((entry) => getMechanic(entry.id)?.name ?? entry.name);
  const topMechanicLabel = topMechanicNames.length ? formatList(topMechanicNames) : "no selected defenses";
  const identityParts = uniqueNonEmpty([
    ...archetypeDefinitions.map((archetype) => archetype.tone),
    ...primaryMechanics.map((entry) => getMechanic(entry.id)?.matchup?.identity),
  ]).slice(0, 3);
  const pressures = uniqueNonEmpty(rankedMechanics.map((entry) => getMechanic(entry.id)?.matchup?.pressure)).slice(0, 4);
  const counterplay = uniqueNonEmpty(rankedMechanics.map((entry) => getMechanic(entry.id)?.matchup?.counterplay)).slice(0, 4);
  const routeHints = uniqueNonEmpty(rankedMechanics.map((entry) => getMechanic(entry.id)?.matchup?.route)).slice(0, 3);
  const tags = uniqueNonEmpty([
    ...archetypeDefinitions.flatMap((archetype) => normalizeTags(archetype.tags ?? [])),
    ...rankedMechanics.flatMap((entry) => entry.tags ?? []),
  ]).slice(0, 10);
  const primaryPressure = strongestPressureLabel(pressure);
  const routeIntro = pressureStatus.id === "in_band"
    ? `${monster.difficultyName} ${titleCase(monster.kind)} in the prototype target window`
    : `${monster.difficultyName} ${titleCase(monster.kind)} marked ${pressureStatus.label.toLowerCase()}`;

  return {
    identity: `${formatList(archetypeNames)} profile centered on ${topMechanicLabel}${identityParts.length ? `: ${identityParts.join("; ")}` : "."}`,
    pressures: pressures.length ? pressures : ["does not yet pressure a specific build style beyond its HP and timer"],
    counterplay: counterplay.length ? counterplay : ["any complete build should be able to test this draft"],
    route_preview: `${routeIntro}; route preview should flag ${primaryPressure} pressure and ${routeHints.join(", ") || "a general combat check"}.`,
    tags,
    primary_mechanics: primaryMechanics.map((entry) => entry.id),
  };
}

function strongestPressureLabel(pressure) {
  const [id] = Object.entries(pressure)
    .sort((a, b) => b[1] - a[1])[0] ?? ["general"];
  if (id === "poison") {
    return "poison-build";
  }
  if (id === "burst") {
    return "burst-build";
  }
  if (id === "sustained") {
    return "sustained-DPS";
  }
  return "general";
}

function countMajorDefenses(monster) {
  const band = getDifficultyBand(monster.difficulty);
  return monster.mechanics.filter((entry) => entry.cost >= band.majorDefenseCost).length;
}

function calculateMitigationMultiplier(selectedMechanics) {
  return selectedMechanics.reduce((multiplier, entry) => {
    const mechanic = getMechanic(entry.id);
    return multiplier + mechanic.effectiveHpPerValue * entry.value;
  }, 1);
}

function calculateSynergyCost(selectedMechanics) {
  const ids = new Set(selectedMechanics.map((entry) => entry.id));
  let cost = 0;
  if (ids.has("armor") && ids.has("block")) {
    cost += 10;
  }
  if (ids.has("armor") && ids.has("poison_resistance")) {
    cost += 12;
  }
  if (ids.has("poison_resistance") && ids.has("cleanse_threshold")) {
    cost += 16;
  }
  if (ids.has("absorb") && ids.has("suppress")) {
    cost += 10;
  }
  if (ids.has("dodge_chance") && ids.has("block")) {
    cost += 12;
  }
  if (ids.has("slow") && ids.has("stun_duration_ms")) {
    cost += 10;
  }
  return cost;
}

function calculatePressure(monster, requiredDps) {
  const baseRatio = requiredDps / monster.targetDps;
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

function calculatePressureStatus(monster, requiredDps) {
  const tolerance = monster.dpsTolerance ?? getDifficultyBand(monster.difficulty).dpsTolerance ?? 0.15;
  const low = monster.targetDps * (1 - tolerance);
  const high = monster.targetDps * (1 + tolerance);
  const ratio = requiredDps / Math.max(0.1, monster.targetDps);
  if (requiredDps < low) {
    return {
      id: ratio < 1 - tolerance * 2 ? "under_band" : "slightly_under",
      label: ratio < 1 - tolerance * 2 ? "Under Band" : "Slightly Under",
      ratio,
      low,
      high,
    };
  }
  if (requiredDps > high) {
    return {
      id: ratio > 1 + tolerance * 2 ? "over_band" : "slightly_over",
      label: ratio > 1 + tolerance * 2 ? "Over Band" : "Slightly Over",
      ratio,
      low,
      high,
    };
  }
  return {
    id: "in_band",
    label: "In Band",
    ratio,
    low,
    high,
  };
}

function clampPressure(value) {
  return Math.max(0.2, Math.min(2.4, value));
}

function createWarnings(monster, totalCost, pressure, pressureStatus, majorDefenseCount) {
  const warnings = [];
  const ids = new Set(monster.mechanics.map((entry) => entry.id));
  const exportableMechanics = monster.mechanics.filter((entry) => {
    const mechanic = getMechanic(entry.id);
    return mechanic && canonicalGodotFields.has(mechanic.godotField);
  });
  if (!monster.archetypes.length) {
    warnings.push(createNotice("Export", "Missing Archetype", "This draft has no archetype metadata attached for later runtime generation."));
  }
  if (!monster.mechanics.length) {
    warnings.push(createNotice("Export", "No Defenses", "This draft has no selected defense fields. It can still export, but it will not test defensive identity."));
  }
  if (exportableMechanics.length !== monster.mechanics.length) {
    warnings.push(createNotice("Export", "Export Field Gap", "One or more selected mechanics do not map cleanly to the Godot Monster resource."));
  }
  if (totalCost > monster.budget * 1.12) {
    warnings.push(createNotice("Budget", "Over Budget", "This draft exceeds the selected band's prototype budget. Treat this as a review prompt, not a balance failure."));
  }
  if (majorDefenseCount > getDifficultyBand(monster.difficulty).maxMajorDefenses) {
    warnings.push(createNotice("Readability", "Many Major Defenses", "This draft exceeds the selected band's major-defense count and may be harder to read at a glance."));
  }
  if (pressureStatus.id === "over_band" || pressureStatus.id === "slightly_over") {
    warnings.push(createNotice("Pressure", "Required DPS High", `Required DPS is above the ${monster.difficultyName} prototype target window after HP and defenses are combined.`));
  }
  if (pressureStatus.id === "under_band" || pressureStatus.id === "slightly_under") {
    warnings.push(createNotice("Pressure", "Required DPS Low", "Required DPS is below the prototype target window after duration, HP, and defenses are combined."));
  }
  if (ids.has("stun_duration_ms") || ids.has("interrupt_skip_count")) {
    warnings.push(createNotice("Runtime", "Timing Preview Only", "Stun and interrupt export as Monster fields, but their runtime behavior is deferred until a dedicated timing-disruption pass."));
  }
  if (monster.mechanics.length >= 4 && monster.kind === "normal") {
    warnings.push(createNotice("Readability", "Busy Normal Monster", "Four or more mechanics on a normal enemy may be harder to read in route previews."));
  }
  return warnings;
}

function createNotice(category, title, body, severity = "notice") {
  return {
    category,
    severity,
    title,
    body,
  };
}

function scoreMechanicCost(mechanic, value) {
  if (mechanic.invertCost) {
    return Math.round(mechanic.baseCost + (mechanic.max - value + 1) * mechanic.costPerValue);
  }
  return Math.round(mechanic.baseCost + value * mechanic.costPerValue);
}

function createMonsterName(random, archetypeA, archetypeB) {
  const prefixPool = [...archetypeA.nameParts.prefixes, ...(archetypeB?.nameParts.prefixes ?? [])];
  const nounPool = [...archetypeA.nameParts.nouns, ...(archetypeB?.nameParts.nouns ?? [])];
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
  if (state.candidates[state.selectedCandidateIndex] === state.monster) {
    state.candidates[state.selectedCandidateIndex] = state.monster;
  }
  render(false);
}

function render(rebuildControls = true) {
  if (!state.monster) {
    renderEmptyMonsterState();
    return;
  }
  const monster = state.monster;
  elements.seedReadout.textContent = `Seed ${state.seed}`;
  elements.monsterTitle.textContent = monster.name;
  elements.monsterNote.textContent = `${monster.archetypeNames.join(" + ")} - ${monster.difficultyName} - ${monster.tempoName} ${monster.duration}s - ${titleCase(monster.kind)}`;
  elements.difficultyScore.textContent = `Score ${monster.model.totalCost}`;
  elements.hpReadout.textContent = formatNumber(monster.hp);
  elements.ehpReadout.textContent = formatNumber(monster.model.effectiveHp);
  elements.durationReadout.textContent = `${monster.duration}s`;
  elements.targetDpsReadout.textContent = `${monster.targetDpsRange[0].toFixed(0)}-${monster.targetDpsRange[1].toFixed(0)}`;
  elements.dpsReadout.textContent = monster.model.requiredDps.toFixed(1);
  elements.budgetReadout.textContent = `${monster.model.totalCost} / ${monster.budget}`;
  elements.mechanicsCount.textContent = `${monster.mechanics.length} selected`;
  elements.warningCount.textContent = `${monster.model.warnings.length} notices`;
  elements.candidateCount.textContent = `${state.candidates.length} monsters`;

  if (rebuildControls) {
    renderStatControls();
  }
  renderCandidates();
  renderMechanics();
  renderMatchupPreview();
  renderBudget();
  renderPressure();
  renderWarnings();
  renderSprite();
  renderExport();
}

function renderEmptyMonsterState() {
  elements.seedReadout.textContent = `Seed ${state.seed}`;
  elements.monsterTitle.textContent = "No Monster Generated";
  elements.monsterNote.textContent = "Import a monster library or create an archetype, then generate a batch.";
  elements.difficultyScore.textContent = "Score 0";
  elements.hpReadout.textContent = "0";
  elements.ehpReadout.textContent = "0";
  elements.durationReadout.textContent = "0s";
  elements.targetDpsReadout.textContent = "0-0";
  elements.dpsReadout.textContent = "0";
  elements.budgetReadout.textContent = "0 / 0";
  elements.mechanicsCount.textContent = "0 selected";
  elements.warningCount.textContent = "0 notices";
  elements.candidateCount.textContent = "0 monsters";
  elements.monsterName.value = "";
  elements.statControls.innerHTML = "";
  elements.mechanicsGrid.innerHTML = "";
  elements.matchupPreview.innerHTML = '<p class="empty-note">No matchup preview available.</p>';
  elements.budgetBars.innerHTML = "";
  elements.pressureGrid.innerHTML = "";
  elements.warnings.innerHTML = '<p class="empty-note">No monster selected.</p>';
  elements.candidateSummary.innerHTML = '<p class="empty-note">No candidates generated.</p>';
  elements.candidateList.innerHTML = "";
  elements.exportJson.value = "";
}

function renderStatControls() {
  elements.statControls.innerHTML = "";
  elements.statControls.append(createNumberSlider("HP", state.monster.hp, 40, Math.max(1400, state.monster.hp), 5, (value) => {
    state.monster.hp = value;
    finishMonsterModel();
    syncSelectedCandidate();
    render(false);
  }));

  for (const entry of state.monster.mechanics) {
    const mechanic = getMechanic(entry.id);
    elements.statControls.append(
      createNumberSlider(mechanic.shortName, entry.value, Math.min(mechanic.min, entry.range[0]), Math.max(mechanic.max, entry.range[1], entry.value), 1, (value) => {
        entry.value = value;
        entry.cost = scoreMechanicCost(mechanic, value);
        finishMonsterModel();
        syncSelectedCandidate();
        render(false);
      }, (value) => formatMechanicValue({ value, valueLabel: mechanic.valueLabel })),
    );
  }
}

function syncSelectedCandidate() {
  if (state.monster && state.candidates[state.selectedCandidateIndex] === state.monster) {
    state.candidates[state.selectedCandidateIndex] = state.monster;
  }
}

function renderCandidates() {
  if (!elements.candidateList) {
    return;
  }
  if (!state.candidates.length) {
    elements.candidateSummary.innerHTML = '<p class="empty-note">No candidates generated.</p>';
    elements.candidateList.innerHTML = "";
    return;
  }
  const dps = state.candidates.map((candidate) => candidate.model.requiredDps);
  const inBandCount = state.candidates.filter((candidate) => candidate.model.pressureStatus.id === "in_band").length;
  elements.candidateSummary.innerHTML = `
    <article><span>Generated</span><strong>${state.candidates.length}</strong></article>
    <article><span>In Band</span><strong>${inBandCount}/${state.candidates.length}</strong></article>
    <article><span>Avg DPS</span><strong>${average(dps).toFixed(1)}</strong></article>
  `;
  elements.candidateList.innerHTML = "";
  state.candidates.forEach((candidate, index) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = `candidate-card${index === state.selectedCandidateIndex ? " selected-candidate" : ""}`;
    button.innerHTML = `
      <span class="candidate-name">${escapeHtml(candidate.name)}</span>
      <span>${escapeHtml(candidate.archetypeNames.join(" + "))}</span>
      <span class="candidate-stat-grid">${renderCandidateStatChips(candidate)}</span>
      <span class="candidate-card-footer">${escapeHtml(candidate.tempoName)} ${candidate.duration}s - DPS ${candidate.model.requiredDps.toFixed(1)} - ${escapeHtml(candidate.model.pressureStatus.label)}</span>
    `;
    button.addEventListener("click", () => selectCandidate(index));
    elements.candidateList.append(button);
  });
}

function renderCandidateStatChips(candidate) {
  const stats = [
    ["HP", formatNumber(candidate.hp)],
    ...candidate.mechanics.map((entry) => [entry.shortName, formatMechanicValue(entry)]),
  ];
  return stats
    .map(([label, value]) => `
      <span class="candidate-stat-chip">
        <b>${escapeHtml(label)}</b>
        <em>${escapeHtml(value)}</em>
      </span>
    `)
    .join("");
}

function createNumberSlider(label, value, min, max, step, onChange, formatValue = String) {
  const row = document.createElement("label");
  row.className = "slider-row";
  row.innerHTML = `
    <span class="slider-label"><strong>${escapeHtml(label)}</strong><span>${escapeHtml(formatValue(value))}</span></span>
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
    labelValue.textContent = formatValue(next);
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
        <strong>${escapeHtml(formatMechanicValue(entry))}</strong>
      </div>
      <p>${escapeHtml(entry.description)}</p>
      <div class="tag-row">${entry.tags.map((tag) => `<span class="tag">${escapeHtml(tag)}</span>`).join("")}</div>
      <div class="mechanic-meta"><span>Range ${entry.range[0]}-${entry.range[1]} / ${entry.scaling}</span><strong>Cost ${entry.cost}</strong></div>
      ${renderMechanicExtrasSummary(entry)}
    `;
    elements.mechanicsGrid.append(card);
  }
}

function renderBudget() {
  const rows = [
    ["HP", state.monster.model.hpCost, "#77d9d0"],
    ["Mechanics", state.monster.model.mechanicCost, "#f0c36b"],
    ["Synergy", state.monster.model.synergyCost, "#b86a9c"],
    ["Major Defenses", state.monster.model.majorDefenseCount, "#d27f65", getDifficultyBand(state.monster.difficulty).maxMajorDefenses],
  ];
  elements.budgetBars.innerHTML = rows
    .map(([label, value, color, cap]) => {
      const denominator = cap ?? state.monster.budget;
      const width = Math.min(100, (value / Math.max(1, denominator)) * 100);
      const readout = cap == null ? value : `${value} / ${cap}`;
      return `
        <div class="bar-row">
          <div class="bar-label"><span>${label}</span><span>${readout}</span></div>
          <div class="bar-track"><div class="bar-fill" style="width: ${width}%; background: ${color};"></div></div>
        </div>
      `;
    })
    .join("");
}

function renderPressure() {
  const pressure = state.monster.model.pressure;
  elements.pressureGrid.innerHTML = [
    bandFitCard(state.monster.model.pressureStatus),
    pressureCard("Poison Builds", pressure.poison),
    pressureCard("Burst Builds", pressure.burst),
    pressureCard("Sustained DPS", pressure.sustained),
  ].join("");
}

function bandFitCard(status) {
  const className = status.id === "in_band" ? "pressure-mid" : status.id.includes("slightly") ? "pressure-low" : "pressure-high";
  return `
    <article class="pressure-card ${className}">
      <span>Band Fit</span>
      <strong>${escapeHtml(status.label)} ${status.ratio.toFixed(2)}x</strong>
    </article>
  `;
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
    elements.warnings.innerHTML = '<p class="empty-note">No structural notices for this candidate.</p>';
    return;
  }
  elements.warnings.innerHTML = state.monster.model.warnings
    .map(
      (warning) => `
        <article class="warning-card">
          <span>${escapeHtml(warning.category)} - ${escapeHtml(warning.title)}</span>
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
  if (!state.monster) {
    elements.exportJson.value = "";
    return;
  }
  const godotOverrides = buildGodotMonsterOverrides(state.monster);
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
      tempo: state.monster.tempo,
      tempo_name: state.monster.tempoName,
      generator: {
        secondary_scale: clampNumber(elements.secondaryScale.value, 1, 10, 10),
        secondary_weight_multiplier: Number(getSecondaryScaleFactor().toFixed(2)),
        tempo_profile: state.monster.tempo,
        tempo_name: state.monster.tempoName,
        tempo_description: state.monster.tempoDescription,
        target_dps: Number(state.monster.targetDps.toFixed(2)),
        target_dps_range: state.monster.targetDpsRange,
      },
      hp: state.monster.hp,
      duration: state.monster.duration,
      matchup_preview: state.monster.model.matchupPreview,
      target_dps: Number(state.monster.targetDps.toFixed(2)),
      target_dps_range: state.monster.targetDpsRange,
      dps_tolerance: state.monster.dpsTolerance,
      mechanics: state.monster.mechanics.map((entry) => ({
        id: entry.id,
        godot_field: getMechanic(entry.id).godotField,
        value: entry.value,
        godot_value: godotExportValue(entry),
        range: entry.range,
        scaling: entry.scaling,
        value_label: entry.valueLabel,
        extras: entry.extras,
        tags: entry.tags,
        required: entry.required === true,
        required_by: entry.requiredBy,
        preview_only: getMechanic(entry.id).previewOnly === true,
      })),
      godot: {
        resource_class: "Monster",
        hp: state.monster.hp,
        duration_ms: state.monster.duration * 1000,
        monster_overrides: godotOverrides,
      },
      archetype_definitions: state.monster.archetypes
        .map(getArchetype)
        .map((archetype) => ({
          id: archetype.id,
          name: archetype.name,
          tags: normalizeTags(archetype.tags),
          unlock_difficulty: normalizeDifficultyId(archetype.unlockDifficulty),
          allowed_kinds: normalizeAllowedKinds(archetype.allowedKinds),
          route_weight: clampNumber(archetype.routeWeight, 0, 200, 80),
          base_hp_bias: archetype.baseHpBias,
          mechanics: Object.entries(archetype.mechanicConfigs)
            .filter(([, config]) => config.enabled)
            .map(([mechanicId, config]) => ({
              id: mechanicId,
              weight: config.weight,
              required: config.required === true,
              min: config.min,
              max: config.max,
              scaling: config.scaling,
              extras: config.extras,
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
        max_major_defenses: getDifficultyBand(state.monster.difficulty).maxMajorDefenses,
        major_defense_cost: getDifficultyBand(state.monster.difficulty).majorDefenseCost,
        major_defense_count: state.monster.model.majorDefenseCount,
        total_cost: state.monster.model.totalCost,
        budget_delta: state.monster.model.budgetDelta,
        effective_hp: state.monster.model.effectiveHp,
        required_dps: Number(state.monster.model.requiredDps.toFixed(2)),
        target_dps: Number(state.monster.targetDps.toFixed(2)),
        target_dps_delta: Number(state.monster.model.targetDpsDelta.toFixed(2)),
        pressure_status: state.monster.model.pressureStatus.id,
        pressure_status_label: state.monster.model.pressureStatus.label,
        pressure_window: {
          low: Number(state.monster.model.pressureStatus.low.toFixed(2)),
          high: Number(state.monster.model.pressureStatus.high.toFixed(2)),
        },
        pressure: {
          poison: Number(state.monster.model.pressure.poison.toFixed(2)),
          burst: Number(state.monster.model.pressure.burst.toFixed(2)),
          sustained: Number(state.monster.model.pressure.sustained.toFixed(2)),
        },
        warnings: state.monster.model.warnings.map((warning) => ({
          category: warning.category,
          severity: warning.severity,
          title: warning.title,
        })),
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

async function exportArchetypeCatalog() {
  state.archetypeLibraryName = elements.archetypeLibraryName.value.trim() || baseline.archetypeLibraryName;
  const fileName = `${slugify(state.archetypeLibraryName) || "dawnbringer_monster_archetypes"}.json`;
  const payload = {
    project: "DawnBringer",
    tool: "Monster Lab",
    schema: "monster_lab_archetype_catalog.v1",
    library_name: state.archetypeLibraryName,
    exported_at: new Date().toISOString(),
    archetypes: state.archetypeCatalog.map(serializeArchetypeForExport),
  };
  saveArchetypeCatalog();
  const saved = await saveTextFile(fileName, JSON.stringify(payload, null, 2), "application/json");
  if (saved) {
    elements.archetypeSaveState.textContent = "Exported";
  }
}

function renderMatchupPreview() {
  const preview = state.monster.model.matchupPreview;
  elements.matchupPreview.innerHTML = `
    <article class="matchup-identity">
      <span>Identity</span>
      <strong>${escapeHtml(preview.identity)}</strong>
    </article>
    <div class="matchup-columns">
      ${matchupList("Pressures", preview.pressures)}
      ${matchupList("Counterplay", preview.counterplay)}
    </div>
    <article class="matchup-route">
      <span>Route Implication</span>
      <p>${escapeHtml(preview.route_preview)}</p>
    </article>
    <div class="tag-row">${preview.tags.map((tag) => `<span class="tag">${escapeHtml(tag)}</span>`).join("")}</div>
  `;
}

function matchupList(label, entries) {
  return `
    <article class="matchup-list">
      <span>${escapeHtml(label)}</span>
      <ul>
        ${entries.map((entry) => `<li>${escapeHtml(entry)}</li>`).join("")}
      </ul>
    </article>
  `;
}

function importArchetypeCatalog() {
  const file = elements.importArchetypesInput.files[0];
  if (!file) {
    return;
  }
  const reader = new FileReader();
  reader.addEventListener("load", () => {
    try {
      const parsed = JSON.parse(String(reader.result));
      const entries = Array.isArray(parsed) ? parsed : parsed.archetypes;
      if (!Array.isArray(entries) || entries.length === 0) {
        throw new Error("No archetypes found.");
      }
      state.archetypeLibraryName = String(parsed.library_name ?? parsed.libraryName ?? file.name.replace(/\.json$/i, "") ?? baseline.archetypeLibraryName).trim() || baseline.archetypeLibraryName;
      state.archetypeCatalog = entries.map((entry) => normalizeImportedArchetype(entry));
      state.pendingDeleteArchetypeId = "";
      state.activeArchetypeId = state.archetypeCatalog[0].id;
      state.activeArchetypeDraft = cloneArchetype(state.archetypeCatalog[0]);
      elements.archetypeLibraryName.value = state.archetypeLibraryName;
      saveArchetypeCatalog();
      refreshArchetypeSelects();
      restoreSelectedArchetypes();
      loadArchetypeDraft(state.activeArchetypeId);
      elements.archetypeSaveState.textContent = `Imported ${state.archetypeCatalog.length}`;
      stageGeneratorSettings();
      renderEmptyMonsterState();
    } catch (error) {
      elements.archetypeSaveState.textContent = "Import failed";
      console.error(error);
    } finally {
      elements.importArchetypesInput.value = "";
    }
  });
  reader.readAsText(file);
}

function serializeArchetypeForExport(archetype) {
  const normalized = normalizeArchetypeDraft(cloneArchetype(archetype));
  return {
    id: normalized.id,
    name: normalized.name,
    tone: normalized.tone,
    tags: normalized.tags,
    unlock_difficulty: normalized.unlockDifficulty,
    allowed_kinds: normalized.allowedKinds,
    route_weight: normalized.routeWeight,
    base_hp_bias: normalized.baseHpBias,
    mechanicWeights: normalized.mechanicWeights,
    mechanicConfigs: normalized.mechanicConfigs,
    nameParts: normalized.nameParts,
  };
}

function downloadTextFile(fileName, text, type) {
  const blob = new Blob([text], { type });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(blob);
  link.download = fileName;
  link.click();
  URL.revokeObjectURL(link.href);
}

async function saveTextFile(fileName, text, type) {
  if (window.showSaveFilePicker) {
    try {
      const handle = await window.showSaveFilePicker({
        suggestedName: fileName,
        types: [
          {
            description: "Monster Lab archetype library",
            accept: { [type]: [".json"] },
          },
        ],
      });
      const writable = await handle.createWritable();
      await writable.write(text);
      await writable.close();
      return true;
    } catch (error) {
      if (error?.name === "AbortError") {
        elements.archetypeSaveState.textContent = "Export canceled";
        return false;
      }
      console.warn("Save picker failed; falling back to browser download.", error);
    }
  }
  downloadTextFile(fileName, text, type);
  return true;
}

function getArchetype(id) {
  return state.archetypeCatalog.find((archetype) => archetype.id === id) ?? null;
}

function getSecondaryArchetype() {
  if (elements.archetypeB.value === "") {
    return null;
  }
  return getArchetype(elements.archetypeB.value);
}

function getMechanic(id) {
  return mechanics.find((mechanic) => mechanic.id === id);
}

function validateCanonicalMechanics() {
  const mechanicIds = new Set();
  for (const mechanic of mechanics) {
    if (!canonicalGodotFields.has(mechanic.godotField)) {
      throw new Error(`Monster Lab mechanic '${mechanic.id}' exports unknown Godot field '${mechanic.godotField}'.`);
    }
    if (mechanicIds.has(mechanic.id)) {
      throw new Error(`Monster Lab mechanic '${mechanic.id}' is duplicated.`);
    }
    mechanicIds.add(mechanic.id);
  }
  for (const archetype of archetypes) {
    for (const mechanicId of Object.keys(archetype.mechanicWeights)) {
      if (!mechanicIds.has(mechanicId)) {
        throw new Error(`Monster Lab archetype '${archetype.id}' references unknown mechanic '${mechanicId}'.`);
      }
    }
  }
}

function buildGodotMonsterOverrides(monster) {
  const overrides = {
    hp: monster.hp,
  };
  for (const entry of monster.mechanics) {
    const mechanic = getMechanic(entry.id);
    if (!mechanic || !canonicalGodotFields.has(mechanic.godotField)) {
      continue;
    }
    overrides[mechanic.godotField] = godotExportValue(entry);
  }
  return overrides;
}

function godotExportValue(entry) {
  const mechanic = getMechanic(entry.id);
  const scale = mechanic?.exportScale ?? 1;
  const value = entry.value * scale;
  if (Number.isInteger(scale) && Number.isInteger(entry.value)) {
    return entry.value;
  }
  return Number(value.toFixed(4));
}

function getDifficultyBand(id) {
  return difficultyBands.find((band) => band.id === id) ?? difficultyBands[0];
}

function normalizeDifficultyId(value) {
  const fallback = baseline.difficulty;
  const id = clampNumber(value, difficultyBands[0]?.id ?? 1, difficultyBands.at(-1)?.id ?? 5, fallback);
  return getDifficultyBand(id).id;
}

function normalizeTags(value) {
  const source = Array.isArray(value) ? value : String(value ?? "").split(",");
  return [...new Set(source
    .map((tag) => slugify(tag))
    .filter(Boolean))]
    .sort((a, b) => a.localeCompare(b));
}

function normalizeAllowedKinds(value) {
  const allowed = new Set(["normal", "elite", "boss"]);
  const source = Array.isArray(value) ? value : String(value ?? "").split(",");
  const normalized = source.filter((kind) => allowed.has(kind));
  return normalized.length ? normalized : ["normal", "elite", "boss"];
}

function defaultMechanicExtras(mechanic) {
  return Object.fromEntries((mechanic?.extraFields ?? []).map((field) => [field.id, field.default]));
}

function normalizeMechanicExtras(mechanic, extras = {}) {
  return Object.fromEntries(
    (mechanic?.extraFields ?? []).map((field) => [
      field.id,
      clampNumber(extras?.[field.id], field.min, field.max, field.default),
    ]),
  );
}

function renderMechanicExtraFields(mechanic, config) {
  if (!mechanic.extraFields?.length) {
    return "";
  }
  const extras = normalizeMechanicExtras(mechanic, config.extras);
  return `
    <div class="custom-mechanic-extra-fields">
      ${mechanic.extraFields
        .map((field) => `
          <label class="mini-field">
            <span>${escapeHtml(field.label)}</span>
            <input type="number" min="${field.min}" max="${field.max}" step="${field.step}" value="${extras[field.id]}" data-extra-field="${field.id}">
          </label>
        `)
        .join("")}
    </div>
    <p class="mechanic-extra-note">${mechanic.extraFields.map((field) => escapeHtml(field.description)).join(" ")}</p>
  `;
}

function readMechanicExtraFields(mechanic, card) {
  const extras = defaultMechanicExtras(mechanic);
  for (const field of mechanic.extraFields ?? []) {
    const input = card.querySelector(`[data-extra-field='${field.id}']`);
    extras[field.id] = clampNumber(input?.value, field.min, field.max, field.default);
  }
  return extras;
}

function mergeMechanicExtras(mechanicId, configs) {
  const mechanic = getMechanic(mechanicId);
  const fields = mechanic?.extraFields ?? [];
  if (!fields.length) {
    return {};
  }
  const totalWeight = configs.reduce((sum, entry) => sum + entry.weight, 0);
  const merged = {};
  for (const field of fields) {
    const value = configs.reduce((sum, entry) => {
      const extras = normalizeMechanicExtras(mechanic, entry.config.extras);
      return sum + extras[field.id] * entry.weight;
    }, 0) / Math.max(1, totalWeight);
    merged[field.id] = Math.round(clampNumber(value, field.min, field.max, field.default));
  }
  return merged;
}

function renderMechanicExtrasSummary(entry) {
  const mechanic = getMechanic(entry.id);
  const fields = mechanic?.extraFields ?? [];
  if (!fields.length) {
    return "";
  }
  const extras = normalizeMechanicExtras(mechanic, entry.extras);
  return `
    <div class="mechanic-extra-summary">
      ${fields
        .map((field) => `<span>${escapeHtml(field.label)} ${extras[field.id]} ${escapeHtml(field.valueLabel ?? "")}</span>`)
        .join("")}
    </div>
  `;
}

function selectedAllowedKinds() {
  const kinds = [];
  if (elements.archetypeKindNormal.checked) {
    kinds.push("normal");
  }
  if (elements.archetypeKindElite.checked) {
    kinds.push("elite");
  }
  if (elements.archetypeKindBoss.checked) {
    kinds.push("boss");
  }
  return normalizeAllowedKinds(kinds);
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

function average(values) {
  if (!values.length) {
    return 0;
  }
  return values.reduce((sum, value) => sum + value, 0) / values.length;
}

function formatWeight(value) {
  if (Number.isInteger(value)) {
    return String(value);
  }
  return value.toFixed(1);
}

function formatList(values) {
  const entries = uniqueNonEmpty(values);
  if (entries.length <= 1) {
    return entries[0] ?? "";
  }
  if (entries.length === 2) {
    return `${entries[0]} and ${entries[1]}`;
  }
  return `${entries.slice(0, -1).join(", ")}, and ${entries.at(-1)}`;
}

function uniqueNonEmpty(values) {
  const seen = new Set();
  const output = [];
  for (const value of values) {
    const text = String(value ?? "").trim();
    if (!text || seen.has(text)) {
      continue;
    }
    seen.add(text);
    output.push(text);
  }
  return output;
}

function formatMechanicValue(entry) {
  return `${entry.value} ${entry.valueLabel}`.trim();
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

setupControls();
renderArchetypeEditor();
stageGeneratorSettings();
renderEmptyMonsterState();
