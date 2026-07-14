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
2. **Skills / rules** — repo conventions (this file + `.cursor/rules/matlab.mdc`)

## MCP setup (MathWorks official)

Your global config is empty: `%USERPROFILE%\.cursor\mcp.json` has `"mcpServers": {}`.

### 1. Install binary

1. MATLAB **R2021a+** on PATH (you have R2025b at `C:\Program Files\MATLAB\R2025b\bin\matlab.exe`).
2. Download **MATLAB MCP Server** for Windows from [github.com/matlab/matlab-mcp-server/releases](https://github.com/matlab/matlab-mcp-server/releases) (`matlab-mcp-server-win64.exe`).
3. Put it somewhere stable, e.g. `%USERPROFILE%\.matlab\agentic-toolkits\bin\matlab-mcp-server.exe`.
4. Once:  
   `matlab-mcp-server.exe --setup-matlab --matlab-root="C:\Program Files\MATLAB\R2025b"`

### 2. Cursor config

**Global** (`%USERPROFILE%\.cursor\mcp.json`) or **project** (`chamberlain/.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "matlab": {
      "command": "C:\\Users\\i.kagan\\.matlab\\agentic-toolkits\\bin\\matlab-mcp-server.exe",
      "args": [
        "--matlab-root=C:\\Program Files\\MATLAB\\R2025b",
        "--initial-working-folder=E:\\Dropbox\\Sources\\Repos\\chamberlain",
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
shareMATLABSession("allow")
```

Then use `--matlab-session-mode=existing` (after `--setup-matlab` installed the toolbox).

### 4. Verify

Ask the agent to list MCP tools, or run a trivial `evaluate_matlab_code` on `2+2`.

## Optional: MathWorks Agentic Toolkit skills

Broader domain skills (debugging, toolboxes, etc.): [github.com/matlab/matlab-agentic-toolkit](https://github.com/matlab/matlab-agentic-toolkit). Cursor setup is **manual** (copy MCP template, install skills). Not required for chamberlain if you use project rule + MCP core server.

## chamberlain patterns

- **Template:** `cl_example_create_penetration_db.m` — generic, placeholder paths.  
- **Real project:** `Pulv_bodysignals/cl_pulv_bodysignals_bacchus_build_db.m` — full paths, calls `cl_create_penetration_db`.  
- **Engine:** `cl_create_penetration_db.m` — do not duplicate Excel/MAT logic in project files.

Header examples must be **literal MATLAB** the user can run, not opaque mode strings.

## Agent checklist for new `.m` files

- [ ] Script OR function file — never mix script + functions  
- [ ] Runnable `Example:` block at top of help  
- [ ] `cl_` naming matches repo layout  
- [ ] If MCP available: run or syntax-check changed files
