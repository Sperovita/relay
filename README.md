# relay

Relay is a file-based handoff convention for coding-agent sessions. Project memory lives in plain markdown under `relay/`: a status board, tickets with a handoff block, specs, and decision records. Any session can be short and disposable, and a fresh agent with no context picks up where the last one stopped. It works in Claude Code and OpenCode, on Linux and Windows (WSL or Git Bash). This repo is the `/relay-init` skill, which installs relay into a project and keeps it current.

## Install

Clone this repo straight into your user-level skills folder. The clone is the install. The second line adds `/relay-init` to OpenCode (see [OpenCode](#opencode)). It writes one small file and does no harm if you don't use OpenCode.

Linux, WSL, or Windows Git Bash:

```bash
git clone https://github.com/Sperovita/relay.git ~/.claude/skills/relay-init
bash ~/.claude/skills/relay-init/opencode-command.sh
```

Windows PowerShell:

```powershell
git clone https://github.com/Sperovita/relay.git "$HOME\.claude\skills\relay-init"
```

then run the `bash` line above from Git Bash. In PowerShell, `bash` may start WSL, which has a different home folder.

Fully quit and restart Claude Code or OpenCode afterwards. OpenCode loads commands only at startup.

Or give your coding agent this repo's link and ask it to install relay. The next section tells it what to do.

## For agents: install or update this skill

If a user asked you to install or update relay from this repo, follow these steps exactly.

1. The install folder must be `~/.claude/skills/relay-init`, named exactly that. The skill looks for itself there. Claude Code and OpenCode both read skills from `~/.claude/skills/`.
2. If that folder does not exist, clone into it: `git clone https://github.com/Sperovita/relay.git ~/.claude/skills/relay-init`. In PowerShell, use `"$HOME\.claude\skills\relay-init"` as the target.
3. If it exists and is a clone of this repo (`git -C ~/.claude/skills/relay-init remote get-url origin` points here), update it with `git -C ~/.claude/skills/relay-init pull --ff-only`. If that fails because of local edits or divergence, stop and tell the user. Do not reset, stash or re-clone over it.
4. If it exists but is not a clone of this repo, stop and ask the user. Do not delete it.
5. Install or refresh the OpenCode command, on install and on every update: `bash ~/.claude/skills/relay-init/opencode-command.sh`. It is safe to rerun. It writes `~/.config/opencode/commands/relay-init.md` if that file is missing, replaces it if it is an older copy from this repo, and does nothing if it is current. If the user has a different file there, it exits 1 and changes nothing. Show the user its output and ask; do not delete or edit their file. On Windows, run it with Git Bash, not with PowerShell's `bash`, which may be WSL's and write to the wrong home folder.
6. Tell the user to fully quit and restart Claude Code or OpenCode, so the skill and command load. A new session inside a running OpenCode is not enough. Then run `/relay-init` in a project to set relay up, or `/relay-init update` in a project that already has it. The skill is manual-only, so the user has to type the command. Do not try to run it yourself.

## Update

In a project that already uses relay, run `/relay-init update`. It checks whether this skill is behind the repo, offers to pull the new version, then brings the project's relay files up to the new template. It also checks the OpenCode command and offers to refresh it if it is an older copy. To update the skill alone, run `git -C ~/.claude/skills/relay-init pull --ff-only`, then `bash ~/.claude/skills/relay-init/opencode-command.sh`, or ask your agent to update relay from this repo. Fully restart OpenCode after either.

## Use

In a project (a git repo with a clean tree), start a session and run:

```
/relay-init what you are working on right now
```

It copies the relay files in, merges an existing `AGENTS.md` / `CLAUDE.md` / `.gitattributes` without dropping anything, fills in the project's run and test commands, seeds a first ticket from your description, and commits `relay: set up`. It never pushes. Then open a new session and say `pick up` plus the ticket's id or just its last three characters (`pick up k7q` for `2026-10-25-k7q`). Say `wrap it up` when you stop.

`/relay-init update` compares the project's relay files with this bundle, shows what changed, and applies what you approve. `/relay-init update all` applies everything except files that look locally customised. An install from before relay moved to its own folder (relay files under `docs/`) is moved to `relay/` first.

The skill is manual-only (`disable-model-invocation`), so Claude Code never runs it unless you type it. OpenCode ignores that flag, but the skill's description says it runs by hand only, and the command is how you start it there.

## OpenCode

- OpenCode reads skills from `~/.claude/skills/` too, so the same clone serves both tools. But OpenCode 1 lists skills only under its `/skills` menu, never as their own slash commands, and no skill metadata changes that. So `opencode-command.sh` installs a small command, `~/.config/opencode/commands/relay-init.md`, that loads the skill and passes your arguments to it. That is what makes `/relay-init` appear. The script never overwrites a file it did not write, and `/relay-init update` offers to refresh it.
- In a project, relay's `pickup` and `wrap` are skills too, so OpenCode shows them under `/skills`. Saying "pick up" or "wrap it up" works in both tools, because `AGENTS.md` points at the process files.
- The template's own `pickup` and `wrap` skills are stored here as `SKILL.md.tmpl`. OpenCode scans skill folders recursively and would otherwise register them in every project. `init.sh` drops the suffix when it copies them into a project.
- In a project, OpenCode reads `AGENTS.md` and Claude Code reads `CLAUDE.md`, which is just `@AGENTS.md`. Put project instructions in `AGENTS.md`. OpenCode does not expand `@` imports.

## What's here

- `SKILL.md`  the `/relay-init` skill
- `init.sh`  the mechanical copier the skill calls. Never overwrites. You can also run it by hand: `bash init.sh /path/to/project`. `--diff`, `--apply` and `--show` compare a project with the template, copy named files over, and print a template file. The skill gets everything it needs from the bundle this way, so it works in projects that block reads outside themselves.
- `opencode/relay-init.md`, `opencode-command.sh`  the OpenCode `/relay-init` command and its installer. `bash opencode-command.sh --check` reports `current`, `missing`, `stale` or `conflict` without writing.
- `template/`  the files a project gets

## Licence

MIT, see `LICENSE`.
