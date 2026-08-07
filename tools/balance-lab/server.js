"use strict";

const { spawn } = require("node:child_process");
const fs = require("node:fs");
const http = require("node:http");
const path = require("node:path");
const { URL } = require("node:url");

const host = process.env.BALANCE_LAB_HOST || "127.0.0.1";
const port = Number(process.env.BALANCE_LAB_PORT || 8787);
const toolRoot = __dirname;
const repoRoot = path.resolve(toolRoot, "..", "..");
const projectRoot = path.join(repoRoot, "project");
const latestReportDir = path.join(projectRoot, "reports", "balance", "latest");
const godotPath = process.env.GODOT_PATH || "F:\\Applications\\Godot\\Godot_v4.7-stable_win64_console.exe";
const godotLogPath = path.join(latestReportDir, "godot_run.log");

const staticTypes = {
  ".css": "text/css; charset=utf-8",
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
};

const runState = {
  status: "idle",
  startedAt: null,
  endedAt: null,
  exitCode: null,
  error: null,
  stdout: "",
  stderr: "",
  command: [],
  latestReportPath: latestReportDir,
  godotLogPath,
};

function sendJson(response, statusCode, payload) {
  response.writeHead(statusCode, {
    "Content-Type": "application/json; charset=utf-8",
    "Cache-Control": "no-store",
  });
  response.end(JSON.stringify(payload, null, 2));
}

function sendText(response, statusCode, text, contentType = "text/plain; charset=utf-8") {
  response.writeHead(statusCode, {
    "Content-Type": contentType,
    "Cache-Control": "no-store",
  });
  response.end(text);
}

function readJsonFile(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function getReportSummary() {
  const resultsPath = path.join(latestReportDir, "results.json");
  if (!fs.existsSync(resultsPath)) {
    return null;
  }

  const report = readJsonFile(resultsPath);
  const mechanics = Array.isArray(report.mechanics) ? report.mechanics : [];
  const scenarios = Array.isArray(report.scenarios) ? report.scenarios : [];
  const counts = report.status_counts || { pass: 0, warn: 0, fail: 0 };
  if (!report.status_counts) {
    for (const row of [...mechanics, ...scenarios]) {
      if (Object.hasOwn(counts, row.status)) {
        counts[row.status] += 1;
      }
    }
  }

  return {
    generatedAt: report.generated_at || null,
    version: report.version || null,
    project: report.project || report.metadata?.project || null,
    tool: report.tool || report.metadata?.tool || null,
    status: report.status || report.metadata?.status || null,
    statusSemantics: report.status_semantics || report.metadata?.status_semantics || null,
    counts,
    mechanicsCount: report.mechanics_count ?? mechanics.length,
    scenarioCount: report.scenario_count ?? scenarios.length,
    seedCount: report.seed_count ?? scenarios.reduce((sum, scenario) => sum + Number(scenario.seed_count || 0), 0),
    resultsPath,
    scenarioSummaryPath: path.join(latestReportDir, "scenario_summary.csv"),
    legacyHtmlPath: path.join(latestReportDir, "index.html"),
  };
}

function getPublicStatus() {
  return {
    ...runState,
    report: getReportSummary(),
  };
}

function appendOutput(streamName, chunk) {
  const text = chunk.toString();
  runState[streamName] = `${runState[streamName]}${text}`.slice(-30000);
}

function startBalanceRun(response) {
  if (runState.status === "running") {
    sendJson(response, 409, {
      error: "balance_run_already_running",
      status: getPublicStatus(),
    });
    return;
  }

  if (!fs.existsSync(godotPath)) {
    runState.status = "failure";
    runState.startedAt = new Date().toISOString();
    runState.endedAt = runState.startedAt;
    runState.exitCode = null;
    runState.error = `Godot executable not found: ${godotPath}`;
    runState.stdout = "";
    runState.stderr = "";
    sendJson(response, 500, getPublicStatus());
    return;
  }

  fs.mkdirSync(latestReportDir, { recursive: true });

  const args = [
    "--headless",
    "--path",
    projectRoot,
    "--log-file",
    godotLogPath,
    "-s",
    "res://scripts/tools/run_balance_suite.gd",
  ];

  runState.status = "running";
  runState.startedAt = new Date().toISOString();
  runState.endedAt = null;
  runState.exitCode = null;
  runState.error = null;
  runState.stdout = "";
  runState.stderr = "";
  runState.command = [godotPath, ...args];

  const child = spawn(godotPath, args, {
    cwd: repoRoot,
    windowsHide: true,
  });

  child.stdout.on("data", (chunk) => appendOutput("stdout", chunk));
  child.stderr.on("data", (chunk) => appendOutput("stderr", chunk));
  child.on("error", (error) => {
    runState.status = "failure";
    runState.endedAt = new Date().toISOString();
    runState.error = error.message;
  });
  child.on("close", (code) => {
    runState.status = code === 0 ? "success" : "failure";
    runState.endedAt = new Date().toISOString();
    runState.exitCode = code;
    if (code !== 0 && !runState.error) {
      runState.error = `Godot exited with code ${code}.`;
    }
  });

  sendJson(response, 202, getPublicStatus());
}

function serveStatic(response, pathname) {
  const requestedPath = pathname === "/" ? "/index.html" : pathname;
  const normalized = path.normalize(requestedPath).replace(/^([/\\])+/, "");
  const filePath = path.join(toolRoot, normalized);

  if (!filePath.startsWith(toolRoot) || !fs.existsSync(filePath) || !fs.statSync(filePath).isFile()) {
    sendText(response, 404, "Not found");
    return;
  }

  const contentType = staticTypes[path.extname(filePath)] || "application/octet-stream";
  sendText(response, 200, fs.readFileSync(filePath), contentType);
}

const server = http.createServer((request, response) => {
  const url = new URL(request.url, `http://${request.headers.host || `${host}:${port}`}`);

  if (request.method === "GET" && url.pathname === "/api/status") {
    sendJson(response, 200, getPublicStatus());
    return;
  }

  if (request.method === "POST" && url.pathname === "/api/run-balance") {
    startBalanceRun(response);
    return;
  }

  if (request.method === "GET" && url.pathname === "/api/report/results") {
    const resultsPath = path.join(latestReportDir, "results.json");
    if (!fs.existsSync(resultsPath)) {
      sendJson(response, 404, { error: "results_not_found", resultsPath });
      return;
    }
    sendJson(response, 200, readJsonFile(resultsPath));
    return;
  }

  if (request.method === "GET" && url.pathname === "/api/report/scenario-summary") {
    const csvPath = path.join(latestReportDir, "scenario_summary.csv");
    if (!fs.existsSync(csvPath)) {
      sendJson(response, 404, { error: "scenario_summary_not_found", csvPath });
      return;
    }
    sendText(response, 200, fs.readFileSync(csvPath, "utf8"), "text/csv; charset=utf-8");
    return;
  }

  if (request.method === "GET" && url.pathname === "/api/report/godot-log") {
    if (!fs.existsSync(godotLogPath)) {
      sendText(response, 404, "Godot run log not found.");
      return;
    }
    sendText(response, 200, fs.readFileSync(godotLogPath, "utf8"));
    return;
  }

  if (request.method === "GET") {
    serveStatic(response, url.pathname);
    return;
  }

  sendText(response, 405, "Method not allowed");
});

server.listen(port, host, () => {
  console.log(`Balance Lab running at http://${host}:${port}`);
  console.log(`Godot path: ${godotPath}`);
});
