# relay

Relay is a file-based handoff convention for coding-agent sessions. Project memory lives in plain markdown under `relay/`: a status board, tickets with a handoff block, specs, and decision records. Any session can be short and disposable, and a fresh agent with no context picks up where the last one stopped. It works in Claude Code and OpenCode, on Linux and Windows (WSL or Git Bash). This repo is the `/relay-init` skill, which installs relay into a project and keeps it current.

## Install

Clone this repo straight into your user-level skills folder. The clone is the install.

Linux, WSL, or Windows Git Bash:

```bash
git clone https://github.com/Sperovita/relay.git ~/.claude/skills/relay-init
```

Windows PowerShell:

```powershell
git clone https://github.com/Sperovita/relay.git "$HOME\.claude\skills\relay-init"
```

Or give your coding agent this repo's link and ask it to install relay. The next section tells it what to do.

## For agents: install or update this skill

If a user asked you to install or update relay from this repo, follow these steps exactly.

1. The install folder must be `~/.claude/skills/relay-init`, named exactly that. The skill looks for itself there. Claude Code and OpenCode both read skills from `~/.claude/skills/`.
2. If that folder does not exist, clone into it: `git clone https://github.com/Sperovita/relay.git ~/.claude/skills/relay-init`. In PowerShell, use `"$HOME\.claude\skills\relay-init"` as the target.
3. If it exists and is a clone of this repo (`git -C ~/.claude/skills/relay-init remote get-url origin` points here), update it with `git -C ~/.claude/skills/relay-init pull --ff-only`. If that fails because of local edits or divergence, stop and tell the user. Do not reset, stash or re-clone over it.
4. If it exists but is not a clone of this repo, stop and ask the user. Do not delete it.
5. Tell the user: start a new session so the skill loads, then run `/relay-init` in a project to set relay up, or `/relay-init update` in a project that already has it. The skill is manual-only, so the user has to type the command. Do not try to run it yourself.

## Update

In a project that already uses relay, run `/relay-init update`. It checks whether this skill is behind the repo, offers to pull the new version, then brings the project's relay files up to the new template. To update the skill alone, run `git -C ~/.claude/skills/relay-init pull --ff-only`, or ask your agent to update relay from this repo.

## Use

In a project (a git repo with a clean tree), start a session and run:

```
/relay-init what you are working on right now
```

It copies the relay files in, merges an existing `AGENTS.md` / `CLAUDE.md` / `.gitattributes` without dropping anything, fills in the project's run and test commands, seeds ticket 0001 from your description, and commits `relay: set up`. It never pushes. Then open a new session and say `pick up 0001`. Say `wrap it up` when you stop.

`/relay-init update` compares the project's relay files with this bundle, shows what changed, and applies what you approve. `/relay-init update all` applies everything except files that look locally customised. An install from before relay moved to its own folder (relay files under `docs/`) is moved to `relay/` first.

The skill is manual-only (`disable-model-invocation`), so it never runs unless you type it.

## OpenCode

- OpenCode reads skills from `~/.claude/skills/` too, so the same clone serves both tools. `/relay-init` works as a slash command there through the skill's `opencode/slash` metadata.
- The template's own `pickup` and `wrap` skills are stored here as `SKILL.md.tmpl`. OpenCode scans skill folders recursively and would otherwise register them in every project. `init.sh` drops the suffix when it copies them into a project.
- In a project, OpenCode reads `AGENTS.md` and Claude Code reads `CLAUDE.md`, which is just `@AGENTS.md`. Put project instructions in `AGENTS.md`. OpenCode does not expand `@` imports.

## What's here

- `SKILL.md`  the `/relay-init` skill
- `init.sh`  the mechanical copier the skill calls. Never overwrites. You can also run it by hand: `bash init.sh /path/to/project`
- `template/`  the files a project gets

## Licence

MIT, see `LICENSE`.
