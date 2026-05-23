# Running Go programs with embedded DuckDB on Windows

This repository demonstrates how to run Go programs with embedded DuckDB on Windows using MSYS2 and GCC.

## Why this setup is required

The Go DuckDB driver uses CGO and requires a working GCC toolchain on Windows. [pkg.go.dev]

MSYS2 provides a compatible GCC toolchain and runtime.

## Setup

1. MSYS2 (via scoop) as a platform for GCC and runtime libraries.

    ```powershell
    scoop install msys2
    ```

2. GCC and runtime libraries <br>
   Open an MSYS2 terminal and run the following command to install the required packages as mentioned in the [DuckDB documentation](https://github.com/duckdb/duckdb-go#windows):

     ```bash
     pacman -S mingw-w64-ucrt-x86_64-gcc
     ```

   This installs the GCC toolchain required for building Go programs with DuckDB on Windows.

## Running the application

### Setting up the environment

To ensure that correct gcc and runtime libraries are used, there is [use-msys2-gcc.ps1](taskfile/use-msys2-gcc.ps1) script that sets the necessary environment variables.

```powershell
./taskfile/use-msys2-gcc.ps1 -VerboseCheck
```

Should provide something like this:

```text
MSYS2 root : C:\Users\Miroslav.Matejovsky\scoop\apps\msys2\current
Toolchain  : C:\Users\Miroslav.Matejovsky\scoop\apps\msys2\current\ucrt64\bin
CC         : C:\Users\Miroslav.Matejovsky\scoop\apps\msys2\current\ucrt64\bin\gcc.exe
CXX        : C:\Users\Miroslav.Matejovsky\scoop\apps\msys2\current\ucrt64\bin\g++.exe
CGO_ENABLED: 1
gcc(used)  : gcc.exe (Rev13, Built by MSYS2 project) 15.2.0
go env CC  : C:\Users\Miroslav.Matejovsky\scoop\apps\msys2\current\ucrt64\bin\gcc.exe
which gcc  : C:\Users\Miroslav.Matejovsky\scoop\apps\msys2\current\ucrt64\bin\gcc.exe
```

### Running the Go programs

Run the following commands in your PowerShell terminal to set up the environment and run the Go programs:

```powershell
pwsh -NoProfile -NonInteractive -File taskfile/use-msys2-gcc.ps1
go run ./cmd/...
```

Or simply run the task using Taskfile:

```powershell
task run
```
