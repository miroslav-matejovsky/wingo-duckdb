package main

import (
	"bytes"
	"fmt"
	"os/exec"
)

func doChecks() error {
	if err := checkMsys2(); err != nil {
		return err
	}
	fmt.Println("All checks passed!")
	return nil
}

func checkMsys2() error {
	// find msys2 installation via Get-Command msys2 in powershell
	shellCmd := "powershell -NoProfile -NonInteractive -Command \"(Get-Command msys2).Source\""
	output, error, err := runPowerShell(shellCmd)
	if err != nil {
		return fmt.Errorf("msys2 not found in PATH: %w, stderr: %s", err, error)
	}
	fmt.Printf("msys2 found at: %s\n", output)
	return nil
}

func runPowerShell(command string) (string, string, error) {
	cmd := exec.Command("powershell.exe",
		"-NoProfile",
		"-NonInteractive",
		"-ExecutionPolicy", "Bypass",
		"-Command", command,
	)

	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()

	return stdout.String(), stderr.String(), err
}
