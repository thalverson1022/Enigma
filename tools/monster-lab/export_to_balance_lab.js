"use strict";

const fs = require("fs");
const path = require("path");

const DEFAULT_OUTPUT_DIR = path.join("project", "data", "balance_lab", "imported");
const DEFAULT_BASE_MONSTER = "res://data/monsters/mouthy_drunk.tres";
const DEFAULT_CLASS = "res://data/classes/rogue.tres";
const DEFAULT_SEED_COUNT = 80;

const probes = [
  {
    idSuffix: "physical_stab",
    labelSuffix: "Physical Stab Probe",
    trees: [],
    talents: [],
    gear: [],
    skills: ["res://data/skills/stab.tres"],
    gold: 0,
  },
  {
    idSuffix: "poison_shadow",
    labelSuffix: "Shadow Poison Probe",
    trees: ["res://data/subclass_trees/shadow.tres"],
    talents: [],
    gear: ["res://data/gear/wyvern_kriss.tres"],
    skills: ["res://data/skills/stab.tres", "res://data/skills/heavy_slash.tres"],
    gold: 0,
  },
  {
    idSuffix: "crit_bandit",
    labelSuffix: "Bandit Crit Probe",
    trees: [],
    talents: [],
    gear: ["res://data/gear/bandit_blade.tres"],
    skills: ["res://data/skills/stab.tres", "res://data/skills/heavy_slash.tres"],
    gold: 100,
  },
];

function main(argv) {
  const args = parseArgs(argv);
  if (args.help || !args.input) {
    printUsage();
    process.exit(args.help ? 0 : 1);
  }
  const source = JSON.parse(fs.readFileSync(args.input, "utf8"));
  const catalog = convertMonsterLabExport(source, {
    sourcePath: args.input,
    seedCount: args.seedCount ?? DEFAULT_SEED_COUNT,
    baseMonster: args.baseMonster ?? DEFAULT_BASE_MONSTER,
  });
  const outputPath = args.output ?? defaultOutputPath(catalog, args.outputDir ?? DEFAULT_OUTPUT_DIR);
  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  fs.writeFileSync(outputPath, `${JSON.stringify(catalog, null, 2)}\n`);
  console.log(`Wrote ${catalog.scenarios.length} Balance Lab scenarios: ${outputPath}`);
}

function convertMonsterLabExport(source, options = {}) {
  assert(source?.project === "DawnBringer", "Expected a DawnBringer Monster Lab export.");
  assert(source?.tool === "Monster Lab", "Expected tool to be Monster Lab.");
  const monster = source.monster;
  assert(monster && typeof monster === "object", "Missing monster export block.");
  const godot = monster.godot ?? {};
  const overrides = godot.monster_overrides ?? {};
  assert(Object.keys(overrides).length > 0, "Missing monster.godot.monster_overrides.");

  const durationMs = Number(godot.duration_ms ?? monster.duration * 1000);
  assert(Number.isFinite(durationMs) && durationMs > 0, "Missing positive Godot duration_ms.");

  const sourceId = slugify(monster.id || monster.name || "monster_lab_import");
  const monsterName = String(monster.name || sourceId);
  const warnings = monster.balance_model?.warnings ?? [];
  const matchupPreview = monster.matchup_preview ?? {};
  const seedCount = Number(options.seedCount ?? DEFAULT_SEED_COUNT);
  assert(Number.isInteger(seedCount) && seedCount > 0, "seedCount must be a positive integer.");

  return {
    project: "DawnBringer",
    tool: "Monster Lab",
    schema: "monster_lab_balance_scenarios.v1",
    source_monster_id: sourceId,
    source_monster_name: monsterName,
    source_file: options.sourcePath ? path.normalize(options.sourcePath) : "",
    matchup_preview: matchupPreview,
    balance_model: {
      target_dps: monster.target_dps,
      target_dps_range: monster.target_dps_range,
      dps_tolerance: monster.dps_tolerance,
      pressure_status: monster.balance_model?.pressure_status ?? "",
      pressure_status_label: monster.balance_model?.pressure_status_label ?? "",
      pressure: monster.balance_model?.pressure ?? {},
      warnings,
    },
    scenarios: probes.map((probe, index) => ({
      id: `monster_lab_${sourceId}_${probe.idSuffix}`,
      label: `${monsterName} - ${probe.labelSuffix}`,
      source: "monster_lab",
      source_monster_id: sourceId,
      class: DEFAULT_CLASS,
      trees: probe.trees,
      talents: probe.talents,
      gear: probe.gear,
      skills: probe.skills,
      monster: options.baseMonster ?? DEFAULT_BASE_MONSTER,
      monster_overrides: overrides,
      duration_ms: Math.round(durationMs),
      seed_start: 5001 + index * seedCount,
      seed_count: seedCount,
      gold: probe.gold,
      thresholds: {},
      matchup_preview: matchupPreview,
      balance_model: {
        target_dps: monster.target_dps,
        target_dps_range: monster.target_dps_range,
        pressure_status: monster.balance_model?.pressure_status ?? "",
        pressure_status_label: monster.balance_model?.pressure_status_label ?? "",
      },
      notes: [
        `Monster Lab bridge import for ${monsterName}.`,
        matchupPreview.route_preview ?? "",
        ...warnings.map((warning) => `${warning.category ?? "Notice"}: ${warning.title ?? warning}`),
      ].filter(Boolean),
    })),
  };
}

function parseArgs(argv) {
  const args = {};
  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];
    if (token === "--help" || token === "-h") {
      args.help = true;
    } else if (token === "--input" || token === "-i") {
      args.input = argv[++index];
    } else if (token === "--output" || token === "-o") {
      args.output = argv[++index];
    } else if (token === "--output-dir") {
      args.outputDir = argv[++index];
    } else if (token === "--seed-count") {
      args.seedCount = Number(argv[++index]);
    } else if (token === "--base-monster") {
      args.baseMonster = argv[++index];
    } else if (!args.input) {
      args.input = token;
    } else {
      throw new Error(`Unknown argument: ${token}`);
    }
  }
  return args;
}

function defaultOutputPath(catalog, outputDir) {
  return path.join(outputDir, `${catalog.source_monster_id}.balance_lab.json`);
}

function printUsage() {
  console.log([
    "Usage: node tools/monster-lab/export_to_balance_lab.js --input monster.json [--output scenario.json]",
    "",
    "Converts one Monster Lab monster export into a Balance Lab scenario catalog.",
  ].join("\n"));
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function slugify(value) {
  return String(value)
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "") || "monster_lab_import";
}

if (require.main === module) {
  main(process.argv.slice(2));
}

module.exports = {
  convertMonsterLabExport,
};
