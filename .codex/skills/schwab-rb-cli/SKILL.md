---
name: schwab-rb-cli
description: Use the installed schwab_rb CLI for authentication and price history downloads. Activate when a user wants to run the schwab_rb command, log in to Schwab, fetch market data, troubleshoot CLI installation or environment variables, or save price history from the command line.
---

# Schwab RB CLI Skill

Use this skill when the task should be completed through the installed `schwab_rb` command rather than by editing Ruby code directly.

## When to use

- The user wants to run `schwab_rb help`, `schwab_rb login`, or `schwab_rb price-history`
- The user wants to download price history data to JSON or CSV
- The user needs help with CLI installation, `asdf` shims, or missing `SCHWAB_*` environment variables
- The user wants the agent to verify the CLI works on the local machine

## Quick workflow

1. Prefer the bundled wrapper script:

```bash
skills/schwab-rb-cli/scripts/run_schwab_rb.sh help
```

The wrapper only attempts to execute the globally installed `schwab_rb` command from `PATH`. It does not use repo-relative paths or Bundler fallbacks.

2. If the wrapper reports that `schwab_rb` is missing:
   - Report that the host machine does not have the CLI available in `PATH`
   - Tell the user to install the gem globally and fix shell/shim configuration before retrying

3. Before running auth or data commands, verify these exported variables exist in the shell environment:
   - `SCHWAB_API_KEY`
   - `SCHWAB_APP_SECRET`
   - `SCHWAB_APP_CALLBACK_URL`

4. For first-time auth, run:

```bash
skills/schwab-rb-cli/scripts/run_schwab_rb.sh login
```

5. For data downloads, run:

```bash
skills/schwab-rb-cli/scripts/run_schwab_rb.sh price-history --symbol AAPL --start-date 2026-03-01
```

## Operating guidance

- Do not ask users to paste secrets into chat when the task can be completed using already-exported environment variables.
- Assume the CLI token is shared at `~/.schwab_rb/token.json`.
- Assume downloaded data goes to `~/.schwab_rb/data` unless `--dir` is passed.
- Use `--format csv` only when the user specifically wants flat files; otherwise prefer JSON because it matches the API response shape.
- If the wrapper says the executable is missing, stop and report that the host install is unavailable. Do not substitute repo-local execution.
- If the CLI reports missing environment variables, check exported shell envs first. Do not rely on a repo-local `.env` unless the user explicitly wants that setup.

## References

- For concrete commands and troubleshooting steps, read [references/cli_examples.md](references/cli_examples.md).
