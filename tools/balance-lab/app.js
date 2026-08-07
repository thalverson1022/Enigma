"use strict";

const elements = {
  runButton: document.querySelector("#run-button"),
  bridgeStatus: document.querySelector("#bridge-status"),
  runState: document.querySelector("#run-state"),
  runDetail: document.querySelector("#run-detail"),
  passCount: document.querySelector("#pass-count"),
  warnCount: document.querySelector("#warn-count"),
  failCount: document.querySelector("#fail-count"),
  scenarioCount: document.querySelector("#scenario-count"),
  seedCount: document.querySelector("#seed-count"),
  reportTimestamp: document.querySelector("#report-timestamp"),
  suiteStatus: document.querySelector("#suite-status"),
  scenarioRows: document.querySelector("#scenario-rows"),
  mechanicsRows: document.querySelector("#mechanics-rows"),
  exitCode: document.querySelector("#exit-code"),
  runOutput: document.querySelector("#run-output"),
};

let pollTimer = null;
let latestReportGeneratedAt = null;

async function fetchJson(url, options = {}) {
  const response = await fetch(url, options);
  const body = await response.json();
  if (!response.ok) {
    const error = new Error(body.error || `Request failed with ${response.status}`);
    error.body = body;
    throw error;
  }
  return body;
}

function setBridgeStatus(status) {
  elements.bridgeStatus.classList.remove(
    "status-idle",
    "status-notice",
    "status-running",
    "status-success",
    "status-failure",
  );
  elements.bridgeStatus.classList.add(`status-${status}`);
}

function updateFromStatus(status) {
  const runStatus = status.status || "idle";
  const report = status.report;
  const isRunning = runStatus === "running";

  elements.runButton.disabled = isRunning;
  elements.runButton.textContent = isRunning ? "Running..." : "Run Balance";
  setBridgeStatus(runStatus === "idle" ? "success" : runStatus);
  elements.bridgeStatus.textContent = runStatus === "idle" ? "Bridge online" : runStatus;

  if (runStatus === "running") {
    elements.runState.textContent = "Balance suite running";
    elements.runDetail.textContent = `Started ${formatTime(status.startedAt)}. Godot output will update as the bridge receives it.`;
  } else if (runStatus === "success") {
    elements.runState.textContent = "Balance suite finished";
    elements.runDetail.textContent = `Completed ${formatTime(status.endedAt)}. Latest report data is available through the bridge.`;
  } else if (runStatus === "failure") {
    elements.runState.textContent = "Balance suite failed";
    elements.runDetail.textContent = status.error || "Godot returned a failure. Check the run output below.";
  } else {
    elements.runState.textContent = "Ready";
    elements.runDetail.textContent = "Click Run Balance to execute the existing Godot balance suite.";
  }

  elements.exitCode.textContent =
    status.exitCode === null || status.exitCode === undefined ? "No exit code" : `Exit ${status.exitCode}`;
  elements.runOutput.textContent = formatOutput(status);
  updateReportSummary(report);

  if (isRunning && !pollTimer) {
    pollTimer = window.setInterval(refreshStatus, 1000);
  } else if (!isRunning && pollTimer) {
    window.clearInterval(pollTimer);
    pollTimer = null;
  }
}

async function loadLatestReport() {
  try {
    const report = await fetchJson("/api/report/results");
    latestReportGeneratedAt = report.generated_at || null;
    renderReport(report);
  } catch (error) {
    renderReportError(error.message);
  }
}

function updateReportSummary(report) {
  if (!report) {
    elements.passCount.textContent = "-";
    elements.warnCount.textContent = "-";
    elements.failCount.textContent = "-";
    elements.scenarioCount.textContent = "-";
    elements.seedCount.textContent = "-";
    elements.reportTimestamp.textContent = "No run loaded";
    elements.suiteStatus.textContent = "Waiting";
    return;
  }

  elements.passCount.textContent = String(report.counts?.pass ?? 0);
  elements.warnCount.textContent = String(report.counts?.warn ?? 0);
  elements.failCount.textContent = String(report.counts?.fail ?? 0);
  elements.scenarioCount.textContent = String(report.scenarioCount ?? 0);
  elements.seedCount.textContent = String(report.seedCount ?? 0);
  elements.reportTimestamp.textContent = report.generatedAt ? `Generated ${formatTime(report.generatedAt)}` : "Report loaded";
  elements.suiteStatus.textContent = (report.counts?.fail ?? 0) > 0 ? "Fail" : (report.counts?.warn ?? 0) > 0 ? "Warn" : "Pass";
}

function renderReport(report) {
  if (!report || !Array.isArray(report.mechanics) || !Array.isArray(report.scenarios)) {
    renderReportError("Report data is missing mechanics or scenarios arrays.");
    return;
  }

  const counts = report.status_counts || countStatuses([...report.mechanics, ...report.scenarios]);
  const seedCount = report.seed_count ?? report.scenarios.reduce((sum, scenario) => sum + numberOrZero(scenario.seed_count), 0);

  updateReportSummary({
    counts,
    scenarioCount: report.scenario_count ?? report.scenarios.length,
    seedCount,
    generatedAt: report.generated_at,
  });

  renderScenarioRows(report.scenarios);
  renderMechanicsRows(report.mechanics);
}

function renderScenarioRows(scenarios) {
  if (!scenarios.length) {
    elements.scenarioRows.innerHTML = '<tr><td colspan="8" class="empty-cell">No scenarios found in this report.</td></tr>';
    return;
  }

  elements.scenarioRows.innerHTML = scenarios.map((scenario) => {
    const aggregate = scenario.aggregate || {};
    const dps = aggregate.dps || {};
    const poisonContribution = getPoisonContribution(aggregate);
    const notes = [
      ...(Array.isArray(scenario.notes) ? scenario.notes : []),
      formatThresholds(scenario.thresholds),
    ].filter(Boolean);

    return `
      <tr>
        <td>
          <strong>${escapeHtml(scenario.label || scenario.id || "Unnamed scenario")}</strong>
          <span class="subtle-line">${escapeHtml(scenario.monster || "Unknown monster")}</span>
          <span class="subtle-line">${escapeHtml(formatList(scenario.rotation))}</span>
          ${notes.length ? `<span class="subtle-line">${escapeHtml(notes.join(" | "))}</span>` : ""}
        </td>
        <td>${statusBadge(scenario.status)}</td>
        <td class="number-cell">${formatNumber(dps.mean)}</td>
        <td class="number-cell">${formatNumber(dps.p05)} / ${formatNumber(dps.p95)}</td>
        <td class="number-cell">${formatPercent(aggregate.win_rate)}</td>
        <td class="number-cell">${formatPercent(poisonContribution)}</td>
        <td class="number-cell">${formatPercent(aggregate.min_cast_proc_rate?.mean)}</td>
        <td class="number-cell">${formatInteger(scenario.seed_count)}</td>
      </tr>
    `;
  }).join("");
}

function renderMechanicsRows(mechanics) {
  if (!mechanics.length) {
    elements.mechanicsRows.innerHTML = '<tr><td colspan="6" class="empty-cell">No mechanics checks found in this report.</td></tr>';
    return;
  }

  elements.mechanicsRows.innerHTML = mechanics.map((check) => {
    const values = check.values || {};
    return `
      <tr>
        <td>
          <strong>${escapeHtml(check.label || check.id || "Unnamed check")}</strong>
          <span class="subtle-line">${escapeHtml(check.id || "")}</span>
        </td>
        <td>${statusBadge(check.status)}</td>
        <td class="number-cell">${formatValue(values.actual)}</td>
        <td class="number-cell">${formatValue(values.expected)}</td>
        <td class="number-cell">${formatValue(values.tolerance)}</td>
        <td>${escapeHtml(check.note || "-")}</td>
      </tr>
    `;
  }).join("");
}

function renderReportError(message) {
  elements.scenarioRows.innerHTML = `<tr><td colspan="8" class="empty-cell">${escapeHtml(message)}</td></tr>`;
  elements.mechanicsRows.innerHTML = `<tr><td colspan="6" class="empty-cell">${escapeHtml(message)}</td></tr>`;
}

function countStatuses(rows) {
  const counts = { pass: 0, warn: 0, fail: 0 };
  for (const row of rows) {
    if (Object.hasOwn(counts, row.status)) {
      counts[row.status] += 1;
    }
  }
  return counts;
}

function getPoisonContribution(aggregate) {
  const poisonMean = aggregate.poison_damage?.mean;
  const totalMean = aggregate.total_damage?.mean;
  if (!Number.isFinite(poisonMean) || !Number.isFinite(totalMean) || totalMean <= 0) {
    return null;
  }
  return poisonMean / totalMean;
}

function formatThresholds(thresholds) {
  if (!thresholds || typeof thresholds !== "object") {
    return "";
  }
  return Object.entries(thresholds)
    .map(([key, value]) => `${key}: ${formatValue(value)}`)
    .join(", ");
}

function formatOutput(status) {
  const lines = [];
  if (status.command?.length) {
    lines.push(status.command.join(" "));
  }
  if (status.stdout) {
    lines.push("", "stdout:", status.stdout.trim());
  }
  if (status.stderr) {
    lines.push("", "stderr:", status.stderr.trim());
  }
  if (status.error) {
    lines.push("", "error:", status.error);
  }
  return lines.join("\n").trim() || "No run started.";
}

function formatTime(value) {
  if (!value) {
    return "unknown time";
  }
  return new Date(value).toLocaleString();
}

async function refreshStatus() {
  try {
    const status = await fetchJson("/api/status");
    updateFromStatus(status);
    if (status.status !== "running" && status.report?.generatedAt !== latestReportGeneratedAt) {
      await loadLatestReport();
    }
  } catch (error) {
    setBridgeStatus("failure");
    elements.bridgeStatus.textContent = "Bridge offline";
    elements.runState.textContent = "Local bridge unavailable";
    elements.runDetail.textContent = "Start the Balance Lab server with node tools\\balance-lab\\server.js.";
    elements.runButton.disabled = true;
    elements.runOutput.textContent = error.message;
  }
}

async function runBalance() {
  elements.runButton.disabled = true;
  try {
    const status = await fetchJson("/api/run-balance", { method: "POST" });
    updateFromStatus(status);
  } catch (error) {
    updateFromStatus(error.body?.status || { status: "failure", error: error.message });
  }
}

function statusBadge(status) {
  const normalized = ["pass", "warn", "fail"].includes(status) ? status : "idle";
  return `<span class="row-status row-status-${normalized}">${escapeHtml(status || "unknown")}</span>`;
}

function formatList(values) {
  if (!Array.isArray(values) || !values.length) {
    return "No rotation";
  }
  return values.join(" -> ");
}

function formatNumber(value) {
  if (!Number.isFinite(value)) {
    return "-";
  }
  return value.toFixed(2);
}

function formatInteger(value) {
  if (!Number.isFinite(value)) {
    return "-";
  }
  return String(Math.round(value));
}

function formatPercent(value) {
  if (!Number.isFinite(value)) {
    return "-";
  }
  return `${(value * 100).toFixed(1)}%`;
}

function formatValue(value) {
  if (typeof value === "number") {
    if (Number.isInteger(value)) {
      return String(value);
    }
    return Math.abs(value) >= 100 ? value.toFixed(1) : value.toFixed(3).replace(/0+$/, "").replace(/\.$/, "");
  }
  if (value === null || value === undefined || value === "") {
    return "-";
  }
  return String(value);
}

function numberOrZero(value) {
  return Number.isFinite(value) ? value : 0;
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

elements.runButton.addEventListener("click", runBalance);
refreshStatus();
