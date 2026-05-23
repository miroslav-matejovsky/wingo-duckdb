<#
.SYNOPSIS
    Project-local MSYS2 GCC setup for Go + cgo builds.

.DESCRIPTION
    This script configures a PowerShell session (or a single command execution)
    to use GCC from MSYS2 instead of any globally installed compiler.

    It ensures that:
      - Go (cgo) uses a specific GCC (from MSYS2)
      - The correct MSYS2 runtime binaries are available via PATH

    This avoids conflicts when multiple GCC installations exist (e.g. Scoop GCC vs MSYS2 GCC).

    Note:
      The script currently targets the UCRT64 toolchain (C:\msys64\ucrt64\bin),
      but this detail is intentionally not part of the script name to keep
      the abstraction focused on "using MSYS2 GCC".

.PARAMETER MsysRoot
    Optional path to MSYS2 installation root.
    If omitted, automatically resolved for Scoop-installed MSYS2.

.PARAMETER VerboseCheck
    Prints resolved paths and compiler information for verification.

.PARAMETER Command
    Optional command to run inside the configured environment.
    If provided, the script executes the command immediately.

.EXAMPLES

    Persist environment in current shell:
        . .\taskfile\use-msys2-gcc.ps1
        go build ./...

    Run a single command:
        .\taskfile\use-msys2-gcc.ps1 go build ./...

    Run with diagnostics:
        .\taskfile\use-msys2-gcc.ps1 -VerboseCheck
        go build ./...

    Run single command with diagnostics:
        .\taskfile\use-msys2-gcc.ps1 -VerboseCheck go build ./...

    Taskfile usage:
        powershell -NoProfile -ExecutionPolicy Bypass `
          -File .\taskfile\use-msys2-gcc.ps1 go build ./...

.ENVIRONMENT CHANGES (PROCESS-ONLY)

    PATH         -> MSYS2 toolchain bin is prepended
    CC           -> set to MSYS2 gcc.exe
    CXX          -> set to MSYS2 g++.exe
    CGO_ENABLED  -> forced to 1

    These changes apply only to the current PowerShell process.

#>

[CmdletBinding()]
param(
    [string]$MsysRoot,
    [switch]$VerboseCheck,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Command
)

$ErrorActionPreference = 'Stop'

function Get-ScoopMsysRoot {
    $msysCmd = Get-Command msys2.cmd -ErrorAction Stop
    $shimDir = Split-Path -Parent $msysCmd.Source
    $candidate = Join-Path $shimDir '..\apps\msys2\current'
    return (Resolve-Path $candidate).Path
}

if (-not $MsysRoot) {
    $MsysRoot = Get-ScoopMsysRoot
}

$ucrtBin = Join-Path $MsysRoot 'ucrt64\bin'
$gcc = Join-Path $ucrtBin 'gcc.exe'
$gxx = Join-Path $ucrtBin 'g++.exe'

if (-not (Test-Path $gcc)) {
    throw "MSYS2 gcc not found: $gcc"
}

# -----------------------------------------------------------------------------
# Set compiler explicitly for cgo
# -----------------------------------------------------------------------------

$env:CC = $gcc
$env:CXX = $gxx
$env:CGO_ENABLED = '1'

# -----------------------------------------------------------------------------
# Ensure MSYS2 bin is first in PATH
# -----------------------------------------------------------------------------

$pathParts = $env:PATH -split ';' | Where-Object { $_ -ne '' }
$normalizedUcrt = [IO.Path]::GetFullPath($ucrtBin).TrimEnd('\')

$alreadyPresent = $false
foreach ($p in $pathParts) {
    try {
        if ([IO.Path]::GetFullPath($p).TrimEnd('\') -ieq $normalizedUcrt) {
            $alreadyPresent = $true
            break
        }
    }
    catch {}
}

if (-not $alreadyPresent) {
    $env:PATH = "$ucrtBin;$env:PATH"
}

# -----------------------------------------------------------------------------
# Optional diagnostics
# -----------------------------------------------------------------------------

if ($VerboseCheck) {
    Write-Host "MSYS2 root : $MsysRoot"
    Write-Host "Toolchain  : $ucrtBin"
    Write-Host "CC         : $env:CC"
    Write-Host "CXX        : $env:CXX"
    Write-Host "CGO_ENABLED: $env:CGO_ENABLED"
    Write-Host "gcc(used)  : $(& $env:CC --version | Select-Object -First 1)"
    Write-Host "go env CC  : $(go env CC)"
    Write-Host "which gcc  : $(Get-Command gcc | Select-Object -ExpandProperty Source)"
}

# -----------------------------------------------------------------------------
# Execute command if provided
# -----------------------------------------------------------------------------

if ($Command -and $Command.Count -gt 0) {
    & $Command[0] @($Command | Select-Object -Skip 1)
    exit $LASTEXITCODE
}