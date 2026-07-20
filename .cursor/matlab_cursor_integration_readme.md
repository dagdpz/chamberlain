# MATLAB + Cursor integration (chamberlain)

How to run, check, and plot MATLAB code from Cursor Agent using MathWorks MCP, plus repo conventions.

**Portable kit:** `.cursor/matlab-kit/QUICKSTART.md` — paste into new repos.

## What you need (three layers)

| Layer | File / config | What it does |
|-------|----------------|--------------|
| **MCP** | `%USERPROFILE%\.cursor\mcp.json` | Agent runs real MATLAB (`evaluate_matlab_code`, etc.) |
| **Skill** | `.cursor/skills/matlab/SKILL.md` | Bootstrap; MathWorks skills via `matlab-kit/install.ps1` |
| **Rule** | `.cursor/rules/matlab.mdc` | Auto-applies on `**/*.m` (chamberlain workflow) |
| **MathWorks rules** | `.cursor/rules/mathworks-*.mdc` | From [matlab/rules](https://github.com/matlab/rules) via installer |

The **MathWorks VS Code / Connected extension** gives *you* syntax highlighting, diagnostics, and Run/Debug in the editor. It does **not** give the agent MATLAB execution or chamberlain conventions — that requires MCP + skill/rule above.

---

## One-time installation

### Prerequisites

- MATLAB **R2021a+** (this machine: **R2025b** at `C:\Program Files\MATLAB\R2025b`)
- MATLAB on PATH (or set `--matlab-root` explicitly)

### 1. Download MATLAB MCP Server

From [github.com/matlab/matlab-mcp-server/releases](https://github.com/matlab/matlab-mcp-server/releases) (v0.11.2+):

- Windows asset: `matlab-mcp-server-windows-x64.exe`
- Copy/rename to a stable path, e.g.  
  `C:\Users\i.kagan\.matlab\agentic-toolkits\bin\matlab-mcp-server.exe`

PowerShell example:

```powershell
$binDir = "$env:USERPROFILE\.matlab\agentic-toolkits\bin"
New-Item -ItemType Directory -Force -Path $binDir | Out-Null
Invoke-WebRequest -Uri "https://github.com/matlab/matlab-mcp-server/releases/download/v0.11.2/matlab-mcp-server-windows-x64.exe" `
  -OutFile "$binDir\matlab-mcp-server.exe"
```

### 2. Install MATLAB toolbox (once)

```powershell
& "$env:USERPROFILE\.matlab\agentic-toolkits\bin\matlab-mcp-server.exe" `
  --setup-matlab `
  --matlab-root="C:\Program Files\MATLAB\R2025b"
```

Expect: `Successfully setup MATLAB.`  
Installs **MATLAB MCP Server Toolbox** (required for attaching to an open MATLAB session).

### 3. Configure Cursor MCP

**Active config (global, all workspaces):**  
`C:\Users\i.kagan\.cursor\mcp.json`

**Template in repo (reference only):**  
`chamberlain/.cursor/matlab-kit/mcp.json.template`

Chamberlain uses **global** `%USERPROFILE%\.cursor\mcp.json` only — no project `.cursor/mcp.json`.

```json
{
  "mcpServers": {
    "matlab": {
      "command": "C:\\Users\\i.kagan\\.matlab\\agentic-toolkits\\bin\\matlab-mcp-server.exe",
      "args": [
        "--matlab-root=C:\\Program Files\\MATLAB\\R2025b",
        "--matlab-session-mode=auto"
      ]
    }
  }
}
```

- Use **global** `mcp.json` for MCP (this machine). `install.ps1` skips project `mcp.json` when global already defines `matlab`.

### 4. Restart Cursor

Quit all Cursor windows and reopen. MCP servers load at startup; changes to `mcp.json` require a full restart.

---

## Verify setup

In **Agent** chat:

```
List MCP tools and run 2+2 in MATLAB
```

**Expected:**

- Server status: ready (in Cursor UI may appear as **`user-matlab`**, not `matlab` — same binary)
- Tools: `detect_matlab_toolboxes`, `check_matlab_code`, `evaluate_matlab_code`, `run_matlab_file`, `run_matlab_test_file`
- `2+2` → `ans = 4`

**Figure test:**

```
Open a figure in MATLAB
```

Agent should run something like `figure; plot(...)` — figure appears in your **MATLAB desktop** when attached to a shared session.

---

## MCP tools reference

| Tool | Use |
|------|-----|
| `detect_matlab_toolboxes` | List installed MATLAB version and toolboxes before codegen |
| `check_matlab_code` | Static analysis on a `.m` file (no execution) |
| `evaluate_matlab_code` | Run a code string; optional `project_path` sets `cd` |
| `run_matlab_file` | Execute a script by absolute path |
| `run_matlab_test_file` | Run MATLAB unit tests |

**MCP resources** (guidelines for the agent):

- `guidelines://coding` — MATLAB coding standards
- `guidelines://plain-text-live-code` — live script `.m` format (R2025a+)

---

## Session modes: new MATLAB vs your open MATLAB

By default MCP may start a **separate** MATLAB. To use **your** open session (BrainVoyager on path, figures on desktop, same workspace):

### In MATLAB (once per session)

```matlab
shareMATLABSession()   % NO arguments — not shareMATLABSession("allow")
```

Or add to `startup.m` if you always want sharing.

### In `mcp.json`: `--matlab-session-mode`

| Mode | Behavior |
|------|----------|
| `auto` **(default)** | Try attach to shared session; if none, start new MATLAB |
| `existing` | Attach only — **fail** if no `shareMATLABSession()` |
| `new` | Always start fresh MATLAB |

For BrainVoyager / slice plots: open MATLAB → `shareMATLABSession()` → keep `auto` (or use `existing` to forbid silent second instances).

### Optional args

| Arg | Notes |
|-----|--------|
| `--matlab-display-mode=desktop` | Show MATLAB UI (default) |
| `--matlab-display-mode=nodesktop` | Headless; GUI commands may still pop windows |
| `--initialize-matlab-on-startup=true` | Start MATLAB when MCP server starts |
| `--disable-telemetry=true` | Opt out of MathWorks anonymized telemetry |

---

## How skill + rule work in Agent

```
You prompt in Agent mode
        ↓
Skill: .cursor/skills/matlab/SKILL.md     (MCP setup)
Rule:  .cursor/rules/matlab.mdc           (chamberlain workflow + **/*.m conventions)
        ↓
MCP: real MATLAB execution                  (required before claiming "works")
```

**Chamberlain workflow, checklist, and prompt patterns:** see `.cursor/rules/matlab.mdc` (auto-applied on `**/*.m`).

**Generic MCP prompts** (not chamberlain-specific): `detect_matlab_toolboxes` before codegen; `List MCP tools and run 2+2 in MATLAB` to verify.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| No MCP tools in Agent | Full Cursor restart; check `%USERPROFILE%\.cursor\mcp.json` |
| `shareMATLABSession` "Too many input arguments" | Use `shareMATLABSession()` with **no** args |
| MCP starts second MATLAB | Run `shareMATLABSession()` in the one you want; or set `existing` mode |
| Figures not visible | Attach to desktop session (`shareMATLABSession` + `auto`/`existing`); check MATLAB not minimized |
| Attach fails after MATLAB restart | Run `shareMATLABSession()` again |
| `check_matlab_code` false positives | Verify with `evaluate_matlab_code` |
| Permission / toolbox errors after upgrade | Re-run `--setup-matlab`; see [matlab-mcp-server issues](https://github.com/matlab/matlab-mcp-server/issues) |

**Logs:** MCP server writes to OS temp unless `--log-folder` is set.

---

## Optional: MathWorks Agentic Toolkit

Official skills (testing, debugging, toolboxes): install via `.cursor/matlab-kit/install.ps1` — links [matlab-agentic-toolkit](https://github.com/matlab/matlab-agentic-toolkit) skill groups from `groups.txt`.

Broader setup (MATLAB installer UI): `setupAgenticToolkit("install")` from [agenticToolkitInstaller.mltbx](https://github.com/matlab/simulink-agentic-toolkit/releases). Cursor path is manual; use `matlab-kit` instead.

---

## Links

- [MATLAB org on GitHub](https://github.com/matlab)
- [MATLAB Agentic Toolkit](https://github.com/matlab/matlab-agentic-toolkit)
- [MATLAB AI Coding Rules](https://github.com/matlab/rules)
- Portable kit: `.cursor/matlab-kit/README.md`
