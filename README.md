# Running Go programs with embedded DuckDB on Windows

This repository demonstrates how to run Go programs with embedded DuckDB on Windows using MSYS2 and GCC.

## Why this setup is required

The Go DuckDB driver uses CGO and requires a working GCC toolchain on Windows. [pkg.go.dev]

MSYS2 provides a compatible GCC toolchain and runtime.

## Setup

1. MSYS2 (via scoop)

    ```powershell
    scoop install msys2
    ```

2. GCC and runtime libraries

  Open an MSYS2 terminal and run the following command to install the required packages as mentioned in the [DuckDB documentation](https://github.com/duckdb/duckdb-go#windows):

    ```bash
    pacman -S mingw-w64-ucrt-x86_64-gcc
    ```
  
  This installs the GCC toolchain required for building Go programs with DuckDB on Windows.

## Running the application

To ensure that correct gcc and runtime libraries are used, there is <taskfile/use-msys2-gcc.ps1> script that sets the necessary environment variables. Run this script in your PowerShell terminal before building or running the Go programs:

```powershell
pwsh -NoProfile -NonInteractive -File taskfile/use-msys2-gcc.ps1
go run ./cmd/...
```

Or simply run the task using Taskfile:

```powershell
task run
```
