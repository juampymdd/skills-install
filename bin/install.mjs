#!/usr/bin/env node
//
// bin/install.mjs
// Entry point para `npx github:juampymdd/skills-install` y `bunx github:juampymdd/skills-install`.
// Instala el set curado de skills vía el CLI "skills" (https://skills.sh).
//

import { spawnSync } from "node:child_process";

// Agente destino. Cambialo si usás otro (cursor, codex, gemini-cli, etc.).
const AGENT = "claude-code";

// Flags por instalación: -g global (~/.claude/skills), -a agente, -y sin confirmaciones.
const FLAGS = ["-g", "-a", AGENT, "-y"];

// Cada entrada: [repo-url, nombre-del-skill]
const SKILLS = [
  ["https://github.com/ibelick/ui-skills", "baseline-ui"],
  ["https://github.com/ibelick/ui-skills", "fixing-accessibility"],
  ["https://github.com/ibelick/ui-skills", "fixing-motion-performance"],
  ["https://github.com/anthropics/skills", "frontend-design"],
  ["https://github.com/wshobson/agents", "wcag-audit-patterns"],
  ["https://github.com/emilkowalski/skill", "emil-design-eng"],
  ["https://github.com/millionco/react-doctor", "react-doctor"],
  ["https://github.com/shadcn-ui/ui", "shadcn"],
  ["https://github.com/jakubkrehel/make-interfaces-feel-better", "make-interfaces-feel-better"],
  ["https://github.com/0xdesign/design-plugin", "design-lab"],
  ["https://github.com/nextlevelbuilder/ui-ux-pro-max-skill", "ui-ux-pro-max"],
  ["https://github.com/Dammyjay93/interface-design", "interface-design"],
  ["https://github.com/raphaelsalaja/skill", "12-principles-of-animation"],
  ["https://github.com/pbakaus/impeccable", "impeccable"],
  ["https://github.com/bencium/bencium-marketplace", "bencium-innovative-ux-designer"],
  ["https://github.com/Leonxlnx/taste-skill", "gpt-taste"],
  ["https://github.com/vercel-labs/agent-skills", "vercel-react-best-practices"],
  ["https://github.com/vercel-labs/agent-browser", "agent-browser"],
  ["https://github.com/vercel-labs/agent-skills", "web-design-guidelines"],
  ["https://github.com/obra/superpowers", "brainstorming"],
];

const isWin = process.platform === "win32";

function hasCmd(cmd) {
  const probe = isWin ? "where" : "command";
  const args = isWin ? [cmd] : ["-v", cmd];
  const r = spawnSync(probe, args, { stdio: "ignore", shell: isWin });
  return r.status === 0;
}

// Runner: npx (Node) o bunx (Bun).
let runner, runnerArgs;
if (hasCmd("npx")) {
  runner = "npx";
  runnerArgs = ["-y"];
} else if (hasCmd("bunx")) {
  runner = "bunx";
  runnerArgs = [];
} else {
  console.error("Error: necesitás Node (npx) o Bun (bunx) instalado.");
  console.error("Node: https://nodejs.org  ·  Bun: https://bun.sh");
  process.exit(1);
}

// Auth de GitHub: sin token, la API limita a 60 req/h y algunas skills fallan.
// Si tenés gh logueado, tomamos el token (-> 5000 req/h, sin prompt).
if (!process.env.GITHUB_TOKEN && hasCmd("gh")) {
  const t = spawnSync("gh", ["auth", "token"], { encoding: "utf8", shell: isWin });
  if (t.status === 0 && t.stdout && t.stdout.trim()) {
    process.env.GITHUB_TOKEN = t.stdout.trim();
  }
}
if (!process.env.GITHUB_TOKEN) {
  console.warn("Aviso: sin GITHUB_TOKEN podés pegar rate limit de la GitHub API (60 req/h).");
  console.warn("       Logueate con 'gh auth login' o exportá GITHUB_TOKEN para evitarlo.\n");
}

const ok = [];
const fail = [];

console.log(`Instalando ${SKILLS.length} skills en el agente: ${AGENT}  (runner: ${runner})\n`);

for (const [repo, skill] of SKILLS) {
  console.log(`→ ${skill.padEnd(34)} (${repo})`);
  const r = spawnSync(
    runner,
    [...runnerArgs, "skills", "add", repo, "--skill", skill, ...FLAGS],
    { stdio: "inherit", shell: isWin }
  );
  if (r.status === 0) ok.push(skill);
  else fail.push(skill);
  console.log("");
}

console.log("─".repeat(29));
console.log(`✓ Instaladas: ${ok.length}`);
if (fail.length > 0) {
  console.log(`✗ Fallaron:   ${fail.length}`);
  for (const s of fail) console.log(`    - ${s}`);
  console.log("\nPara las que fallaron, revisá el nombre real del skill con:");
  console.log(`    ${runner} skills add <repo-url> --list`);
  process.exit(1);
}
