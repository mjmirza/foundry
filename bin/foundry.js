#!/usr/bin/env node
"use strict";
// Thin launcher. Resolves the bundled installer relative to this file, which is
// reliable when run through npx, and runs it with bash, passing your arguments.
const { spawnSync } = require("child_process");
const path = require("path");

const installer = path.join(__dirname, "..", "foundry", "install.sh");
const result = spawnSync("bash", [installer, ...process.argv.slice(2)], { stdio: "inherit" });
process.exit(result.status === null ? 1 : result.status);
