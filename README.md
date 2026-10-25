# relay

Relay is a file-based handoff convention for coding-agent sessions. Project memory lives in plain markdown under `relay/`: a status board, tickets with a handoff block, specs, and decision records. Any session can be short and disposable, and a fresh agent with no context picks up where the last one stopped. It works in Claude Code and OpenCode, on Linux and Windows (WSL or Git Bash). This repo is the `/relay-init` skill, which installs relay into a project and keeps it current.

## Install

Clone this repo straight into your user-level skills folder. The clone is the install.

Linux, WSL, or Windows Git Bash:

```bash
git clone https://github.com/sperovita/relay.git ~/.claude/skills/relay-init
```

Windows PowerShell:

```powershell
git clone https://github.com/sperovita/relay.git "$HOME\.claude\skills\relay-init"
```

## Update

```bash
git -C ~/.claude/skills/relay-init pull
```

Then run `/relay-init update` in each project to bring its relay files up to the new template.

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

## Maintainer

This repo is published from a private development repo as snapshot commits. Each one holds only the files above. Changes are made upstream and arrive with the next snapshot.

Publishing, from the private repo:

```bash
just publish                 # builds the tree, leak-checks it, commits a snapshot on local branch public
git push relay-public        # pushes public -> main with the repo's deploy key
```

One-time setup for the push: a write-enabled deploy key scoped to this repo only (no account-wide token), and a remote whose only push refspec is `public:main`, so a bare push can never send the private branches:

```bash
git remote add relay-public git@github.com:sperovita/relay.git
git config remote.relay-public.push refs/heads/public:refs/heads/main
git config core.sshCommand "ssh -i ~/.ssh/id_ed25519_relay -o IdentitiesOnly=yes"
```

## Licence

MIT, see `LICENSE`.
