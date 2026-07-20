#Requires -Version 5.1
<#
.SYNOPSIS
  Install MathWorks rules + skills into .cursor for this project.

.DESCRIPTION
  - Clones/updates matlab-agentic-toolkit and matlab/rules under %USERPROFILE%\.matlab\
  - Symlinks selected skill groups into .cursor/skills/
  - Copies MathWorks rules into .cursor/rules/ as mathworks-*.mdc
  - Writes .cursor/mcp.json from mcp.json.template

.EXAMPLE
  .\.cursor\matlab-kit\install.ps1
  .\.cursor\matlab-kit\install.ps1 -MatlabRoot "D:\MATLAB\R2025b" -SkillsOnly
#>
param(
    [string]$MatlabRoot = "C:\Program Files\MATLAB\R2025b",
    [string]$McpServer = "$env:USERPROFILE\.matlab\agentic-toolkits\bin\matlab-mcp-server.exe",
    [switch]$SkillsOnly,
    [switch]$Force,
    [switch]$WriteMcpJson
)

$ErrorActionPreference = "Stop"
$KitDir = $PSScriptRoot
$CursorDir = (Resolve-Path (Join-Path $KitDir "..")).Path
$ProjectRoot = (Resolve-Path (Join-Path $CursorDir "..")).Path
if ((Split-Path $CursorDir -Leaf) -ne '.cursor') {
    throw "Expected matlab-kit under <repo>/.cursor/matlab-kit; got KitDir=$KitDir"
}
if ((Split-Path $ProjectRoot -Leaf) -eq '.cursor') {
    throw "Project root resolved to .cursor (wrong). Run from <repo>/.cursor/matlab-kit/install.ps1"
}
$SkillsDir = Join-Path $CursorDir "skills"
$RulesDir = Join-Path $CursorDir "rules"
$MatlabCache = Join-Path $env:USERPROFILE ".matlab"
$ToolkitRepo = Join-Path $MatlabCache "matlab-agentic-toolkit"
$RulesRepo = Join-Path $MatlabCache "matlab-rules"
$GroupsFile = Join-Path $KitDir "groups.txt"

function Ensure-GitRepo {
    param([string]$Url, [string]$Path)
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "git is required. Install Git and re-run."
    }
    if (-not (Test-Path $Path)) {
        Write-Host "Cloning $Url -> $Path"
        New-Item -ItemType Directory -Force -Path (Split-Path $Path) | Out-Null
        git clone --depth 1 $Url $Path
    } else {
        Write-Host "Updating $Path"
        git -C $Path pull --ff-only
    }
}

function Get-SkillGroups {
    Get-Content $GroupsFile |
        Where-Object { $_ -and -not $_.TrimStart().StartsWith("#") } |
        ForEach-Object { $_.Trim() }
}

function New-RuleMdc {
    param([string]$SourceMd, [string]$DestMdc, [string]$Description, [string]$Globs = "**/*.m")
    $body = Get-Content -Raw -Path $SourceMd
    $front = @"
---
description: $Description
globs: $Globs
alwaysApply: false
---

"@
    Set-Content -Path $DestMdc -Value ($front + $body) -Encoding utf8
    Write-Host "  rule: $(Split-Path $DestMdc -Leaf)"
}

function Install-Rules {
    $map = @{
        "matlab-coding-standards.md" = @{
            Out = "mathworks-matlab-coding-standards.mdc"
            Desc = "MathWorks MATLAB coding standards (naming, formatting, functions)"
        }
        "live-script-generation.md" = @{
            Out = "mathworks-live-script-generation.mdc"
            Desc = "MathWorks plain-text Live Script generation rules"
            Globs = "**/*.{m,mlx}"
        }
        "matlab-performance-optimization.md" = @{
            Out = "mathworks-matlab-performance-optimization.mdc"
            Desc = "MathWorks MATLAB performance and memory optimization"
        }
    }
    New-Item -ItemType Directory -Force -Path $RulesDir | Out-Null
    foreach ($entry in $map.GetEnumerator()) {
        $src = Join-Path $RulesRepo $entry.Key
        if (-not (Test-Path $src)) { throw "Missing rule file: $src" }
        $dest = Join-Path $RulesDir $entry.Value.Out
        if ($Force -or -not (Test-Path $dest)) {
            New-RuleMdc -SourceMd $src -DestMdc $dest -Description $entry.Value.Desc -Globs $(if ($entry.Value.Globs) { $entry.Value.Globs } else { "**/*.m" })
        }
    }
}

function New-SkillLink {
    param([string]$LinkPath, [string]$TargetPath)
    if (Test-Path $LinkPath) { return }
    try {
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -ErrorAction Stop | Out-Null
    } catch {
        # Junction works without admin / Developer Mode on Windows
        cmd /c mklink /J "$LinkPath" "$TargetPath" | Out-Null
        if (-not (Test-Path $LinkPath)) { throw "Failed to link $LinkPath -> $TargetPath. Enable Developer Mode or run as Administrator." }
    }
}

function Install-SkillLinks {
    New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null
    foreach ($group in Get-SkillGroups) {
        $groupPath = Join-Path $ToolkitRepo "skills-catalog\$group"
        if (-not (Test-Path $groupPath)) {
            throw "Unknown skill group '$group'. Check groups.txt and skills-catalog/ in matlab-agentic-toolkit."
        }
        Get-ChildItem -Path $groupPath -Directory | ForEach-Object {
            $linkPath = Join-Path $SkillsDir $_.Name
            if (Test-Path $linkPath) {
                if ($Force) { Remove-Item $linkPath -Recurse -Force }
                else { return }
            }
            Write-Host "  skill: $($_.Name) <- $group"
            New-SkillLink -LinkPath $linkPath -TargetPath $_.FullName
        }
    }
}

function Install-McpJson {
    $globalMcp = Join-Path $env:USERPROFILE ".cursor\mcp.json"
    if (-not $WriteMcpJson -and (Test-Path $globalMcp)) {
        $globalText = Get-Content -Raw $globalMcp
        if ($globalText -match '"matlab"') {
            Write-Host "Skipping project mcp.json (using global $globalMcp). Use -WriteMcpJson to create local copy."
            return
        }
    }
    if ((Test-Path (Join-Path $CursorDir "mcp.json")) -and -not $Force) {
        Write-Host "Keeping existing .cursor/mcp.json (use -Force to overwrite)"
        return
    }
    $template = Get-Content -Raw (Join-Path $KitDir "mcp.json.template")
    $json = $template `
        -replace "__MCP_SERVER__", ($McpServer -replace "\\", "\\") `
        -replace "__MATLAB_ROOT__", $MatlabRoot `
        -replace "__PROJECT_ROOT__", ($ProjectRoot -replace "\\", "\\")
    Set-Content -Path (Join-Path $CursorDir "mcp.json") -Value $json -Encoding utf8
    Write-Host "Wrote .cursor/mcp.json"
}

Write-Host "MATLAB Cursor kit -> $ProjectRoot"
New-Item -ItemType Directory -Force -Path $CursorDir | Out-Null

Ensure-GitRepo -Url "https://github.com/matlab/matlab-agentic-toolkit.git" -Path $ToolkitRepo
if (-not $SkillsOnly) {
    Ensure-GitRepo -Url "https://github.com/matlab/rules.git" -Path $RulesRepo
}

Write-Host "Linking skills from groups.txt..."
Install-SkillLinks

if (-not $SkillsOnly) {
    Write-Host "Installing MathWorks rules..."
    Install-Rules
    if (-not (Test-Path $McpServer)) {
        Write-Warning "MCP server not found at: $McpServer"
        Write-Warning "Download from https://github.com/matlab/matlab-mcp-server/releases and run --setup-matlab"
    }
    Install-McpJson
}

Write-Host "Done. Restart Cursor. Verify: 'List MCP tools and run 2+2 in MATLAB'"
