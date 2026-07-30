const state = {
  sheets: [],
  activeSheetId: null,
  image: null,
  imageName: "",
  imageUrl: "",
  frames: [],
  selectedFrameIds: [],
  animations: [],
  selectedFrameId: null,
  selectedAnimIndex: 0,
  selectedTimelineIndex: -1,
  tool: "select",
  zoom: 3,
  dragging: null,
  playing: false,
  previewCursor: 0,
  lastPreviewTime: 0,
  undoStack: [],
  redoStack: [],
  playbackScale: 1,
  lastFrameListIndex: -1,
};

const el = {
  sheetInput: document.getElementById("sheetInput"),
  sheetTabs: document.getElementById("sheetTabs"),
  dropZone: document.getElementById("dropZone"),
  sheetMeta: document.getElementById("sheetMeta"),
  sheetCanvas: document.getElementById("sheetCanvas"),
  previewCanvas: document.getElementById("previewCanvas"),
  frameList: document.getElementById("frameList"),
  timeline: document.getElementById("timeline"),
  animationSelect: document.getElementById("animationSelect"),
  toolSelect: document.getElementById("toolSelect"),
  toolDraw: document.getElementById("toolDraw"),
  toolPivot: document.getElementById("toolPivot"),
  zoomRange: document.getElementById("zoomRange"),
  showGrid: document.getElementById("showGrid"),
  showPivots: document.getElementById("showPivots"),
  gridWidth: document.getElementById("gridWidth"),
  gridHeight: document.getElementById("gridHeight"),
  gridMarginX: document.getElementById("gridMarginX"),
  gridMarginY: document.getElementById("gridMarginY"),
  gridSpacingX: document.getElementById("gridSpacingX"),
  gridSpacingY: document.getElementById("gridSpacingY"),
  alphaThreshold: document.getElementById("alphaThreshold"),
  minArea: document.getElementById("minArea"),
  detectPadding: document.getElementById("detectPadding"),
  frameName: document.getElementById("frameName"),
  frameX: document.getElementById("frameX"),
  frameY: document.getElementById("frameY"),
  frameW: document.getElementById("frameW"),
  frameH: document.getElementById("frameH"),
  pivotX: document.getElementById("pivotX"),
  pivotY: document.getElementById("pivotY"),
  frameDuration: document.getElementById("frameDuration"),
  bulkMeta: document.getElementById("bulkMeta"),
  bulkPrefix: document.getElementById("bulkPrefix"),
  animationName: document.getElementById("animationName"),
  fpsInput: document.getElementById("fpsInput"),
  loopInput: document.getElementById("loopInput"),
  speedRange: document.getElementById("speedRange"),
  speedValue: document.getElementById("speedValue"),
  exportName: document.getElementById("exportName"),
  exportScale: document.getElementById("exportScale"),
};

const sheetCtx = el.sheetCanvas.getContext("2d");
const previewCtx = el.previewCanvas.getContext("2d");

function uid(prefix) {
  return `${prefix}_${Math.random().toString(36).slice(2, 9)}`;
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function selectedFrame() {
  return state.frames.find((frame) => frame.id === state.selectedFrameId) || null;
}

function selectedFrames() {
  return state.selectedFrameIds
    .map((id) => state.frames.find((frame) => frame.id === id))
    .filter(Boolean);
}

function selectedAnimation() {
  return state.animations[state.selectedAnimIndex] || null;
}

function safeName(value, fallback = "asset") {
  return (value || fallback)
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9_ -]/g, "")
    .replace(/\s+/g, "_")
    .replace(/_+/g, "_") || fallback;
}

function createAnimation(name) {
  return { id: uid("anim"), name, frames: [], fps: 8, loop: true };
}

function createEmptySheet(name) {
  const sheet = {
    id: uid("sheet"),
    name,
    image: null,
    imageName: "",
    imageUrl: "",
    frames: [],
    animations: [createAnimation("idle")],
    selectedFrameId: null,
    selectedFrameIds: [],
    selectedAnimIndex: 0,
    selectedTimelineIndex: -1,
    undoStack: [],
    redoStack: [],
  };
  state.sheets.push(sheet);
  switchSheet(sheet.id);
  return sheet;
}

function activeSheet() {
  return state.sheets.find((sheet) => sheet.id === state.activeSheetId) || null;
}

function syncStateToSheet() {
  const sheet = activeSheet();
  if (!sheet) return;
  sheet.image = state.image;
  sheet.imageName = state.imageName;
  sheet.imageUrl = state.imageUrl;
  sheet.frames = state.frames;
  sheet.animations = state.animations;
  sheet.selectedFrameId = state.selectedFrameId;
  sheet.selectedFrameIds = state.selectedFrameIds;
  sheet.selectedAnimIndex = state.selectedAnimIndex;
  sheet.selectedTimelineIndex = state.selectedTimelineIndex;
  sheet.undoStack = state.undoStack;
  sheet.redoStack = state.redoStack;
}

function switchSheet(sheetId) {
  syncStateToSheet();
  const sheet = state.sheets.find((item) => item.id === sheetId);
  if (!sheet) return;
  state.activeSheetId = sheet.id;
  state.image = sheet.image;
  state.imageName = sheet.imageName;
  state.imageUrl = sheet.imageUrl;
  state.frames = sheet.frames;
  state.animations = sheet.animations;
  state.selectedFrameId = sheet.selectedFrameId;
  state.selectedFrameIds = sheet.selectedFrameIds || [];
  state.selectedAnimIndex = sheet.selectedAnimIndex;
  state.selectedTimelineIndex = sheet.selectedTimelineIndex;
  state.undoStack = sheet.undoStack || [];
  state.redoStack = sheet.redoStack || [];
  if (state.imageName) el.exportName.value = safeName(state.imageName, "sprite_lab_export");
  resizeSheetCanvas();
  renderAll();
}

function updateActiveSheetName(name) {
  const sheet = activeSheet();
  if (!sheet) return;
  sheet.name = name || "Untitled";
}

function snapshotCurrent() {
  return {
    frames: structuredClone(state.frames),
    animations: structuredClone(state.animations),
    selectedFrameId: state.selectedFrameId,
    selectedFrameIds: [...state.selectedFrameIds],
    selectedAnimIndex: state.selectedAnimIndex,
    selectedTimelineIndex: state.selectedTimelineIndex,
  };
}

function restoreSnapshot(snapshot) {
  state.frames = structuredClone(snapshot.frames);
  state.animations = structuredClone(snapshot.animations);
  state.selectedFrameId = snapshot.selectedFrameId;
  state.selectedFrameIds = [...snapshot.selectedFrameIds];
  state.selectedAnimIndex = snapshot.selectedAnimIndex;
  state.selectedTimelineIndex = snapshot.selectedTimelineIndex;
  syncStateToSheet();
  renderAll();
}

function pushUndo() {
  state.undoStack.push(snapshotCurrent());
  if (state.undoStack.length > 80) state.undoStack.shift();
  state.redoStack = [];
  syncStateToSheet();
}

function undo() {
  if (!state.undoStack.length) return;
  state.redoStack.push(snapshotCurrent());
  restoreSnapshot(state.undoStack.pop());
}

function redo() {
  if (!state.redoStack.length) return;
  state.undoStack.push(snapshotCurrent());
  restoreSnapshot(state.redoStack.pop());
}

function init() {
  state.animations = [createAnimation("idle")];
  createEmptySheet("Untitled");
  bindEvents();
  renderAll();
  requestAnimationFrame(previewLoop);
}

function bindEvents() {
  el.sheetInput.addEventListener("change", (event) => {
    const file = event.target.files[0];
    if (file) loadImageFile(file);
  });

  ["dragenter", "dragover"].forEach((name) => {
    el.dropZone.addEventListener(name, (event) => {
      event.preventDefault();
      el.dropZone.classList.add("dragging");
    });
  });

  ["dragleave", "drop"].forEach((name) => {
    el.dropZone.addEventListener(name, (event) => {
      event.preventDefault();
      el.dropZone.classList.remove("dragging");
    });
  });

  el.dropZone.addEventListener("drop", (event) => {
    const file = event.dataTransfer.files[0];
    if (file) loadImageFile(file);
  });

  document.getElementById("sliceGridButton").addEventListener("click", sliceGrid);
  document.getElementById("detectButton").addEventListener("click", detectSprites);
  document.getElementById("addFrameButton").addEventListener("click", addBlankFrame);
  document.getElementById("duplicateFrameButton").addEventListener("click", duplicateFrame);
  document.getElementById("deleteFrameButton").addEventListener("click", deleteSelectedFrame);
  document.getElementById("sameSizeButton").addEventListener("click", () => unifySelected("size"));
  document.getElementById("samePivotButton").addEventListener("click", () => unifySelected("pivot"));
  document.getElementById("samePositionButton").addEventListener("click", () => unifySelected("position"));
  document.getElementById("sameDurationButton").addEventListener("click", () => unifySelected("duration"));
  document.getElementById("renameSelectedButton").addEventListener("click", renameSelectedFrames);
  document.getElementById("addAnimationButton").addEventListener("click", addAnimation);
  document.getElementById("addToAnimationButton").addEventListener("click", addFrameToAnimation);
  document.getElementById("removeAnimFrameButton").addEventListener("click", removeTimelineFrame);
  document.getElementById("playButton").addEventListener("click", togglePlayback);
  document.getElementById("exportButton").addEventListener("click", exportZip);

  [el.showGrid, el.showPivots].forEach((input) => input.addEventListener("change", drawSheet));
  el.zoomRange.addEventListener("input", () => {
    state.zoom = Number(el.zoomRange.value);
    resizeSheetCanvas();
  });

  [el.toolSelect, el.toolDraw, el.toolPivot].forEach((button) => {
    button.addEventListener("click", () => setTool(button.id.replace("tool", "").toLowerCase()));
  });

  [el.frameName, el.frameX, el.frameY, el.frameW, el.frameH, el.pivotX, el.pivotY, el.frameDuration].forEach((input) => {
    input.addEventListener("focus", () => {
      if (selectedFrame()) pushUndo();
    });
    input.addEventListener("input", updateSelectedFrameFromInputs);
  });

  el.animationSelect.addEventListener("change", () => {
    state.selectedAnimIndex = Number(el.animationSelect.value);
    state.selectedTimelineIndex = -1;
    const animation = selectedAnimation();
    if (animation) {
      el.fpsInput.value = animation.fps;
      el.loopInput.checked = animation.loop;
    }
    renderAnimationPanel();
  });

  el.fpsInput.addEventListener("input", () => {
    const animation = selectedAnimation();
    if (animation) animation.fps = clamp(Number(el.fpsInput.value) || 1, 1, 60);
  });

  el.loopInput.addEventListener("change", () => {
    const animation = selectedAnimation();
    pushUndo();
    if (animation) animation.loop = el.loopInput.checked;
  });

  el.speedRange.addEventListener("input", () => {
    state.playbackScale = Number(el.speedRange.value) || 1;
    el.speedValue.textContent = `${state.playbackScale.toFixed(1)}x`;
  });

  el.sheetCanvas.addEventListener("pointerdown", pointerDown);
  el.sheetCanvas.addEventListener("pointermove", pointerMove);
  window.addEventListener("pointerup", pointerUp);

  window.addEventListener("keydown", (event) => {
    if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === "z") {
      event.preventDefault();
      if (event.shiftKey) redo();
      else undo();
      return;
    }
    if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === "y") {
      event.preventDefault();
      redo();
      return;
    }
    if (["INPUT", "SELECT"].includes(document.activeElement.tagName)) return;
    const frame = selectedFrame();
    if (!frame) return;
    const step = event.shiftKey ? 8 : 1;
    if (event.key === "Delete") deleteSelectedFrame();
    if (event.key === " ") {
      event.preventDefault();
      togglePlayback();
    }
    if (["ArrowLeft", "ArrowRight", "ArrowUp", "ArrowDown"].includes(event.key)) {
      event.preventDefault();
      pushUndo();
      if (state.tool === "pivot") {
        frame.pivotX += event.key === "ArrowLeft" ? -step : event.key === "ArrowRight" ? step : 0;
        frame.pivotY += event.key === "ArrowUp" ? -step : event.key === "ArrowDown" ? step : 0;
      } else {
        frame.x += event.key === "ArrowLeft" ? -step : event.key === "ArrowRight" ? step : 0;
        frame.y += event.key === "ArrowUp" ? -step : event.key === "ArrowDown" ? step : 0;
      }
      normalizeFrame(frame);
      renderAll();
    }
  });
}

function setTool(tool) {
  state.tool = tool;
  el.toolSelect.classList.toggle("active", tool === "select");
  el.toolDraw.classList.toggle("active", tool === "draw");
  el.toolPivot.classList.toggle("active", tool === "pivot");
}

function loadImageFile(file) {
  const url = URL.createObjectURL(file);
  const image = new Image();
  image.onload = () => {
    if (state.image) createEmptySheet(file.name.replace(/\.[^.]+$/, ""));
    state.image = image;
    state.imageUrl = url;
    state.imageName = file.name.replace(/\.[^.]+$/, "");
    updateActiveSheetName(state.imageName);
    el.exportName.value = safeName(state.imageName, "sprite_lab_export");
    state.frames = [];
    state.selectedFrameIds = [];
    state.selectedFrameId = null;
    state.selectedTimelineIndex = -1;
    state.animations = [createAnimation("idle")];
    state.selectedAnimIndex = 0;
    state.undoStack = [];
    state.redoStack = [];
    el.sheetMeta.textContent = `${file.name} · ${image.width} x ${image.height}`;
    syncStateToSheet();
    resizeSheetCanvas();
    renderAll();
  };
  image.src = url;
}

function resizeSheetCanvas() {
  if (!state.image) {
    el.sheetCanvas.width = 960;
    el.sheetCanvas.height = 540;
  } else {
    el.sheetCanvas.width = state.image.width * state.zoom;
    el.sheetCanvas.height = state.image.height * state.zoom;
  }
  drawSheet();
}

function drawSheet() {
  sheetCtx.imageSmoothingEnabled = false;
  sheetCtx.clearRect(0, 0, el.sheetCanvas.width, el.sheetCanvas.height);
  if (!state.image) {
    sheetCtx.fillStyle = "#aeb6bf";
    sheetCtx.font = "18px sans-serif";
    sheetCtx.fillText("Import a sprite sheet to begin.", 28, 42);
    return;
  }

  const z = state.zoom;
  sheetCtx.drawImage(state.image, 0, 0, state.image.width * z, state.image.height * z);

  if (el.showGrid.checked) {
    state.frames.forEach((frame, index) => {
      const selected = frame.id === state.selectedFrameId;
      sheetCtx.strokeStyle = selected ? "#f2c14e" : "#58c4b6";
      sheetCtx.lineWidth = selected ? 3 : 1;
      sheetCtx.strokeRect(frame.x * z + 0.5, frame.y * z + 0.5, frame.w * z, frame.h * z);
      sheetCtx.fillStyle = selected ? "#f2c14e" : "#58c4b6";
      sheetCtx.fillRect(frame.x * z, Math.max(0, frame.y * z - 18), 26, 16);
      sheetCtx.fillStyle = "#111316";
      sheetCtx.font = "11px sans-serif";
      sheetCtx.fillText(String(index + 1), frame.x * z + 4, Math.max(12, frame.y * z - 6));
    });
  }

  if (el.showPivots.checked) {
    state.frames.forEach((frame) => {
      const x = (frame.x + frame.pivotX) * z;
      const y = (frame.y + frame.pivotY) * z;
      sheetCtx.strokeStyle = frame.id === state.selectedFrameId ? "#ee6c4d" : "#f2c14e";
      sheetCtx.lineWidth = 1;
      sheetCtx.beginPath();
      sheetCtx.moveTo(x - 7, y);
      sheetCtx.lineTo(x + 7, y);
      sheetCtx.moveTo(x, y - 7);
      sheetCtx.lineTo(x, y + 7);
      sheetCtx.stroke();
    });
  }
}

function sliceGrid() {
  if (!state.image) return;
  pushUndo();
  const cellW = Number(el.gridWidth.value) || 1;
  const cellH = Number(el.gridHeight.value) || 1;
  const marginX = Number(el.gridMarginX.value) || 0;
  const marginY = Number(el.gridMarginY.value) || 0;
  const spacingX = Number(el.gridSpacingX.value) || 0;
  const spacingY = Number(el.gridSpacingY.value) || 0;
  const frames = [];
  let index = 1;

  for (let y = marginY; y + cellH <= state.image.height; y += cellH + spacingY) {
    for (let x = marginX; x + cellW <= state.image.width; x += cellW + spacingX) {
      frames.push(createFrame(`frame_${String(index).padStart(3, "0")}`, x, y, cellW, cellH));
      index += 1;
    }
  }

  state.frames = frames;
  state.selectedFrameId = frames[0]?.id || null;
  state.selectedFrameIds = state.selectedFrameId ? [state.selectedFrameId] : [];
  renderAll();
}

function detectSprites() {
  if (!state.image) return;
  pushUndo();
  const threshold = Number(el.alphaThreshold.value) || 1;
  const minArea = Number(el.minArea.value) || 1;
  const padding = Number(el.detectPadding.value) || 0;
  const temp = document.createElement("canvas");
  temp.width = state.image.width;
  temp.height = state.image.height;
  const ctx = temp.getContext("2d", { willReadFrequently: true });
  ctx.drawImage(state.image, 0, 0);
  const data = ctx.getImageData(0, 0, temp.width, temp.height).data;
  const visited = new Uint8Array(temp.width * temp.height);
  const frames = [];
  let index = 1;

  for (let y = 0; y < temp.height; y += 1) {
    for (let x = 0; x < temp.width; x += 1) {
      const start = y * temp.width + x;
      if (visited[start] || data[start * 4 + 3] < threshold) continue;
      const box = floodBox(x, y, temp.width, temp.height, data, visited, threshold);
      const area = box.count;
      if (area < minArea) continue;
      const padded = {
        x: clamp(box.minX - padding, 0, temp.width - 1),
        y: clamp(box.minY - padding, 0, temp.height - 1),
        w: clamp(box.maxX - box.minX + 1 + padding * 2, 1, temp.width),
        h: clamp(box.maxY - box.minY + 1 + padding * 2, 1, temp.height),
      };
      padded.w = Math.min(padded.w, temp.width - padded.x);
      padded.h = Math.min(padded.h, temp.height - padded.y);
      frames.push(createFrame(`sprite_${String(index).padStart(3, "0")}`, padded.x, padded.y, padded.w, padded.h));
      index += 1;
    }
  }

  frames.sort((a, b) => a.y - b.y || a.x - b.x);
  state.frames = frames;
  state.selectedFrameId = frames[0]?.id || null;
  state.selectedFrameIds = state.selectedFrameId ? [state.selectedFrameId] : [];
  renderAll();
}

function floodBox(x, y, width, height, data, visited, threshold) {
  const stack = [[x, y]];
  const box = { minX: x, minY: y, maxX: x, maxY: y, count: 0 };
  while (stack.length) {
    const [cx, cy] = stack.pop();
    if (cx < 0 || cy < 0 || cx >= width || cy >= height) continue;
    const index = cy * width + cx;
    if (visited[index]) continue;
    visited[index] = 1;
    if (data[index * 4 + 3] < threshold) continue;

    box.minX = Math.min(box.minX, cx);
    box.minY = Math.min(box.minY, cy);
    box.maxX = Math.max(box.maxX, cx);
    box.maxY = Math.max(box.maxY, cy);
    box.count += 1;

    stack.push([cx + 1, cy]);
    stack.push([cx - 1, cy]);
    stack.push([cx, cy + 1]);
    stack.push([cx, cy - 1]);
  }
  return box;
}

function createFrame(name, x, y, w, h) {
  return {
    id: uid("frame"),
    name,
    x: Math.round(x),
    y: Math.round(y),
    w: Math.max(1, Math.round(w)),
    h: Math.max(1, Math.round(h)),
    pivotX: Math.round(w / 2),
    pivotY: Math.round(h),
    duration: 100,
  };
}

function addBlankFrame() {
  if (!state.image) return;
  pushUndo();
  const frame = createFrame(`frame_${String(state.frames.length + 1).padStart(3, "0")}`, 0, 0, Number(el.gridWidth.value) || 32, Number(el.gridHeight.value) || 32);
  normalizeFrame(frame);
  state.frames.push(frame);
  state.selectedFrameId = frame.id;
  state.selectedFrameIds = [frame.id];
  renderAll();
}

function duplicateFrame() {
  const frame = selectedFrame();
  if (!frame) return;
  pushUndo();
  const copy = { ...frame, id: uid("frame"), name: `${frame.name}_copy`, x: frame.x + 4, y: frame.y + 4 };
  normalizeFrame(copy);
  state.frames.push(copy);
  state.selectedFrameId = copy.id;
  state.selectedFrameIds = [copy.id];
  renderAll();
}

function deleteSelectedFrame() {
  const ids = state.selectedFrameIds.length ? state.selectedFrameIds : [state.selectedFrameId];
  if (!ids.length) return;
  pushUndo();
  state.frames = state.frames.filter((item) => !ids.includes(item.id));
  state.animations.forEach((animation) => {
    animation.frames = animation.frames.filter((item) => !ids.includes(item.frameId));
  });
  state.selectedFrameId = state.frames[0]?.id || null;
  state.selectedFrameIds = state.selectedFrameId ? [state.selectedFrameId] : [];
  state.selectedTimelineIndex = -1;
  renderAll();
}

function normalizeFrame(frame) {
  if (!state.image) return;
  frame.w = Math.max(1, Math.round(frame.w));
  frame.h = Math.max(1, Math.round(frame.h));
  frame.x = clamp(Math.round(frame.x), 0, Math.max(0, state.image.width - frame.w));
  frame.y = clamp(Math.round(frame.y), 0, Math.max(0, state.image.height - frame.h));
  frame.pivotX = Math.round(frame.pivotX);
  frame.pivotY = Math.round(frame.pivotY);
  frame.duration = Math.max(1, Math.round(frame.duration || 100));
}

function updateSelectedFrameFromInputs() {
  const frame = selectedFrame();
  if (!frame) return;
  frame.name = el.frameName.value || frame.name;
  frame.x = Number(el.frameX.value) || 0;
  frame.y = Number(el.frameY.value) || 0;
  frame.w = Number(el.frameW.value) || 1;
  frame.h = Number(el.frameH.value) || 1;
  frame.pivotX = Number(el.pivotX.value) || 0;
  frame.pivotY = Number(el.pivotY.value) || 0;
  frame.duration = Number(el.frameDuration.value) || 100;
  normalizeFrame(frame);
  syncStateToSheet();
  drawSheet();
  syncBulkMeta();
  renderFrameList();
  drawPreview();
}

function addAnimation() {
  const name = safeName(el.animationName.value, `animation_${state.animations.length + 1}`);
  pushUndo();
  state.animations.push({ ...createAnimation(name), fps: Number(el.fpsInput.value) || 8 });
  state.selectedAnimIndex = state.animations.length - 1;
  renderAnimationPanel();
}

function addFrameToAnimation() {
  const frame = selectedFrame();
  const animation = selectedAnimation();
  if (!frame || !animation) return;
  pushUndo();
  animation.frames.push({ frameId: frame.id, duration: frame.duration });
  state.selectedTimelineIndex = animation.frames.length - 1;
  renderAnimationPanel();
}

function removeTimelineFrame() {
  const animation = selectedAnimation();
  if (!animation || state.selectedTimelineIndex < 0) return;
  pushUndo();
  animation.frames.splice(state.selectedTimelineIndex, 1);
  state.selectedTimelineIndex = Math.min(state.selectedTimelineIndex, animation.frames.length - 1);
  renderAnimationPanel();
}

function togglePlayback() {
  state.playing = !state.playing;
  document.getElementById("playButton").textContent = state.playing ? "Pause" : "Play";
  state.lastPreviewTime = performance.now();
}

function renderAll() {
  syncStateToSheet();
  renderSheetTabs();
  drawSheet();
  syncFrameInputs();
  syncBulkMeta();
  renderFrameList();
  renderAnimationPanel();
  drawPreview();
}

function renderSheetTabs() {
  el.sheetTabs.textContent = "";
  state.sheets.forEach((sheet) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = `sheet-tab${sheet.id === state.activeSheetId ? " active" : ""}`;
    button.textContent = sheet.name || "Untitled";
    button.title = sheet.name || "Untitled";
    button.addEventListener("click", () => switchSheet(sheet.id));
    el.sheetTabs.appendChild(button);
  });
  if (state.image) {
    el.sheetMeta.textContent = `${state.imageName || "Sheet"} · ${state.image.width} x ${state.image.height}`;
  } else {
    el.sheetMeta.textContent = "No sheet loaded.";
  }
}

function syncFrameInputs() {
  const frame = selectedFrame();
  [el.frameName, el.frameX, el.frameY, el.frameW, el.frameH, el.pivotX, el.pivotY, el.frameDuration].forEach((input) => input.disabled = !frame);
  if (!frame) {
    el.frameName.value = "";
    el.frameX.value = "";
    el.frameY.value = "";
    el.frameW.value = "";
    el.frameH.value = "";
    el.pivotX.value = "";
    el.pivotY.value = "";
    el.frameDuration.value = "";
    return;
  }
  el.frameName.value = frame.name;
  el.frameX.value = frame.x;
  el.frameY.value = frame.y;
  el.frameW.value = frame.w;
  el.frameH.value = frame.h;
  el.pivotX.value = frame.pivotX;
  el.pivotY.value = frame.pivotY;
  el.frameDuration.value = frame.duration;
}

function syncBulkMeta() {
  const count = selectedFrames().length;
  el.bulkMeta.textContent = count > 1
    ? `${count} frames selected. Batch tools copy values from the active frame.`
    : "Select multiple frames with Ctrl/Shift.";
}

function selectFrame(frameId, event = {}) {
  const index = state.frames.findIndex((frame) => frame.id === frameId);
  if (index < 0) return;
  if (event.shiftKey && state.lastFrameListIndex >= 0) {
    const start = Math.min(state.lastFrameListIndex, index);
    const end = Math.max(state.lastFrameListIndex, index);
    state.selectedFrameIds = state.frames.slice(start, end + 1).map((frame) => frame.id);
  } else if (event.ctrlKey || event.metaKey) {
    if (state.selectedFrameIds.includes(frameId)) {
      state.selectedFrameIds = state.selectedFrameIds.filter((id) => id !== frameId);
    } else {
      state.selectedFrameIds = [...state.selectedFrameIds, frameId];
    }
  } else {
    state.selectedFrameIds = [frameId];
  }
  state.selectedFrameId = frameId;
  state.lastFrameListIndex = index;
  syncStateToSheet();
}

function unifySelected(kind) {
  const source = selectedFrame();
  const frames = selectedFrames().filter((frame) => frame.id !== source?.id);
  if (!source || !frames.length) return;
  pushUndo();
  frames.forEach((frame) => {
    if (kind === "size") {
      frame.w = source.w;
      frame.h = source.h;
    }
    if (kind === "pivot") {
      frame.pivotX = source.pivotX;
      frame.pivotY = source.pivotY;
    }
    if (kind === "position") {
      frame.x = source.x;
      frame.y = source.y;
    }
    if (kind === "duration") frame.duration = source.duration;
    normalizeFrame(frame);
  });
  renderAll();
}

function renameSelectedFrames() {
  const frames = selectedFrames();
  if (!frames.length) return;
  pushUndo();
  const prefix = safeName(el.bulkPrefix.value, "frame");
  frames.forEach((frame, index) => {
    frame.name = `${prefix}_${String(index + 1).padStart(3, "0")}`;
  });
  renderAll();
}

function renderFrameList() {
  el.frameList.textContent = "";
  state.frames.forEach((frame, index) => {
    const item = document.createElement("button");
    item.type = "button";
    item.className = `frame-item${frame.id === state.selectedFrameId ? " selected" : ""}${state.selectedFrameIds.includes(frame.id) ? " multi-selected" : ""}`;
    item.innerHTML = `
      <img class="thumb" alt="" src="${frameDataUrl(frame)}">
      <span class="frame-label">${frame.name}</span>
      <span class="frame-detail">${frame.w}x${frame.h}</span>
    `;
    item.addEventListener("click", (event) => {
      selectFrame(frame.id, event);
      syncFrameInputs();
      syncBulkMeta();
      renderFrameList();
      drawSheet();
      drawPreview();
    });
    item.draggable = true;
    item.addEventListener("dragstart", (event) => event.dataTransfer.setData("text/plain", String(index)));
    item.addEventListener("dragover", (event) => event.preventDefault());
    item.addEventListener("drop", (event) => {
      event.preventDefault();
      pushUndo();
      const from = Number(event.dataTransfer.getData("text/plain"));
      const [moved] = state.frames.splice(from, 1);
      state.frames.splice(index, 0, moved);
      renderAll();
    });
    el.frameList.appendChild(item);
  });
}

function renderAnimationPanel() {
  el.animationSelect.textContent = "";
  state.animations.forEach((animation, index) => {
    const option = document.createElement("option");
    option.value = String(index);
    option.textContent = `${animation.name} (${animation.frames.length})`;
    option.selected = index === state.selectedAnimIndex;
    el.animationSelect.appendChild(option);
  });

  const animation = selectedAnimation();
  if (animation) {
    el.fpsInput.value = animation.fps;
    el.loopInput.checked = animation.loop;
  }

  el.timeline.textContent = "";
  if (!animation) return;
  animation.frames.forEach((step, index) => {
    const frame = state.frames.find((item) => item.id === step.frameId);
    const item = document.createElement("button");
    item.type = "button";
    item.className = `timeline-item${state.selectedTimelineIndex === index ? " selected" : ""}`;
    item.innerHTML = `
      <img class="thumb" alt="" src="${frame ? frameDataUrl(frame) : ""}">
      <span class="frame-label">${frame ? frame.name : "Missing frame"}</span>
      <span class="frame-detail">${step.duration}ms</span>
    `;
    item.addEventListener("click", () => {
      state.selectedTimelineIndex = index;
      if (frame) {
        state.selectedFrameId = frame.id;
        state.selectedFrameIds = [frame.id];
      }
      renderAll();
    });
    item.draggable = true;
    item.addEventListener("dragstart", (event) => event.dataTransfer.setData("text/plain", String(index)));
    item.addEventListener("dragover", (event) => event.preventDefault());
    item.addEventListener("drop", (event) => {
      event.preventDefault();
      pushUndo();
      const from = Number(event.dataTransfer.getData("text/plain"));
      const [moved] = animation.frames.splice(from, 1);
      animation.frames.splice(index, 0, moved);
      state.selectedTimelineIndex = index;
      renderAnimationPanel();
    });
    el.timeline.appendChild(item);
  });
}

function frameDataUrl(frame, scale = 1) {
  if (!state.image || !frame) return "";
  const canvas = document.createElement("canvas");
  canvas.width = frame.w * scale;
  canvas.height = frame.h * scale;
  const ctx = canvas.getContext("2d");
  ctx.imageSmoothingEnabled = false;
  ctx.drawImage(state.image, frame.x, frame.y, frame.w, frame.h, 0, 0, canvas.width, canvas.height);
  return canvas.toDataURL("image/png");
}

function pointerPosition(event) {
  const rect = el.sheetCanvas.getBoundingClientRect();
  return {
    x: Math.floor((event.clientX - rect.left) / state.zoom),
    y: Math.floor((event.clientY - rect.top) / state.zoom),
  };
}

function pointerDown(event) {
  if (!state.image) return;
  const pos = pointerPosition(event);
  if (state.tool === "draw") {
    pushUndo();
    const frame = createFrame(`frame_${String(state.frames.length + 1).padStart(3, "0")}`, pos.x, pos.y, 1, 1);
    state.frames.push(frame);
    state.selectedFrameId = frame.id;
    state.selectedFrameIds = [frame.id];
    state.dragging = { mode: "draw", startX: pos.x, startY: pos.y, frameId: frame.id };
    renderAll();
    return;
  }

  const tabHit = [...state.frames].reverse().find((frame, reversedIndex) => {
    const index = state.frames.length - 1 - reversedIndex;
    return pointInNumberTab(pos, frame, index);
  });
  const hit = tabHit || [...state.frames].reverse().find((frame) => pos.x >= frame.x && pos.x <= frame.x + frame.w && pos.y >= frame.y && pos.y <= frame.y + frame.h);
  if (!hit) return;
  selectFrame(hit.id, event);
  if (state.tool === "pivot") {
    pushUndo();
    hit.pivotX = pos.x - hit.x;
    hit.pivotY = pos.y - hit.y;
    state.dragging = { mode: "pivot", frameId: hit.id };
  } else {
    const edge = pos.x >= hit.x + hit.w - 3 || pos.y >= hit.y + hit.h - 3;
    if (tabHit || edge) {
      pushUndo();
      state.dragging = { mode: edge && !tabHit ? "resize" : "move", frameId: hit.id, offsetX: pos.x - hit.x, offsetY: pos.y - hit.y };
    }
  }
  renderAll();
}

function pointInNumberTab(pos, frame, index) {
  const labelWidth = Math.max(9, String(index + 1).length * 4 + 5);
  const tabY = Math.max(0, frame.y - Math.ceil(18 / state.zoom));
  return pos.x >= frame.x
    && pos.x <= frame.x + Math.ceil(labelWidth / state.zoom)
    && pos.y >= tabY
    && pos.y <= tabY + Math.ceil(16 / state.zoom);
}

function pointerMove(event) {
  if (!state.dragging || !state.image) return;
  const pos = pointerPosition(event);
  const frame = state.frames.find((item) => item.id === state.dragging.frameId);
  if (!frame) return;

  if (state.dragging.mode === "draw") {
    frame.x = Math.min(state.dragging.startX, pos.x);
    frame.y = Math.min(state.dragging.startY, pos.y);
    frame.w = Math.abs(pos.x - state.dragging.startX) + 1;
    frame.h = Math.abs(pos.y - state.dragging.startY) + 1;
    frame.pivotX = Math.round(frame.w / 2);
    frame.pivotY = frame.h;
  } else if (state.dragging.mode === "pivot") {
    frame.pivotX = pos.x - frame.x;
    frame.pivotY = pos.y - frame.y;
  } else if (state.dragging.mode === "resize") {
    frame.w = pos.x - frame.x + 1;
    frame.h = pos.y - frame.y + 1;
  } else {
    frame.x = pos.x - state.dragging.offsetX;
    frame.y = pos.y - state.dragging.offsetY;
  }

  normalizeFrame(frame);
  drawSheet();
  syncFrameInputs();
}

function pointerUp() {
  if (!state.dragging) return;
  state.dragging = null;
  renderAll();
}

function drawPreview() {
  previewCtx.imageSmoothingEnabled = false;
  previewCtx.clearRect(0, 0, el.previewCanvas.width, el.previewCanvas.height);
  previewCtx.strokeStyle = "#3a414a";
  previewCtx.beginPath();
  previewCtx.moveTo(0, Math.floor(el.previewCanvas.height * 0.72) + 0.5);
  previewCtx.lineTo(el.previewCanvas.width, Math.floor(el.previewCanvas.height * 0.72) + 0.5);
  previewCtx.stroke();

  const animation = selectedAnimation();
  let frame = selectedFrame();
  if (animation?.frames.length) {
    const step = animation.frames[state.previewCursor % animation.frames.length];
    frame = state.frames.find((item) => item.id === step.frameId) || frame;
  }
  if (!state.image || !frame) return;

  const scale = Math.max(1, Math.floor(Math.min(6, (el.previewCanvas.width * 0.55) / frame.w, (el.previewCanvas.height * 0.65) / frame.h)));
  const originX = Math.floor(el.previewCanvas.width / 2);
  const originY = Math.floor(el.previewCanvas.height * 0.72);
  const dx = originX - frame.pivotX * scale;
  const dy = originY - frame.pivotY * scale;
  previewCtx.drawImage(state.image, frame.x, frame.y, frame.w, frame.h, dx, dy, frame.w * scale, frame.h * scale);
  previewCtx.strokeStyle = "#ee6c4d";
  previewCtx.beginPath();
  previewCtx.moveTo(originX - 7, originY);
  previewCtx.lineTo(originX + 7, originY);
  previewCtx.moveTo(originX, originY - 7);
  previewCtx.lineTo(originX, originY + 7);
  previewCtx.stroke();
}

function previewLoop(now) {
  const animation = selectedAnimation();
  if (state.playing && animation?.frames.length) {
    const step = animation.frames[state.previewCursor % animation.frames.length];
    const frameMs = (step.duration || 1000 / Math.max(1, animation.fps)) / Math.max(0.1, state.playbackScale);
    if (now - state.lastPreviewTime >= frameMs) {
      state.previewCursor += 1;
      if (state.previewCursor >= animation.frames.length && !animation.loop) {
        state.previewCursor = animation.frames.length - 1;
        state.playing = false;
        document.getElementById("playButton").textContent = "Play";
      }
      state.lastPreviewTime = now;
      drawPreview();
    }
  }
  requestAnimationFrame(previewLoop);
}

async function exportZip() {
  if (!state.image || !state.frames.length) return;
  const project = safeName(el.exportName.value, "sprite_lab_export");
  const scale = Math.max(1, Number(el.exportScale.value) || 1);
  const usedFrames = framesUsedByAnimations();
  if (!usedFrames.length) {
    alert("Add frames to an animation before exporting.");
    return;
  }
  const exportLayout = computeExportLayout(usedFrames);
  const files = [];
  const manifestFrames = [];
  const fileNamesByFrameId = new Map();
  const claimedFileNames = new Set();

  for (const frame of usedFrames) {
    const fileName = uniqueFrameFileName(frame, claimedFileNames);
    fileNamesByFrameId.set(frame.id, fileName);
    const blob = await frameBlob(frame, scale, exportLayout);
    files.push({ path: `${project}/frames/${fileName}`, data: new Uint8Array(await blob.arrayBuffer()) });
    manifestFrames.push({
      id: frame.id,
      name: frame.name,
      file: `frames/${fileName}`,
      source_rect: { x: frame.x, y: frame.y, w: frame.w, h: frame.h },
      source_pivot: { x: frame.pivotX, y: frame.pivotY },
      export_pivot: { x: exportLayout.centerX * scale, y: exportLayout.centerY * scale },
      duration_ms: frame.duration,
    });
  }

  const manifest = {
    format: "sprite-lab-godot",
    version: 1,
    source_sheet: state.imageName,
    export_scale: scale,
    export_canvas: { w: exportLayout.w * scale, h: exportLayout.h * scale },
    frames: manifestFrames,
    animations: state.animations.map((animation) => ({
      name: animation.name,
      fps: animation.fps,
      loop: animation.loop,
      frames: animation.frames
        .map((step) => {
          const frame = state.frames.find((item) => item.id === step.frameId);
          return frame ? { frame: frame.name, file: `frames/${fileNamesByFrameId.get(frame.id)}`, duration_ms: step.duration } : null;
        })
        .filter(Boolean),
    })),
  };

  files.push({ path: `${project}/sprite_lab_manifest.json`, data: textBytes(JSON.stringify(manifest, null, 2)) });
  files.push({ path: `${project}/godot_import_sprite_lab.gd`, data: textBytes(godotImportScript()) });
  const zip = makeZip(files);
  downloadBlob(zip, `${project}.zip`);
}

function framesUsedByAnimations() {
  const usedIds = new Set();
  const frames = [];
  state.animations.forEach((animation) => {
    animation.frames.forEach((step) => {
      if (usedIds.has(step.frameId)) return;
      const frame = state.frames.find((item) => item.id === step.frameId);
      if (!frame) return;
      usedIds.add(step.frameId);
      frames.push(frame);
    });
  });
  return frames;
}

function uniqueFrameFileName(frame, claimedFileNames) {
  const base = safeName(frame.name, "frame");
  let fileName = `${base}.png`;
  let index = 2;
  while (claimedFileNames.has(fileName)) {
    fileName = `${base}_${index}.png`;
    index += 1;
  }
  claimedFileNames.add(fileName);
  return fileName;
}

function computeExportLayout(frames) {
  const halfW = Math.max(1, ...frames.map((frame) => Math.max(frame.pivotX, frame.w - frame.pivotX)));
  const halfH = Math.max(1, ...frames.map((frame) => Math.max(frame.pivotY, frame.h - frame.pivotY)));
  return {
    w: halfW * 2,
    h: halfH * 2,
    centerX: halfW,
    centerY: halfH,
  };
}

function frameBlob(frame, scale, layout) {
  return new Promise((resolve) => {
    const canvas = document.createElement("canvas");
    canvas.width = layout.w * scale;
    canvas.height = layout.h * scale;
    const ctx = canvas.getContext("2d");
    ctx.imageSmoothingEnabled = false;
    ctx.drawImage(
      state.image,
      frame.x,
      frame.y,
      frame.w,
      frame.h,
      (layout.centerX - frame.pivotX) * scale,
      (layout.centerY - frame.pivotY) * scale,
      frame.w * scale,
      frame.h * scale
    );
    canvas.toBlob(resolve, "image/png");
  });
}

function downloadBlob(blob, name) {
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = name;
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

function textBytes(text) {
  return new TextEncoder().encode(text);
}

function makeZip(files) {
  const localParts = [];
  const centralParts = [];
  let offset = 0;
  files.forEach((file) => {
    const name = textBytes(file.path.replace(/\\/g, "/"));
    const data = file.data;
    const crc = crc32(data);
    const local = concatBytes([
      u32(0x04034b50), u16(20), u16(0), u16(0), u16(0), u16(0), u32(crc),
      u32(data.length), u32(data.length), u16(name.length), u16(0), name, data,
    ]);
    localParts.push(local);
    centralParts.push(concatBytes([
      u32(0x02014b50), u16(20), u16(20), u16(0), u16(0), u16(0), u16(0), u32(crc),
      u32(data.length), u32(data.length), u16(name.length), u16(0), u16(0), u16(0),
      u16(0), u32(0), u32(offset), name,
    ]));
    offset += local.length;
  });
  const central = concatBytes(centralParts);
  const local = concatBytes(localParts);
  const end = concatBytes([
    u32(0x06054b50), u16(0), u16(0), u16(files.length), u16(files.length),
    u32(central.length), u32(local.length), u16(0),
  ]);
  return new Blob([local, central, end], { type: "application/zip" });
}

function concatBytes(chunks) {
  const length = chunks.reduce((total, chunk) => total + chunk.length, 0);
  const out = new Uint8Array(length);
  let offset = 0;
  chunks.forEach((chunk) => {
    out.set(chunk, offset);
    offset += chunk.length;
  });
  return out;
}

function u16(value) {
  const bytes = new Uint8Array(2);
  new DataView(bytes.buffer).setUint16(0, value, true);
  return bytes;
}

function u32(value) {
  const bytes = new Uint8Array(4);
  new DataView(bytes.buffer).setUint32(0, value >>> 0, true);
  return bytes;
}

const crcTable = Array.from({ length: 256 }, (_, index) => {
  let c = index;
  for (let k = 0; k < 8; k += 1) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
  return c >>> 0;
});

function crc32(data) {
  let crc = 0xffffffff;
  for (let i = 0; i < data.length; i += 1) crc = crcTable[(crc ^ data[i]) & 0xff] ^ (crc >>> 8);
  return (crc ^ 0xffffffff) >>> 0;
}

function godotImportScript() {
  return `@tool
extends EditorScript

# Usage:
# 1. Copy an exported Sprite Lab folder into your Godot project.
# 2. Open this script in Godot and run it from the script editor.
# 3. It creates a SpriteFrames resource next to sprite_lab_manifest.json.

func _run() -> void:
\tvar manifest_path := "res://sprite_lab_manifest.json"
\tif not FileAccess.file_exists(manifest_path):
\t\tpush_error("Place sprite_lab_manifest.json at the project root or adjust manifest_path.")
\t\treturn
\tvar manifest := JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
\tif typeof(manifest) != TYPE_DICTIONARY:
\t\tpush_error("Sprite Lab manifest could not be parsed.")
\t\treturn
\tvar sprite_frames := SpriteFrames.new()
\tsprite_frames.remove_animation("default")
\tvar frame_lookup := {}
\tfor frame in manifest.get("frames", []):
\t\tvar texture := load("res://" + frame["file"])
\t\tif texture:
\t\t\tframe_lookup[frame["name"]] = texture
\tfor animation in manifest.get("animations", []):
\t\tvar anim_name := animation["name"]
\t\tsprite_frames.add_animation(anim_name)
\t\tvar speed := float(animation.get("fps", 8))
\t\tsprite_frames.set_animation_speed(anim_name, speed)
\t\tsprite_frames.set_animation_loop(anim_name, bool(animation.get("loop", true)))
\t\tfor step in animation.get("frames", []):
\t\t\tvar texture = frame_lookup.get(step["frame"])
\t\t\tif texture:
\t\t\t\tvar duration_ms := float(step.get("duration_ms", 1000.0 / speed))
\t\t\t\tvar duration_ratio := duration_ms / (1000.0 / speed)
\t\t\t\tsprite_frames.add_frame(anim_name, texture, max(0.01, duration_ratio))
\tResourceSaver.save(sprite_frames, "res://sprite_lab_spriteframes.tres")
`;
}

init();
