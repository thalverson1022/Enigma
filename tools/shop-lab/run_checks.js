"use strict";

const { spawnSync } = require("node:child_process");
const path = require("node:path");

const checks = [
  ["node", ["--check", "app.js"]],
  ["node", ["--check", "determinism_check.js"]],
  ["node", ["--check", "curve_check.js"]],
  ["node", ["--check", "value_check.js"]],
  ["node", ["--check", "readability_check.js"]],
  ["node", ["--check", "distribution_check.js"]],
  ["node", ["--check", "cursed_chaos_check.js"]],
  ["node", ["--check", "retrigger_check.js"]],
  ["node", ["--check", "preset_check.js"]],
  ["node", ["--check", "random_seed_check.js"]],
  ["node", ["--check", "phase5_shape_check.js"]],
  ["node", ["--check", "stale_assumption_check.js"]],
  ["node", ["determinism_check.js"]],
  ["node", ["curve_check.js"]],
  ["node", ["value_check.js"]],
  ["node", ["readability_check.js"]],
  ["node", ["distribution_check.js"]],
  ["node", ["cursed_chaos_check.js"]],
  ["node", ["retrigger_check.js"]],
  ["node", ["preset_check.js"]],
  ["node", ["random_seed_check.js"]],
  ["node", ["phase5_shape_check.js"]],
  ["node", ["stale_assumption_check.js"]],
];

const cwd = __dirname;

for (const [command, args] of checks) {
  const label = [command, ...args].join(" ");
  process.stdout.write(`\n> ${label}\n`);
  const result = spawnSync(command, args, {
    cwd,
    encoding: "utf8",
  });
  if (result.stdout) {
    process.stdout.write(result.stdout);
  }
  if (result.stderr) {
    process.stderr.write(result.stderr);
  }
  if (result.status !== 0) {
    process.stderr.write(`check failed: ${label}\n`);
    process.exit(result.status ?? 1);
  }
}

console.log(`\nshop-lab checks ok: ${checks.length} checks passed`);
