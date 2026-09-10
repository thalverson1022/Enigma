"use strict";

const fs = require("node:fs");
const path = require("node:path");

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

const root = __dirname;
const filesToScan = ["README.md", "index.html", "app.js"];
const forbiddenPatterns = [
  { pattern: /Phase 4/i, label: "Phase 4 presentation language" },
  { pattern: /DawnBringer/i, label: "DawnBringer presentation language" },
  { pattern: /affix\.poison_damage_per_tick/i, label: "old poison tick affix id" },
  { pattern: /affix\.armor_reduction/i, label: "old armor reduction affix id" },
  { pattern: /affix\.physical_skill_damage/i, label: "old physical skill damage affix id" },
  { pattern: /amazing[-_\s]?score/i, label: "old amazing-score shop metric" },
  { pattern: /legendary[^\\n]*(weight|roll|generate|procedural)/i, label: "procedural Legendary behavior" },
];

const allowedBoundaryPatterns = [
  /legendary: "Legendary"/i,
  /Legendary: fixed catalog, P5M10 tuning/i,
  /fixed Legendary catalog items/i,
  /Legendary stat packages/i,
];

const failures = [];
for (const fileName of filesToScan) {
  const filePath = path.join(root, fileName);
  const text = fs.readFileSync(filePath, "utf8");
  const lines = text.split(/\r?\n/);
  lines.forEach((line, index) => {
    for (const { pattern, label } of forbiddenPatterns) {
      if (!pattern.test(line)) {
        continue;
      }
      if (/legendary/i.test(line) && allowedBoundaryPatterns.some((allowed) => allowed.test(line))) {
        continue;
      }
      failures.push(`${fileName}:${index + 1}: ${label}: ${line.trim()}`);
    }
  });
}

const appText = fs.readFileSync(path.join(root, "app.js"), "utf8");
assert(/\["weapon", "helm", "armor", "trinket", "charm"\]/.test(appText), "five-slot array is missing");
assert(!/\["weapon", "trinket", "charm"\]/.test(appText), "old three-slot array returned");
assert(!/const\s+proceduralRarities\s*=\s*\[[^\]]*"legendary"/s.test(appText), "Legendary returned to procedural rarity list");
assert(!/const\s+proceduralRarities\s*=\s*\[[^\]]*"crude"/s.test(appText), "Crude returned to procedural rarity list");
assert(failures.length === 0, `stale Shop Lab assumptions found:\n${failures.join("\n")}`);

console.log(`stale assumptions ok: scanned ${filesToScan.length} files`);
