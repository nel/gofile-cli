# Gofile CLI

[![Test](https://github.com/nel/gofile-cli/actions/workflows/test.yml/badge.svg)](https://github.com/nel/gofile-cli/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A lightweight Bash CLI for uploading one or more files to a shared [Gofile](https://gofile.io) folder.

- Upload arguments, shell globs, or paths from standard input
- Group every upload into a single shareable folder
- Keep stdout pipe-safe by writing only the final URL there
- Show progress and status information on stderr
- Work without a registered Gofile account

## Requirements

- Bash 3.2 or later
- `curl`

## Installation

Clone the repository and install the executable somewhere on your `PATH`:

```sh
git clone https://github.com/nel/gofile-cli.git
cd gofile-cli
install -m 755 gofile ~/.bin/gofile
```

Ensure `~/.bin` is included in your `PATH`.

## Usage

```text
gofile [-q] [file ...]
```

Examples:

```console
gofile file1.mkv file2.mkv
ls *.mkv | gofile
gofile -q *.mkv | pbcopy
```

Use `-q` to hide progress and status output. The resulting folder URL is always written to stdout, making it safe to redirect or pipe into another command.

## How it works

The command creates a temporary Gofile guest account for each run. It uploads the first file into a new folder, then reuses that authenticated folder for all remaining files. Guest uploads are subject to Gofile's storage and retention policies.

## Development

```sh
./tests/test_gofile.sh
shellcheck gofile tests/test_gofile.sh
```

The tests mock `curl`, so they perform no network requests and upload no files. GitHub Actions runs the test suite and ShellCheck on every push and pull request.

## License

Released under the [MIT License](LICENSE).
