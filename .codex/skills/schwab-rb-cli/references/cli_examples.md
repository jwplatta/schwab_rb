# schwab_rb CLI Examples

## Basic checks

```bash
skills/schwab-rb-cli/scripts/run_schwab_rb.sh help
skills/schwab-rb-cli/scripts/run_schwab_rb.sh help price-history
```

## Authentication

Expected exported variables:

```bash
env | rg '^SCHWAB_'
```

Login flow:

```bash
skills/schwab-rb-cli/scripts/run_schwab_rb.sh login
```

## Price history downloads

Daily JSON output:

```bash
skills/schwab-rb-cli/scripts/run_schwab_rb.sh price-history --symbol AAPL --start-date 2026-03-01
```

Minute CSV output:

```bash
skills/schwab-rb-cli/scripts/run_schwab_rb.sh price-history \
  --symbol VIX \
  --start-date 2026-03-01 \
  --end-date 2026-03-24 \
  --freq 1min \
  --format csv
```

Custom output directory:

```bash
skills/schwab-rb-cli/scripts/run_schwab_rb.sh price-history \
  --symbol SPY \
  --start-date 2026-03-01 \
  --dir /tmp/schwab_rb_data
```

## Installation troubleshooting

Install the gem from the repo:

```bash
bundle exec rake install
```

If the host uses `asdf`, regenerate shims:

```bash
asdf reshim ruby 3.2.2
```

Verify the executable:

```bash
which schwab_rb
ls -l ~/.asdf/shims/schwab_rb
```

If `schwab_rb` is still not on `PATH`, the wrapper script will fail immediately and the agent should report that the host install is not usable yet.

## Environment troubleshooting

Check that the variables are exported, not just set in the shell:

```bash
env | rg '^SCHWAB_'
```

Portable shell setup:

```bash
# ~/.zshrc
if [ -f "$HOME/.env" ]; then
  set -a
  source "$HOME/.env"
  set +a
fi
```

Then in `~/.env`:

```bash
SCHWAB_API_KEY=...
SCHWAB_APP_SECRET=...
SCHWAB_APP_CALLBACK_URL=https://127.0.0.1:8182
```
