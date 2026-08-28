const BIOME_PRESENTATION = {
  Swamp: {
    normal: ["Green Slime", "Swamp Goblin", "Bog Rat", "Giant Leech", "Poison Frog"],
    captain: ["Troll", "Bog Witch"],
    elite: ["Hydra Spawn", "Mire Knight", "Green Hag"],
    boss: ["Swamp Hydra", "Ancient Troll", "Slime Queen", "The Drowned Matriarch", "Bogheart Colossus"],
    gradient: "linear-gradient(180deg, #1d3329 0%, #0d1718 56%, #14130b 100%)",
  },
  Cave: {
    normal: ["Vampire Bat", "Wolf Spider", "Goblin", "Troglodyte", "Ogre"],
    captain: ["Troll", "Giant Centipede"],
    elite: ["Basilisk", "Cave Brute", "Echoing Seer"],
    boss: ["Purple Cave Wyrm", "The Goblin King", "Ancient Basilisk", "The Deep Maw", "Gemvein Tyrant"],
    gradient: "linear-gradient(180deg, #1d2230 0%, #0c1018 58%, #19140f 100%)",
  },
  Graveyard: {
    normal: ["Restless Spirit", "Giant Rat", "Wolf", "Skeleton", "Zombie"],
    captain: ["Golem", "Grave Robber"],
    elite: ["Wight", "Necromancer", "Mire Knight"],
    boss: ["Bone Colossus", "Lich", "Headless Knight", "The Bell-Tower Revenant", "King Leoric"],
    gradient: "linear-gradient(180deg, #243031 0%, #11161a 56%, #151411 100%)",
  },
  "Haunted Forest": {
    normal: ["Spider", "Forest Goblin", "Wisp", "Treant Sapling", "Dire Wolf"],
    captain: ["Werewolf", "Treant"],
    elite: ["Green Hag", "Night Stalker", "Hollow-Eyed Witch"],
    boss: ["Ancient Treant", "Forest Witch", "Great Werewolf", "The Root-Crowned Widow", "Moonless Huntmaster"],
    gradient: "linear-gradient(180deg, #183125 0%, #0b1615 56%, #12160e 100%)",
  },
  "Ruined Keep": {
    normal: ["Rat", "Undead Guard", "Bandit", "Cultist", "Animated Armor"],
    captain: ["Gargoyle", "Warlock"],
    elite: ["Dark Knight", "Oathbreaker Captain", "Arcane Golem"],
    boss: ["Fallen King", "Bejeweled Iron Golem", "The Half-blood Prince", "The Last Castellan", "Faithless Executioner"],
    gradient: "linear-gradient(180deg, #302b2e 0%, #151419 58%, #18120f 100%)",
  },
  "Ancient Ruins": {
    normal: ["Cultist", "Animated Statue", "Scarab", "Wisp"],
    captain: ["Minotaur", "Guardian Construct"],
    elite: ["Arcane Golem", "Runemark Sentinel", "Scarab Queen"],
    boss: ["Ancient Guardian", "Sphinx", "Runic Colossus", "The First Idol", "Ancient Archivist"],
    gradient: "linear-gradient(180deg, #2e2b20 0%, #151712 58%, #17120b 100%)",
  },
};

const CAPTAIN_PROMOTED_NORMAL_NAMES = {
  "Green Slime": "Giant Green Slime",
  "Swamp Goblin": "Veteran Swamp Goblin",
  "Bog Rat": "Giant Bog Rat",
  "Giant Leech": "Elder Leech",
  "Poison Frog": "Giant Poison Frog",
  "Vampire Bat": "Giant Vampire Bat",
  "Wolf Spider": "Giant Wolf Spider",
  Goblin: "Veteran Goblin",
  Troglodyte: "Veteran Troglodyte",
  Ogre: "Veteran Ogre",
  "Restless Spirit": "Ancient Restless Spirit",
  "Giant Rat": "Dire Rat",
  Wolf: "Giant Wolf",
  Skeleton: "Ancient Skeleton",
  Zombie: "Ancient Zombie",
  Spider: "Giant Spider",
  "Forest Goblin": "Veteran Forest Goblin",
  Wisp: "Ancient Wisp",
  "Treant Sapling": "Ancient Treant Sapling",
  "Dire Wolf": "Alpha Dire Wolf",
  Rat: "Giant Rat",
  "Undead Guard": "Ancient Undead Guard",
  Bandit: "Veteran Bandit",
  Cultist: "Veteran Cultist",
  "Animated Armor": "Ancient Animated Armor",
  "Animated Statue": "Ancient Animated Statue",
  Scarab: "Giant Scarab",
};

const TYPE_LABELS = {
  normal: "Normal",
  captain: "Captain",
  elite: "Elite",
  boss: "Boss",
};

const elements = {
  type: document.querySelector("#type-select"),
  biome: document.querySelector("#biome-select"),
  name: document.querySelector("#name-select"),
  size: document.querySelector("#size-select"),
  prompt: document.querySelector("#prompt-output"),
  candidateInput: document.querySelector("#candidate-input"),
  grid: document.querySelector("#candidate-grid"),
  count: document.querySelector("#candidate-count"),
  preview: document.querySelector("#preview-canvas"),
  stage: document.querySelector(".stage"),
  selectedLabel: document.querySelector("#selected-label"),
  metadata: document.querySelector("#metadata-output"),
  pathHint: document.querySelector("#path-hint"),
  refreshPrompt: document.querySelector("#refresh-prompt-button"),
  copyPrompt: document.querySelector("#copy-prompt-button"),
  exportPng: document.querySelector("#export-png-button"),
  exportJson: document.querySelector("#export-json-button"),
  copyJson: document.querySelector("#copy-json-button"),
  previewHit: document.querySelector("#preview-hit-button"),
  exportMask: document.querySelector("#export-mask-button"),
};

let candidates = [];
let selectedIndex = -1;

function init() {
  Object.keys(BIOME_PRESENTATION).forEach((biome) => {
    elements.biome.add(new Option(biome, biome));
  });

  elements.type.addEventListener("change", onIdentityChanged);
  elements.biome.addEventListener("change", onIdentityChanged);
  elements.name.addEventListener("change", onIdentityChanged);
  elements.refreshPrompt.addEventListener("click", updatePrompt);
  elements.copyPrompt.addEventListener("click", copyPrompt);
  elements.candidateInput.addEventListener("change", importCandidateFiles);
  elements.exportPng.addEventListener("click", exportSelectedPng);
  elements.exportJson.addEventListener("click", exportSelectedJson);
  elements.copyJson.addEventListener("click", copyMetadata);
  elements.previewHit.addEventListener("click", previewHit);
  elements.exportMask.addEventListener("click", exportWhiteMask);

  populateNames();
  updatePrompt();
  addEmptyState();
  updateMetadata();
  drawPreview();
}

function onIdentityChanged(event) {
  if (event.target === elements.type || event.target === elements.biome) {
    populateNames();
  }
  updatePrompt();
  updateMetadata();
  drawPreview();
}

function populateNames() {
  const current = elements.name.value;
  const names = namesFor(elements.biome.value, elements.type.value);
  elements.name.innerHTML = "";
  names.forEach((name) => elements.name.add(new Option(name, name)));
  if (names.includes(current)) {
    elements.name.value = current;
  }
}

function namesFor(biome, type) {
  const table = BIOME_PRESENTATION[biome];
  if (type !== "captain") {
    return table[type].slice();
  }

  const promoted = table.normal
    .map((name) => CAPTAIN_PROMOTED_NORMAL_NAMES[name])
    .filter(Boolean);
  return table.captain.concat(promoted);
}

function updatePrompt() {
  elements.prompt.value = buildPrompt();
}

function buildPrompt() {
  const type = TYPE_LABELS[elements.type.value];
  const biome = elements.biome.value;
  const name = elements.name.value;
  return [
    "Create four distinct 32x32 pixel-art RPG enemy sprite candidates for DawnBringer.",
    `Enemy name: ${name}. Enemy type: ${type}. Biome: ${biome}.`,
    "Use a transparent background. Single static full-body combat sprite only.",
    "No text, no UI, no border, no scenery, no baked-in floor shadow.",
    "Keep the silhouette readable at 32x32, with chunky pixel clusters and a limited palette.",
    "Face three-quarters toward the viewer, grounded near the bottom of the canvas, centered with a little transparent padding.",
    "Style target: dark fantasy roguelite, readable tabletop monster token, crisp pixel art, not smooth illustration.",
    `Make the ${type} rank visible through silhouette only: Normal is simple, Captain is tougher, Elite is more threatening, Boss is larger and iconic.`,
    "Return separate transparent PNG images if possible.",
  ].join("\n");
}

async function copyPrompt() {
  await writeClipboard(elements.prompt.value, elements.prompt);
}

async function importCandidateFiles(event) {
  const files = Array.from(event.target.files || []);
  const firstImportedIndex = candidates.length;
  for (const file of files) {
    const image = await loadImage(file);
    const normalized = normalizeToSpriteCanvas(image, Number(elements.size.value));
    candidates.push({
      file_name: file.name,
      source_width: image.naturalWidth,
      source_height: image.naturalHeight,
      canvas: normalized,
    });
  }
  renderCandidates();
  if (files.length > 0) {
    selectCandidate(firstImportedIndex);
  }
  event.target.value = "";
}

function normalizeToSpriteCanvas(image, size) {
  const canvas = document.createElement("canvas");
  canvas.width = size;
  canvas.height = size;
  const context = canvas.getContext("2d");
  context.clearRect(0, 0, size, size);
  context.imageSmoothingEnabled = false;

  const scale = Math.min(size / image.naturalWidth, size / image.naturalHeight);
  const drawWidth = Math.max(1, Math.round(image.naturalWidth * scale));
  const drawHeight = Math.max(1, Math.round(image.naturalHeight * scale));
  const x = Math.round((size - drawWidth) / 2);
  const y = Math.round(size - drawHeight);
  context.drawImage(image, x, y, drawWidth, drawHeight);
  return canvas;
}

function renderCandidates() {
  elements.grid.innerHTML = "";
  candidates.forEach((candidate, index) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "candidate-card";
    button.addEventListener("click", () => selectCandidate(index));

    const canvas = document.createElement("canvas");
    canvas.width = candidate.canvas.width;
    canvas.height = candidate.canvas.height;
    canvas.getContext("2d").drawImage(candidate.canvas, 0, 0);

    const title = document.createElement("strong");
    title.textContent = elements.name.value;
    const meta = document.createElement("span");
    meta.textContent = candidate.file_name || `Candidate ${index + 1}`;

    button.append(canvas, title, meta);
    elements.grid.append(button);
  });
  elements.count.textContent = `${candidates.length} sprites`;
  if (candidates.length === 0) {
    addEmptyState();
  }
}

function addEmptyState() {
  elements.grid.innerHTML = `<p class="empty-note">No candidates imported.</p>`;
  elements.count.textContent = "0 sprites";
}

function selectCandidate(index) {
  selectedIndex = index;
  elements.grid.querySelectorAll(".candidate-card").forEach((card, cardIndex) => {
    card.classList.toggle("selected", cardIndex === index);
  });
  drawPreview();
  updateMetadata();
}

function drawPreview(flash = false) {
  const context = elements.preview.getContext("2d");
  context.clearRect(0, 0, elements.preview.width, elements.preview.height);
  context.imageSmoothingEnabled = false;

  const biome = BIOME_PRESENTATION[elements.biome.value];
  elements.stage.style.setProperty("--biome-gradient", biome.gradient);

  if (!hasSelection()) {
    drawPreviewPlaceholder(context);
    return;
  }

  const candidate = candidates[selectedIndex];
  const spriteSize = candidate.canvas.width;
  const scale = elements.type.value === "boss" ? 5.2 : elements.type.value === "elite" ? 4.7 : 4.25;
  const drawSize = Math.round(spriteSize * scale);
  const x = Math.round((elements.preview.width - drawSize) / 2);
  const y = Math.round(elements.preview.height - drawSize - 34);
  context.drawImage(candidate.canvas, x, y, drawSize, drawSize);

  if (flash) {
    context.globalCompositeOperation = "source-atop";
    context.fillStyle = "rgba(255, 255, 255, 0.78)";
    context.fillRect(x, y, drawSize, drawSize);
    context.globalCompositeOperation = "source-over";
  }
}

function drawPreviewPlaceholder(context) {
  context.fillStyle = "rgba(255,255,255,0.18)";
  context.fillRect(104, 108, 48, 72);
  context.fillStyle = "rgba(119,217,208,0.5)";
  context.fillRect(116, 126, 6, 4);
  context.fillRect(135, 126, 6, 4);
  elements.selectedLabel.textContent = "Import candidates";
}

function previewHit() {
  elements.preview.classList.remove("hit");
  drawPreview(true);
  window.setTimeout(() => {
    elements.preview.classList.add("hit");
    drawPreview(false);
  }, 20);
}

function metadata() {
  const selected = hasSelection() ? candidates[selectedIndex] : {};
  const name = elements.name.value;
  const type = elements.type.value;
  const biome = elements.biome.value;
  const size = Number(elements.size.value);
  return {
    tool: "Enemy Lab",
    model_version: "enemy_lab.chatgpt_sprite.v1",
    display_name: name,
    enemy_type: type,
    biome,
    sprite_size: size,
    transparent_background: true,
    source_file: selected.file_name || "",
    source_size: selected.source_width && selected.source_height ? `${selected.source_width}x${selected.source_height}` : "",
    png_path_hint: pathHint(name, type, biome),
    generation_prompt: elements.prompt.value,
    godot_animation: {
      damage: "runtime flash with small impact movement",
      flash_duration_ms: 420,
      impact_offset_px: 5,
      preferred_implementation: "Sprite2D modulate/self_modulate tween; optional white-mask material, no baked hit frames required",
    },
  };
}

function updateMetadata() {
  const data = metadata();
  elements.selectedLabel.textContent = hasSelection()
    ? `${data.display_name} · ${TYPE_LABELS[data.enemy_type]}`
    : "Import candidates";
  elements.pathHint.value = data.png_path_hint;
  elements.metadata.value = JSON.stringify(data, null, 2);
}

function pathHint(name, type, biome) {
  return `project/assets/generated/enemies/${slug(biome)}/${type}/${slug(name)}.png`;
}

function exportSelectedPng() {
  if (!hasSelection()) {
    return;
  }
  const data = metadata();
  downloadCanvas(candidates[selectedIndex].canvas, `${slug(data.biome)}_${data.enemy_type}_${slug(data.display_name)}.png`);
}

function exportSelectedJson() {
  const data = metadata();
  downloadText(
    JSON.stringify(data, null, 2),
    `${slug(data.biome)}_${data.enemy_type}_${slug(data.display_name)}.json`,
    "application/json",
  );
}

function exportWhiteMask() {
  if (!hasSelection()) {
    return;
  }
  const source = candidates[selectedIndex].canvas;
  const mask = document.createElement("canvas");
  mask.width = source.width;
  mask.height = source.height;
  const context = mask.getContext("2d");
  context.drawImage(source, 0, 0);
  const image = context.getImageData(0, 0, mask.width, mask.height);
  for (let index = 0; index < image.data.length; index += 4) {
    if (image.data[index + 3] === 0) {
      continue;
    }
    image.data[index] = 255;
    image.data[index + 1] = 255;
    image.data[index + 2] = 255;
  }
  context.putImageData(image, 0, 0);
  const data = metadata();
  downloadCanvas(mask, `${slug(data.biome)}_${data.enemy_type}_${slug(data.display_name)}_white_mask.png`);
}

async function copyMetadata() {
  await writeClipboard(elements.metadata.value, elements.metadata);
}

function hasSelection() {
  return selectedIndex >= 0 && selectedIndex < candidates.length;
}

function loadImage(file) {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.onload = () => {
      URL.revokeObjectURL(image.src);
      resolve(image);
    };
    image.onerror = reject;
    image.src = URL.createObjectURL(file);
  });
}

async function writeClipboard(text, fallbackElement) {
  if (navigator.clipboard) {
    try {
      await navigator.clipboard.writeText(text);
      return;
    } catch (_error) {
      // File URLs can deny clipboard writes; selection still gives a quick manual fallback.
    }
  }
  fallbackElement.focus();
  fallbackElement.select();
}

function downloadCanvas(canvas, filename) {
  const link = document.createElement("a");
  link.download = filename;
  link.href = canvas.toDataURL("image/png");
  link.click();
}

function downloadText(text, filename, type) {
  const blob = new Blob([text], { type });
  const link = document.createElement("a");
  link.download = filename;
  link.href = URL.createObjectURL(blob);
  link.click();
  URL.revokeObjectURL(link.href);
}

function slug(value) {
  return String(value)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
}

init();
