"use strict";

const fs = require("fs");
const path = require("path");
const vm = require("vm");

const root = __dirname;
const context = { window: {} };
vm.createContext(context);

for (const file of ["data/mechanics.js", "data/archetypes.js", "data/difficulty.js"]) {
  vm.runInContext(fs.readFileSync(path.join(root, file), "utf8"), context, { filename: file });
}

const mechanics = context.window.MonsterLabMechanics;
const archetypes = context.window.MonsterLabArchetypes;
const difficultyBands = context.window.MonsterLabDifficultyBands;
const { convertMonsterLabExport } = require("./export_to_balance_lab.js");

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

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

assert(Array.isArray(mechanics) && mechanics.length === canonicalGodotFields.size, "Unexpected canonical mechanic count.");
assert(Array.isArray(archetypes) && archetypes.length > 0, "Missing archetypes.");
assert(Array.isArray(difficultyBands) && difficultyBands.length > 0, "Missing difficulty bands.");

const mechanicIds = new Set();
const maxDifficultyId = Math.max(...difficultyBands.map((band) => band.id));
for (const mechanic of mechanics) {
  assert(!mechanicIds.has(mechanic.id), `Duplicate mechanic id '${mechanic.id}'.`);
  mechanicIds.add(mechanic.id);
  assert(canonicalGodotFields.has(mechanic.godotField), `Unknown Godot field '${mechanic.godotField}' for '${mechanic.id}'.`);
  assert(typeof mechanic.exportScale === "number", `Missing exportScale for '${mechanic.id}'.`);
  assert(mechanic.curves && mechanic.curves[1] && mechanic.curves[maxDifficultyId], `Missing difficulty curves for '${mechanic.id}'.`);
  assert(mechanic.matchup && typeof mechanic.matchup === "object", `Missing matchup language for '${mechanic.id}'.`);
  for (const field of ["identity", "pressure", "counterplay", "route"]) {
    assert(typeof mechanic.matchup[field] === "string" && mechanic.matchup[field].trim().length > 0, `Missing matchup.${field} for '${mechanic.id}'.`);
  }
}

for (const field of canonicalGodotFields) {
  assert([...mechanics].some((mechanic) => mechanic.godotField === field), `Missing mechanic for Godot field '${field}'.`);
}

for (const archetype of archetypes) {
  assert(typeof archetype.id === "string" && archetype.id.trim().length > 0, "Archetype is missing an id.");
  assert(typeof archetype.name === "string" && archetype.name.trim().length > 0, `Archetype '${archetype.id}' is missing a name.`);
  assert(typeof archetype.tone === "string" && archetype.tone.trim().length > 0, `Archetype '${archetype.id}' is missing tone language.`);
  assert(typeof archetype.baseHpBias === "number" && archetype.baseHpBias > 0, `Archetype '${archetype.id}' needs a positive baseHpBias.`);
  assert(archetype.nameParts && Array.isArray(archetype.nameParts.prefixes) && archetype.nameParts.prefixes.length > 0, `Archetype '${archetype.id}' needs name prefixes.`);
  assert(archetype.nameParts && Array.isArray(archetype.nameParts.nouns) && archetype.nameParts.nouns.length > 0, `Archetype '${archetype.id}' needs name nouns.`);
  for (const mechanicId of Object.keys(archetype.mechanicWeights)) {
    assert(mechanicIds.has(mechanicId), `Archetype '${archetype.id}' references unknown mechanic '${mechanicId}'.`);
    assert(typeof archetype.mechanicWeights[mechanicId] === "number" && archetype.mechanicWeights[mechanicId] > 0, `Archetype '${archetype.id}' mechanic '${mechanicId}' needs a positive weight.`);
  }
}

function exportValue(mechanic, value) {
  const scaled = value * mechanic.exportScale;
  return Number.isInteger(mechanic.exportScale) && Number.isInteger(value) ? value : Number(scaled.toFixed(4));
}

const sampleOverrides = {};
for (const mechanic of mechanics) {
  const sampleValue = mechanic.curves[3][0];
  sampleOverrides[mechanic.godotField] = exportValue(mechanic, sampleValue);
}

assert(sampleOverrides.poison_resistance > 0 && sampleOverrides.poison_resistance < 1, "poison_resistance should export as a fraction.");
assert(sampleOverrides.dodge_chance > 0 && sampleOverrides.dodge_chance < 1, "dodge_chance should export as a fraction.");
assert(sampleOverrides.crit_negation > 0 && sampleOverrides.crit_negation < 1, "crit_negation should export as a fraction.");
assert(sampleOverrides.armor >= 1, "armor should export as a direct numeric value.");
assert(Number.isInteger(sampleOverrides.cleanse_threshold), "cleanse_threshold should export as an integer threshold.");

const sampleExport = JSON.parse(fs.readFileSync(path.join(root, "fixtures/monster_lab_export_sample.json"), "utf8"));
const scenarioCatalog = convertMonsterLabExport(sampleExport, { sourcePath: "fixtures/monster_lab_export_sample.json", seedCount: 12 });
assert(scenarioCatalog.schema === "monster_lab_balance_scenarios.v1", "Converted Balance Lab catalog should use the v1 schema.");
assert(scenarioCatalog.scenarios.length >= 3, "Converted Balance Lab catalog should include multiple probe scenarios.");
assert(scenarioCatalog.matchup_preview?.identity, "Converted Balance Lab catalog should preserve matchup identity.");
assert(scenarioCatalog.balance_model?.pressure_status === "in_band", "Converted Balance Lab catalog should preserve pressure status.");
for (const scenario of scenarioCatalog.scenarios) {
  assert(scenario.id.startsWith("monster_lab_"), "Converted scenario ids should be namespaced.");
  assert(scenario.source === "monster_lab", "Converted scenarios should preserve their Monster Lab source.");
  assert(scenario.monster_overrides.hp === 180, "Converted scenarios should preserve Godot monster overrides.");
  assert(scenario.duration_ms === 20000, "Converted scenarios should preserve Godot duration_ms.");
  assert(scenario.matchup_preview?.route_preview, "Converted scenarios should preserve matchup preview language.");
  assert(Array.isArray(scenario.skills) && scenario.skills.length > 0, "Converted scenarios should include a probe rotation.");
  assert(Array.isArray(scenario.gear), "Converted scenarios should include a gear array.");
  assert(Object.keys(scenario.thresholds ?? {}).length === 0, "Converted bridge scenarios should not invent hard balance thresholds.");
  assert(scenario.balance_model?.pressure_status === "in_band", "Converted scenarios should preserve pressure status.");
}

for (const invalidExport of [
  {},
  { project: "DawnBringer", tool: "Monster Lab", monster: {} },
  { project: "DawnBringer", tool: "Monster Lab", monster: { id: "bad", name: "Bad", duration: 0, godot: { monster_overrides: {} } } },
]) {
  let failed = false;
  try {
    convertMonsterLabExport(invalidExport);
  } catch {
    failed = true;
  }
  assert(failed, "Invalid Monster Lab exports should fail converter validation.");
}

let previousBandId = 0;
let previousTargetHigh = 0;
for (const band of difficultyBands) {
  assert(Number.isInteger(band.id) && band.id > previousBandId, `Difficulty band '${band.name}' should have an ascending integer id.`);
  assert(typeof band.name === "string" && band.name.length > 0, `Difficulty band ${band.id} is missing a name.`);
  assert(typeof band.budget === "number" && band.budget > 0, `Difficulty band '${band.name}' needs a positive budget.`);
  assert(Array.isArray(band.mechanicCount) && band.mechanicCount.length === 2, `Difficulty band '${band.name}' needs a mechanicCount range.`);
  assert(band.mechanicCount[0] >= 1 && band.mechanicCount[1] >= band.mechanicCount[0], `Difficulty band '${band.name}' has an invalid mechanicCount range.`);
  assert(Number.isInteger(band.maxMajorDefenses) && band.maxMajorDefenses >= 1, `Difficulty band '${band.name}' needs maxMajorDefenses.`);
  assert(typeof band.majorDefenseCost === "number" && band.majorDefenseCost > 0, `Difficulty band '${band.name}' needs majorDefenseCost.`);
  assert(band.maxMajorDefenses <= band.mechanicCount[1], `Difficulty band '${band.name}' allows more major defenses than selected mechanics.`);
  assert(Array.isArray(band.targetDpsRange) && band.targetDpsRange.length === 2, `Difficulty band '${band.name}' needs a targetDpsRange.`);
  assert(band.targetDpsRange[0] > 0 && band.targetDpsRange[1] > band.targetDpsRange[0], `Difficulty band '${band.name}' has an invalid targetDpsRange.`);
  assert(band.targetDpsRange[0] >= previousTargetHigh, `Difficulty band '${band.name}' should not drop below the previous target DPS range.`);
  assert(typeof band.dpsTolerance === "number" && band.dpsTolerance > 0 && band.dpsTolerance < 0.5, `Difficulty band '${band.name}' needs a reasonable dpsTolerance.`);
  assert(!Object.hasOwn(band, "baseHp"), `Difficulty band '${band.name}' should derive HP from target DPS instead of baseHp.`);
  assert(!Object.hasOwn(band, "duration"), `Difficulty band '${band.name}' should get duration from tempo profiles instead of band.duration.`);
  assert(!Object.hasOwn(band, "targetDps"), `Difficulty band '${band.name}' should use targetDpsRange instead of fixed targetDps.`);
  previousBandId = band.id;
  previousTargetHigh = band.targetDpsRange[1];
}

console.log("Monster Lab validation: OK");
