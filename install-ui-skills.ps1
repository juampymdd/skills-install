#
# install-ui-skills.ps1
# Instala el set curado de skills de UI / diseno / frontend para tu agente.
#
# Uso:
#   irm https://raw.githubusercontent.com/juampymdd/skills-install/main/install-ui-skills.ps1 | iex
#   # o local:
#   .\install-ui-skills.ps1
#
# Notas:
#   - Usa el CLI "skills" (https://skills.sh) via npx o bunx.
#   - No-interactivo: instala todo de una sin abrir selectores.
#   - Si una skill falla, sigue con las demas y te lo reporta al final.

# Agente destino. Cambialo si usas otro: -a cursor / codex / gemini-cli, etc.
$Agent = "claude-code"

# Flags por instalacion: -g global (~/.claude/skills), -a agente, -y sin confirmaciones.
$Flags = @("-g", "-a", $Agent, "-y")

# Runner: npx (Node) o bunx (Bun).
if (Get-Command npx -ErrorAction SilentlyContinue) {
    $Runner = "npx"
    $RunnerArgs = @("-y")
} elseif (Get-Command bunx -ErrorAction SilentlyContinue) {
    $Runner = "bunx"
    $RunnerArgs = @()
} else {
    Write-Error "Necesitas Node (npx) o Bun (bunx) instalado. Node: https://nodejs.org  -  Bun: https://bun.sh"
    exit 1
}

# Auth de GitHub: sin token, la API limita a 60 req/h y algunas skills fallan.
# Si tenes gh logueado, tomamos el token (-> 5000 req/h, sin prompt).
if (-not $env:GITHUB_TOKEN -and (Get-Command gh -ErrorAction SilentlyContinue)) {
    try {
        $tok = (gh auth token 2>$null)
        if ($tok) { $env:GITHUB_TOKEN = $tok.Trim() }
    } catch {}
}
if (-not $env:GITHUB_TOKEN) {
    Write-Host "Aviso: sin GITHUB_TOKEN podes pegar rate limit de la GitHub API (60 req/h)."
    Write-Host "       Logueate con 'gh auth login' o seteá `$env:GITHUB_TOKEN para evitarlo."
    Write-Host ""
}

# Cada entrada: Repo + Skill
$Skills = @(
  @{ Repo = "https://github.com/ibelick/ui-skills";                       Skill = "baseline-ui" }
  @{ Repo = "https://github.com/ibelick/ui-skills";                       Skill = "fixing-accessibility" }
  @{ Repo = "https://github.com/ibelick/ui-skills";                       Skill = "fixing-motion-performance" }
  @{ Repo = "https://github.com/anthropics/skills";                       Skill = "frontend-design" }
  @{ Repo = "https://github.com/wshobson/agents";                         Skill = "wcag-audit-patterns" }
  @{ Repo = "https://github.com/emilkowalski/skill";                      Skill = "emil-design-eng" }
  @{ Repo = "https://github.com/millionco/react-doctor";                  Skill = "react-doctor" }
  @{ Repo = "https://github.com/shadcn-ui/ui";                            Skill = "shadcn" }
  @{ Repo = "https://github.com/jakubkrehel/make-interfaces-feel-better"; Skill = "make-interfaces-feel-better" }
  @{ Repo = "https://github.com/0xdesign/design-plugin";                  Skill = "design-lab" }
  @{ Repo = "https://github.com/nextlevelbuilder/ui-ux-pro-max-skill";    Skill = "ui-ux-pro-max" }
  @{ Repo = "https://github.com/Dammyjay93/interface-design";             Skill = "interface-design" }
  @{ Repo = "https://github.com/raphaelsalaja/skill";                     Skill = "12-principles-of-animation" }
  @{ Repo = "https://github.com/pbakaus/impeccable";                      Skill = "impeccable" }
  @{ Repo = "https://github.com/bencium/bencium-marketplace";            Skill = "bencium-innovative-ux-designer" }
  @{ Repo = "https://github.com/Leonxlnx/taste-skill";                    Skill = "gpt-taste" }
  @{ Repo = "https://github.com/vercel-labs/agent-skills";                Skill = "vercel-react-best-practices" }
  @{ Repo = "https://github.com/vercel-labs/agent-browser";               Skill = "agent-browser" }
  @{ Repo = "https://github.com/vercel-labs/agent-skills";                Skill = "web-design-guidelines" }
  @{ Repo = "https://github.com/obra/superpowers";                        Skill = "brainstorming" }
)

$ok = @()
$fail = @()

Write-Host "Instalando $($Skills.Count) skills en el agente: $Agent  (runner: $Runner)"
Write-Host ""

foreach ($entry in $Skills) {
    $repo  = $entry.Repo
    $skill = $entry.Skill
    Write-Host ("-> {0,-34} ({1})" -f $skill, $repo)

    & $Runner @RunnerArgs skills add $repo --skill $skill @Flags

    if ($LASTEXITCODE -eq 0) {
        $ok += $skill
    } else {
        $fail += $skill
    }
    Write-Host ""
}

Write-Host "-----------------------------"
Write-Host "OK Instaladas: $($ok.Count)"
if ($fail.Count -gt 0) {
    Write-Host "X  Fallaron:   $($fail.Count)"
    foreach ($s in $fail) { Write-Host "    - $s" }
    Write-Host ""
    Write-Host "Para las que fallaron, revisa el nombre real del skill con:"
    Write-Host "    $Runner skills add <repo-url> --list"
}
