# Gofile CLI

[![Test](https://github.com/nel/gofile-cli/actions/workflows/test.yml/badge.svg)](https://github.com/nel/gofile-cli/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A lightweight command-line tool for uploading one or more files to a shared [Gofile](https://gofile.io) folder. It is implemented in Bash and works normally when called from Bash, Zsh, and other POSIX-style interactive shells.

- Upload arguments, shell globs, or paths from standard input
- Group every upload into a single shareable folder
- Keep stdout pipe-safe by writing only the final URL there
- Show progress and status information on stderr
- Open a pre-addressed email draft containing the link
- Work without a registered Gofile account

## Requirements

- Bash 3.2 or later as the script runtime
- `curl`

You do not need to use Bash as your interactive shell. Running `gofile` from Zsh works because the executable's `#!/usr/bin/env bash` shebang starts Bash automatically. The command accepts ordinary paths, globs expanded by the calling shell, and newline-separated paths over standard input. It is tested when invoked from both Bash and Zsh.

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
gofile [-nq] [file ...]
```

Examples:

```console
gofile file1.mkv file2.mkv
ls *.mkv | gofile
gofile -q *.mkv | pbcopy
gofile -n movie.mkv
```

Use `-q` to hide progress and status output. The resulting folder URL is always written to stdout, making it safe to redirect or pipe into another command.

### Email drafts

To open a draft in the system's default mail application after a successful upload, create `~/.gofile`:

```ini
EMAIL_TO=someone@example.com
EPISODE_LIST_LIMIT=6
```

This uses the standard `mailto:` URL scheme. Its body contains only the Gofile link. The subject is derived from the first successfully uploaded filename:

- `The-Show_Name.S01E03.1080p.WEB-DL.mkv` becomes `The Show Name — S01E03`.
- Uploading up to `EPISODE_LIST_LIMIT` distinct episodes lists every episode number.
- Larger batches are summarized as `The Show — Season 1` or `The Show — Seasons 1, 2`.
- `Some.Movie.2025.2160p.mkv` becomes `Some Movie (2025)`.

For browser-based webmail, provide a compose URL template. The `{to}`, `{subject}`, and `{body}` placeholders are replaced with URL-encoded values. For example, Gmail can be configured without making it the command's default:

```ini
EMAIL_TO=someone@example.com
EMAIL_COMPOSE_URL=https://mail.google.com/mail/?view=cm&fs=1&to={to}&su={subject}&body={body}
EPISODE_LIST_LIMIT=6
```

This URL is opened in the default browser, so it does not invoke Apple Mail. Other webmail services can be used if they expose an equivalent compose URL. There is no common standard for webmail compose URLs, so consult the service's documentation and adapt the template parameters as needed.

Use `-n` to skip opening a draft for one upload. Environment variables named `GOFILE_EMAIL_TO`, `GOFILE_EMAIL_COMPOSE_URL`, and `GOFILE_EPISODE_LIST_LIMIT` override the corresponding config values. Set `GOFILE_CONFIG` to use a config file in another location.

## How it works

The command creates a temporary Gofile guest account for each run. It uploads the first file into a new folder, then reuses that authenticated folder for all remaining files. If email drafting is configured, it URL-encodes the recipient, cleaned subject, and link, inserts them into either a standard `mailto:` URL or the configured webmail template, and asks the operating system to open it. Guest uploads are subject to Gofile's storage and retention policies.

## Development

```sh
./tests/test_gofile.sh
shellcheck gofile tests/*.sh
```

The test suite checks request handling with a mocked `curl`, then uploads two tiny files to the real Gofile service. Using two files ensures it covers guest authentication and folder reuse, including the API behavior that originally motivated this project. GitHub Actions runs the complete suite on every push and pull request, weekly, and on manual request.

## License

Released under the [MIT License](LICENSE).
