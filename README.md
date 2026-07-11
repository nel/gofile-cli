# Gofile CLI

[![Test](https://github.com/nel/gofile-cli/actions/workflows/test.yml/badge.svg)](https://github.com/nel/gofile-cli/actions/workflows/test.yml)
[![Integration](https://github.com/nel/gofile-cli/actions/workflows/integration.yml/badge.svg)](https://github.com/nel/gofile-cli/actions/workflows/integration.yml)
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

Download the latest version directly from GitHub:

```sh
mkdir -p ~/.bin
curl -fsSL https://raw.githubusercontent.com/nel/gofile-cli/main/gofile -o ~/.bin/gofile
chmod 755 ~/.bin/gofile
```

Ensure `~/.bin` is included in your `PATH`.

To inspect or contribute to the source instead, clone the repository and run the executable from the checkout.

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
./tests/test_integration.sh
shellcheck gofile tests/*.sh
```

The unit test mocks `curl` and runs on every push and pull request. A separate integration test uploads two tiny files to Gofile every Monday and can also be started manually from GitHub Actions. Using two files ensures the live test covers guest authentication and folder reuse, including the API behavior that originally motivated this project.

## License

Released under the [MIT License](LICENSE).
