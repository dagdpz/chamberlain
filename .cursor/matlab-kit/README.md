# Portable MATLAB + Cursor kit

**Start here:** [QUICKSTART.md](QUICKSTART.md) · Full reference: this file.

Paste **`.cursor/matlab-kit/`** (and run `install.ps1`) into any MATLAB project. Combines:

| Source | Role in Cursor |
|--------|----------------|
| [matlab-mcp-server](https://github.com/matlab/matlab-mcp-server) | MCP tools (`evaluate_matlab_code`, …) — **machine install**, not in this folder |
| [matlab-agentic-toolkit](https://github.com/matlab/matlab-agentic-toolkit) | Official **skills** (testing, debugging, toolboxes, …) — linked from one clone |
| [matlab/rules](https://github.com/matlab/rules) | Official **coding rules** — copied into `.cursor/rules/` as `mathworks-*.mdc` |
| Project | `.cursor/rules/<project>.mdc` + optional `.cursor/skills/<project>/` |

Chamberlain example: `rules/matlab.mdc` (project workflow) on top of MathWorks rules.

---

## Architecture

```
Machine (once per PC)                    Per project (paste + install)
─────────────────────                    ─────────────────────────────
%USERPROFILE%\.matlab\
  agentic-toolkits\bin\
    matlab-mcp-server.exe                .cursor/
  matlab-agentic-toolkit\  (git)           matlab-kit/          ← portable bundle
    skills-catalog/...                     install.ps1
  matlab-rules\            (git)           groups.txt
                                           mcp.json.template
                                         rules/
                                           mathworks-*.mdc      ← from install
                                           <project>.mdc        ← you add
                                         skills/
                                           matlab-testing/      ← symlinks
                                           matlab-debugging/
                                           <project>/           ← optional
                                         mcp.json               ← from template
```

**MCP binary stays global** (license, size). **Skills stay one clone** (large, updated with `git pull`). **Rules are copied** into the project (small, versionable). **Project workflow** is one extra `.mdc` file.

---

## One-time machine setup

### 1. MCP server + MATLAB toolbox

See `.cursor/matlab_cursor_integration_readme.md` or:

```powershell
$bin = "$env:USERPROFILE\.matlab\agentic-toolkits\bin"
New-Item -ItemType Directory -Force -Path $bin | Out-Null
# Download matlab-mcp-server-windows-x64.exe from GitHub releases → $bin\matlab-mcp-server.exe
& "$bin\matlab-mcp-server.exe" --setup-matlab --matlab-root="C:\Program Files\MATLAB\R2025b"
```

### 2. Run kit installer (also clones MathWorks repos)

From the project root:

```powershell
.\.cursor\matlab-kit\install.ps1
```

This clones/updates:

- `%USERPROFILE%\.matlab\matlab-agentic-toolkit`
- `%USERPROFILE%\.matlab\matlab-rules`

Then links skills, installs rules. Writes project `.cursor/mcp.json` only if global MCP config has no `matlab` entry (or pass `-WriteMcpJson`).

### 3. Restart Cursor

Full quit and reopen so MCP loads.

### 4. Verify

In Agent: `List MCP tools and run 2+2 in MATLAB`

---

## New MATLAB project (paste workflow)

1. Copy into the repo:
   ```
   .cursor/matlab-kit/     # entire folder
   ```
2. Add project rule (optional): `.cursor/rules/myproject.mdc`
3. Edit `matlab-kit/groups.txt` — pick skill groups (start minimal; see below)
4. Run:
   ```powershell
   .\.cursor\matlab-kit\install.ps1
   ```
5. Restart Cursor (MCP from global `%USERPROFILE%\.cursor\mcp.json` unless you used `-WriteMcpJson`)

**Alternative:** keep `matlab-kit` in a dotfiles repo and symlink `\.cursor\matlab-kit` into each project.

### Git (recommended)

| Commit | Ignore |
|--------|--------|
| `matlab-kit/` | `.cursor/mcp.json` (machine paths; use template) |
| `rules/<project>.mdc` | `.cursor/skills/matlab-*` junctions (re-run installer) |
| `rules/mathworks-*.mdc` (optional — or regenerate) | |

---

## Skill groups (`groups.txt`)

**Required:** `matlab-core`

Pick only what you need — fewer skills = more reliable auto-trigger ([MathWorks guidance](https://github.com/matlab/matlab-agentic-toolkit/blob/main/Configuration_and_Troubleshooting.md#skills-not-auto-loading)).

| Group | When |
|-------|------|
| `matlab-core` | Always |
| `signal-processing` | DSP, audio, wavelets |
| `image-processing-and-computer-vision` | Images, CV, medical imaging |
| `ai-and-statistics` | ML, stats |
| `matlab-programming` | Input validation, robust functions |

Full catalog: [skills-catalog](https://github.com/matlab/matlab-agentic-toolkit/tree/main/skills-catalog)

Update skills later:

```powershell
git -C "$env:USERPROFILE\.matlab\matlab-agentic-toolkit" pull
.\.cursor\matlab-kit\install.ps1 -SkillsOnly
```

---

## Rules layering

| File | Source |
|------|--------|
| `mathworks-matlab-coding-standards.mdc` | [matlab/rules](https://github.com/matlab/rules) |
| `mathworks-live-script-generation.mdc` | matlab/rules |
| `mathworks-matlab-performance-optimization.mdc` | matlab/rules |
| `<project>.mdc` | Your repo conventions (e.g. `matlab.mdc` in chamberlain) |

MCP also exposes `guidelines://coding` at runtime — rules above are for **editor/agent context** before MCP runs.

---

## MCP: global vs project

| Config | Path | Use |
|--------|------|-----|
| Global | `%USERPROFILE%\.cursor\mcp.json` | **Default** — one MATLAB MCP config for all projects |
| Project | `<repo>/.cursor/mcp.json` | Only if no global config; use `install.ps1 -WriteMcpJson` |

`install.ps1` skips project `mcp.json` when global already defines `matlab`.

For BrainVoyager figures: open MATLAB → `shareMATLABSession()` → keep `--matlab-session-mode=auto`.

---

## Cursor vs official MathWorks installer

MathWorks [agenticToolkitInstaller.mltbx](https://github.com/matlab/simulink-agentic-toolkit/releases) + `setupAgenticToolkit("install")` is the supported path for Claude Code / Copilot. **Cursor is manual** ([experimental](https://github.com/matlab/matlab-agentic-toolkit)) — this kit is that manual path.

---

## Links

- [MATLAB org on GitHub](https://github.com/matlab)
- [MATLAB Agentic Toolkit](https://github.com/matlab/matlab-agentic-toolkit)
- [MATLAB MCP Server](https://github.com/matlab/matlab-mcp-server)
- [MATLAB AI Coding Rules](https://github.com/matlab/rules)
