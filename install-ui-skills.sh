#!/usr/bin/env bash
#
# install-ui-skills.sh
# Instala el set curado de skills de UI / diseño / frontend para tu agente.
#
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/juampymdd/skills-install/main/install-ui-skills.sh | bash
#   # o local:
#   bash install-ui-skills.sh
#
# Notas:
#   - Usa el CLI "skills" (https://skills.sh) vía npx o bunx.
#   - No-interactivo: instala todo de una sin abrir selectores.
#   - Si una skill falla, sigue con las demás y te lo reporta al final.

set -u

# Agente destino. Cambialo si usás otro: -a cursor / codex / gemini-cli, etc.
AGENT="claude-code"

# Destino:
#   - default: global (-g) -> ~/.claude/skills, sirve en todos tus proyectos.
#   - PROJECT=1: instala en el proyecto actual (cwd) -> ./.claude/skills.
# Flags: -a agente, -y sin confirmaciones.
if [ -n "${PROJECT:-}" ]; then
  FLAGS=(-a "$AGENT" -y)
  SCOPE="proyecto ($(pwd)/.claude/skills)"
else
  FLAGS=(-g -a "$AGENT" -y)
  SCOPE="global (~/.claude/skills)"
fi

# Runner: npx (Node) o bunx (Bun).
if command -v npx >/dev/null 2>&1; then
  RUNNER=(npx -y)
elif command -v bunx >/dev/null 2>&1; then
  RUNNER=(bunx)
else
  echo "Error: necesitás Node (npx) o Bun (bunx) instalado." >&2
  echo "Instalá Node: https://nodejs.org  ·  o Bun: https://bun.sh" >&2
  exit 1
fi

# Auth de GitHub: sin token, la API limita a 60 req/h y algunas skills fallan.
# Si tenés gh logueado, tomamos el token (-> 5000 req/h, sin prompt).
if [ -z "${GITHUB_TOKEN:-}" ] && command -v gh >/dev/null 2>&1; then
  _tok="$(gh auth token 2>/dev/null || true)"
  [ -n "$_tok" ] && export GITHUB_TOKEN="$_tok"
fi
if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "Aviso: sin GITHUB_TOKEN podés pegar rate limit de la GitHub API (60 req/h)." >&2
  echo "       Logueate con 'gh auth login' o exportá GITHUB_TOKEN para evitarlo." >&2
  echo >&2
fi

# Cada entrada: "repo-url|nombre-del-skill"
SKILLS=(
  "https://github.com/ibelick/ui-skills|baseline-ui"
  "https://github.com/ibelick/ui-skills|fixing-accessibility"
  "https://github.com/ibelick/ui-skills|fixing-motion-performance"
  "https://github.com/anthropics/skills|frontend-design"
  "https://github.com/wshobson/agents|wcag-audit-patterns"
  "https://github.com/emilkowalski/skill|emil-design-eng"
  "https://github.com/millionco/react-doctor|react-doctor"
  "https://github.com/shadcn-ui/ui|shadcn"
  "https://github.com/jakubkrehel/make-interfaces-feel-better|make-interfaces-feel-better"
  "https://github.com/0xdesign/design-plugin|design-lab"
  "https://github.com/nextlevelbuilder/ui-ux-pro-max-skill|ui-ux-pro-max"
  "https://github.com/Dammyjay93/interface-design|interface-design"
  "https://github.com/raphaelsalaja/skill|12-principles-of-animation"
  "https://github.com/pbakaus/impeccable|impeccable"
  "https://github.com/bencium/bencium-marketplace|bencium-innovative-ux-designer"
  "https://github.com/Leonxlnx/taste-skill|gpt-taste"
  "https://github.com/vercel-labs/agent-skills|vercel-react-best-practices"
  "https://github.com/vercel-labs/agent-browser|agent-browser"
  "https://github.com/vercel-labs/agent-skills|web-design-guidelines"
  "https://github.com/obra/superpowers|brainstorming"
)

ok=()
fail=()

echo "Instalando ${#SKILLS[@]} skills en el agente: $AGENT  (runner: ${RUNNER[0]})"
echo "Destino: $SCOPE"
echo

for entry in "${SKILLS[@]}"; do
  repo="${entry%%|*}"
  skill="${entry##*|}"
  printf '→ %-34s (%s)\n' "$skill" "$repo"
  if "${RUNNER[@]}" skills add "$repo" --skill "$skill" "${FLAGS[@]}"; then
    ok+=("$skill")
  else
    fail+=("$skill")
  fi
  echo
done

echo "─────────────────────────────"
echo "✓ Instaladas: ${#ok[@]}"
if [ "${#fail[@]}" -gt 0 ]; then
  echo "✗ Fallaron:   ${#fail[@]}"
  for s in "${fail[@]}"; do echo "    - $s"; done
  echo
  echo "Para las que fallaron, revisá el nombre real del skill con:"
  echo "    ${RUNNER[*]} skills add <repo-url> --list"
fi
