// extract-config — pulls the embedded Psiphon network config out of an
// official Conduit release binary and writes it as psiphon_config.json
// in the current directory.
//
// The official Conduit binary (from Psiphon's GitHub Releases) embeds its
// psiphon_config.json via Go's //go:embed directive. This tool finds that
// JSON blob inside the binary and copies it to a file. It's only copying
// data that's already in the binary you downloaded — nothing fancy.
//
// Usage:
//   extract-config <path-to-official-conduit-binary>
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
)

const outputFile = "psiphon_config.json"

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintln(os.Stderr, "Usage: extract-config <path-to-official-conduit-binary>")
		fmt.Fprintln(os.Stderr, "")
		fmt.Fprintln(os.Stderr, "Tip: just type './extract-config ' then drag the official")
		fmt.Fprintln(os.Stderr, "Conduit binary into your terminal window. It will paste the path.")
		os.Exit(2)
	}

	data, err := os.ReadFile(os.Args[1])
	if err != nil {
		fmt.Fprintf(os.Stderr, "Cannot read file: %v\n", err)
		os.Exit(1)
	}

	needle := []byte(`"PropagationChannelId"`)
	pos := bytes.Index(data, needle)
	if pos < 0 {
		fmt.Fprintln(os.Stderr, "Could not find a Psiphon config inside this file.")
		fmt.Fprintln(os.Stderr, "Are you sure this is an official Conduit binary from")
		fmt.Fprintln(os.Stderr, "https://github.com/Psiphon-Inc/conduit/releases ?")
		os.Exit(1)
	}

	start := bytes.LastIndexByte(data[:pos], '{')
	if start < 0 {
		fmt.Fprintln(os.Stderr, "Found marker but no opening brace before it.")
		os.Exit(1)
	}

	end := -1
	depth, inStr, esc := 0, false, false
	for i := start; i < len(data); i++ {
		c := data[i]
		if esc {
			esc = false
			continue
		}
		if c == '\\' && inStr {
			esc = true
			continue
		}
		if c == '"' {
			inStr = !inStr
			continue
		}
		if inStr {
			continue
		}
		switch c {
		case '{':
			depth++
		case '}':
			depth--
			if depth == 0 {
				end = i + 1
				break
			}
		}
		if end >= 0 {
			break
		}
	}
	if end < 0 {
		fmt.Fprintln(os.Stderr, "Could not find end of JSON object.")
		os.Exit(1)
	}

	blob := data[start:end]
	if err := json.Unmarshal(blob, new(any)); err != nil {
		fmt.Fprintf(os.Stderr, "Extracted bytes don't parse as JSON: %v\n", err)
		os.Exit(1)
	}

	if err := os.WriteFile(outputFile, blob, 0o644); err != nil {
		fmt.Fprintf(os.Stderr, "Could not write %s: %v\n", outputFile, err)
		os.Exit(1)
	}

	fmt.Fprintf(os.Stderr, "✓ Wrote %s (%d bytes) in the current folder.\n", outputFile, len(blob))
}
