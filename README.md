# gofile-cli

A small Bash CLI that uploads files to one shared [Gofile](https://gofile.io) folder and prints a pipe-safe download URL.

```console
gofile file1.mkv file2.mkv
ls *.mkv | gofile
gofile -q *.mkv | pbcopy
```

Progress and summaries go to stderr; only the final folder URL goes to stdout. The command creates a temporary Gofile guest account for each run and reuses its authenticated folder for all input files.

## Install

```sh
install -m 755 gofile ~/.bin/gofile
```

## Test

```sh
./tests/test_gofile.sh
shellcheck gofile tests/test_gofile.sh
```

Tests mock `curl`; they make no network requests and upload no files.
