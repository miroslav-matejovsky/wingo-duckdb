# Running Go programs with embedded DuckDB on Windows

This repository demonstrates how to run Go programs with embedded DuckDB on Windows.

## Setup

DuckDB requires gcc and all necessary build tools to be installed on the system.

### MSYS2

Use scoop to install msys2, which provides the necessary build tools and gcc compiler.

```powershell
scoop install msys2
```

### GCC and runtime libraries

Open an MSYS2 terminal and run the following command to install the required packages as mentioned in the [DuckDB documentation](https://github.com/duckdb/duckdb-go#windows):

```bash
pacman -S mingw-w64-ucrt-x86_64-gcc
```

### Set environment variables

To ensure that correct gcc and runtime libraries are used, there is <taskfile/use-msys2-gcc.ps1> script that sets the necessary environment variables. Run this script in your PowerShell terminal before building or running the Go programs:

```powershell
pwsh -NoProfile -NonInteractive -File taskfile/use-msys2-gcc.ps1
go run ./cmd/...
```

Or simply run the task using Taskfile:

```powershell
task run
```


