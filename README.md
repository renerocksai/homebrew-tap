# renerocksai/tap

Homebrew formulae by renerocksai.

## omajot

Markdown notes that sync through your own hub over Tailscale.
Guide: <https://renerocks.ai/omajot/>

```sh
brew install renerocksai/tap/omajot
```

This installs the `omajot` command: the hub, the note commands and the TUI.
It works on macOS and Linux (Apple silicon, Intel, arm64).

### Run the hub as a service

Write your Tailscale login to `~/.config/omajot/config.json` once:

```json
{"hub_login": "you@example.com"}
```

Then start the hub and publish it on your tailnet:

```sh
brew services start omajot
tailscale serve --bg --https=8443 http://127.0.0.1:8787
```

The hub starts at login and restarts if it stops. The notes are in
`~/omajot-data`. Optional keys in the same file: `hub_port` (default 8787)
and `hub_data`.

### Update

```sh
brew upgrade omajot
brew services restart omajot
```

The omajot release workflow updates `Formula/omajot.rb` for every release.
