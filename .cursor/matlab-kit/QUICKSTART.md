# MATLAB + Cursor — QUICKSTART

One page. Full details: [README.md](README.md). MCP troubleshooting: `../matlab_cursor_integration_readme.md`.

---

## What this kit does

Cursor Agent needs **three layers** for MATLAB:

| Layer | Purpose | Installed by |
|-------|---------|------------|
| **MCP** | Run real MATLAB (`evaluate_matlab_code`, …) | Machine setup + `mcp.json` |
| **Rules** (`.mdc`) | How to write `.m` files | `install.ps1` → `mathworks-*.mdc` |
| **Skills** (`SKILL.md`) | Testing, debugging, DSP workflows, … | `install.ps1` → junctions in `.cursor/skills/` |

**Project rule** (optional): `.cursor/rules/<project>.mdc` — your repo conventions. Chamberlain uses `matlab.mdc`.

```
You prompt Agent
    → Rules + Skills (context)
    → MCP (executes MATLAB)
    → MATLAB on your PC
```

---

## MCP binary — which `.exe`?

Use **`matlab-mcp-server.exe`** in:

`%USERPROFILE%\.matlab\agentic-toolkits\bin\`

`matlab-mcp-server-windows-x64.exe` is the GitHub download name — same file after rename. **Keep one, delete the duplicate.**

Both configs should point at `matlab-mcp-server.exe`. **Chamberlain:** global only (`~/.cursor/mcp.json`); no project `.cursor/mcp.json`.

---

## Once per machine (already done if MCP works)

```powershell
# 1. Download from https://github.com/matlab/matlab-mcp-server/releases
#    → save as %USERPROFILE%\.matlab\agentic-toolkits\bin\matlab-mcp-server.exe

# 2. One-time MATLAB toolbox install
& "$env:USERPROFILE\.matlab\agentic-toolkits\bin\matlab-mcp-server.exe" `
  --setup-matlab --matlab-root="C:\Program Files\MATLAB\R2025b"

# 3. Global MCP (optional — works for all projects)
#    Edit %USERPROFILE%\.cursor\mcp.json
```

**Verify:** Agent chat → `List MCP tools and run 2+2 in MATLAB` → `ans = 4`.

**Figures / BrainVoyager:** In MATLAB run `shareMATLABSession()` (no args), keep `--matlab-session-mode=auto`.

---

## Every new MATLAB repo

```powershell
# 1. Copy portable folder
Copy-Item -Recurse "<source>\.cursor\matlab-kit" "<newrepo>\.cursor\matlab-kit"

# 2. Edit skill groups (optional)
notepad <newrepo>\.cursor\matlab-kit\groups.txt
# Minimum line: matlab-core

# 3. Install from repo root
cd <newrepo>
.\.cursor\matlab-kit\install.ps1

# 4. Project rule (optional) — skip for generic MATLAB; copy/adapt for chamberlain-style repos
#    <newrepo>\.cursor\rules\myproject.mdc

# 5. MCP: global `%USERPROFILE%\.cursor\mcp.json` — omit `--initial-working-folder` so MCP uses the opened Cursor workspace

# 6. Restart Cursor
```

**Chamberlain:** also copy `rules/matlab.mdc` (workflow), not just `matlab-kit/`.

---

## What `install.ps1` creates

| Output | What it is |
|--------|------------|
| `.cursor/rules/mathworks-*.mdc` | Copied from [matlab/rules](https://github.com/matlab/rules) |
| `.cursor/skills/matlab-testing/` etc. | Junctions → `%USERPROFILE%\.matlab\matlab-agentic-toolkit\skills-catalog\` |
| `.cursor/mcp.json` | From `mcp.json.template` (unless file exists; use `-Force` to overwrite) |

**Machine cache** (shared across all repos, not in git):

```
%USERPROFILE%\.matlab\
  agentic-toolkits\bin\matlab-mcp-server.exe
  matlab-agentic-toolkit\      # git clone — skill source
  matlab-rules\                # git clone — rule source
```

---

## Git: commit vs ignore

| Commit | Don't commit (regenerate with `install.ps1`) |
|--------|-----------------------------------------------|
| `matlab-kit/` | `.cursor/mcp.json` |
| `rules/<project>.mdc` | `.cursor/skills/matlab-*` junctions |
| `rules/mathworks-*.mdc` (optional) | |

---

## Update MathWorks skills later

```powershell
git -C "$env:USERPROFILE\.matlab\matlab-agentic-toolkit" pull
.\.cursor\matlab-kit\install.ps1 -SkillsOnly
```

---

## `groups.txt` cheat sheet

| Group | Add when |
|-------|----------|
| `matlab-core` | **Always** (required) |
| `signal-processing` | DSP, audio |
| `image-processing-and-computer-vision` | Imaging, CV |
| `ai-and-statistics` | ML, stats |

Fewer groups = better skill auto-trigger. Catalog: [skills-catalog](https://github.com/matlab/matlab-agentic-toolkit/tree/main/skills-catalog).

---

## Install.ps1 flags

```powershell
.\.cursor\matlab-kit\install.ps1                          # full install
.\.cursor\matlab-kit\install.ps1 -SkillsOnly              # refresh junctions only
.\.cursor\matlab-kit\install.ps1 -Force                   # overwrite mcp.json + rules
.\.cursor\matlab-kit\install.ps1 -MatlabRoot "D:\MATLAB\R2025b"
```

**Layout:** `matlab-kit` must live at `<repo>/.cursor/matlab-kit/` — not nested as `.cursor/.cursor/`. If you see that folder, delete it and re-run install (first script version had a path bug; fixed).

---

## Links

- [MATLAB org](https://github.com/matlab) · [Agentic Toolkit](https://github.com/matlab/matlab-agentic-toolkit) · [MCP Server](https://github.com/matlab/matlab-mcp-server) · [Rules](https://github.com/matlab/rules)
