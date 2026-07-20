---
name: matlab
description: >-
  MATLAB conventions for chamberlain and MathWorks MCP setup. Use when editing
  or creating .m files, penetration DB builders, or configuring MATLAB for Cursor.
---

# MATLAB (chamberlain)

## Why the VS Code “MATLAB” / Connected extension is not enough

The MathWorks extension gives **you** syntax highlighting, diagnostics, run/debug, and navigation in the editor. It does **not** inject that into the Cursor **agent** context. The agent will still guess MATLAB rules unless you add:

1. **MCP** — run/check code in real MATLAB  
2. **Skills / rules** — MCP setup (this file); chamberlain workflow + `.m` conventions (`.cursor/rules/matlab.mdc`)

## MCP setup (MathWorks official)

Full install/verify/troubleshooting: `.cursor/matlab_cursor_integration_readme.md`.  
Portable MathWorks rules + skills: `.cursor/matlab-kit/README.md` + `install.ps1`.  
Project workflow: `.cursor/rules/matlab.mdc`.

### 1. Install binary

1. MATLAB **R2021a+** on PATH (you have R2025b at `C:\Program Files\MATLAB\R2025b\bin\matlab.exe`).
2. Download **MATLAB MCP Server** for Windows from [github.com/matlab/matlab-mcp-server/releases](https://github.com/matlab/matlab-mcp-server/releases) (`matlab-mcp-server-win64.exe`).
3. Put it somewhere stable, e.g. `%USERPROFILE%\.matlab\agentic-toolkits\bin\matlab-mcp-server.exe`.
4. Once:  
   `matlab-mcp-server.exe --setup-matlab --matlab-root="C:\Program Files\MATLAB\R2025b"`

### 2. Cursor config

**Global** (`%USERPROFILE%\.cursor\mcp.json`) — chamberlain uses this only (no project `.cursor/mcp.json`):

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

Adjust paths. Restart Cursor fully. In Agent chat, MCP should expose tools like `evaluate_matlab_code`, `run_matlab_file`, `check_matlab_code`.

### 3. Reuse open MATLAB (optional)

In MATLAB R2023a+:

```matlab
shareMATLABSession()   % no arguments
```

Run once per MATLAB session (or add to `startup.m`). With `--matlab-session-mode=auto` (default), MCP attaches to that session if available; use `existing` to require attach-only.

### 4. Verify

Ask the agent to list MCP tools, or run a trivial `evaluate_matlab_code` on `2+2`.

## Optional: MathWorks Agentic Toolkit skills

Broader domain skills (debugging, toolboxes, etc.): [github.com/matlab/matlab-agentic-toolkit](https://github.com/matlab/matlab-agentic-toolkit). Cursor setup is **manual** (copy MCP template, install skills). Not required for chamberlain if you use project rule + MCP core server.

## chamberlain patterns

See `.cursor/rules/matlab.mdc` for workflow, checklist, and prompt patterns.
