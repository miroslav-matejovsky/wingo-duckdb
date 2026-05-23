package main

import (
	"fmt"
	"os"

	_ "github.com/duckdb/duckdb-go/v2"
)

func main() {
	if err := doChecks(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	runDuckDB()
}
