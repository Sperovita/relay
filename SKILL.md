---
name: relay-init
description: Set up relay (file-based session handoff) in the current project, or update an existing relay install from the bundled template. Run by hand only.
disable-model-invocation: true
argument-hint: "[what you are working on now | update]"
---

# relay-init

Relay keeps project memory in markdown under `relay/`, so sessions can be short and disposable. This skill installs it in the project you are in, or brings an existing install up to date. Everything happens inside the project, and you commit but never push. The exceptions are in Update: step S may pull a newer version of this skill into `$SRC`, and step C may refresh this skill's OpenCode command. Both ask first.

## 0. Find the bundle and the project

- **Bundle:** the directory this file is in, shown as the skill's base directory when it loaded. If no base directory was shown, try `~/.claude/skills/relay-init`. It must contain `init.sh` and `template/AGENTS.md`. Call it `$SRC` below. If it is missing, stop and say so.
- **Project:** `git rev-parse --show-toplevel`. If the current directory is not a git repo, ask whether to `git init` here. If the answer is no, stop.
- **Clean tree:** if `git status --porcelain` shows anything, list it and stop. Ask the user to commit or stash first, so that the relay commit holds only relay.
- **Mode:** if `relay/process/pickup.md` or `docs/process/pickup.md` exists, or the arguments say `update`, use **Update**. Otherwise use **Set up**. The `docs/` path is an install from before relay moved to its own folder.

## Set up

1. **Note what already exists.** Before copying, record which of `AGENTS.md`, `CLAUDE.md` and `.gitattributes` are present. `init.sh` skips existing files, so these need merging.
2. **Copy.** Run `bash "$SRC/init.sh" .` from the project root. Keep its `+ path` list; that is what you stage later.
3. **Merge files that were already there.** Never drop content. Move it if needed.
   - `AGENTS.md` existed: insert the pointer block from `$SRC/template/AGENTS.md` (the paragraph starting "This repo uses relay" through "Open the files above with your read tool when told to.") directly under the file's first heading, or at the top if there is none. If the file has no `## Project specifics` section, append the template's.
   - `CLAUDE.md` existed and is more than `@AGENTS.md`: move its content into `AGENTS.md` verbatim, without rewording, under `## Project specifics` (or a `## From CLAUDE.md` section if it is long or already structured). Then make `CLAUDE.md` just `@AGENTS.md`. Leave any `@path` import lines in `CLAUDE.md` below `@AGENTS.md`: only Claude Code expands them, and in `AGENTS.md` OpenCode would see a bare `@path` line. Skip lines that are already in `AGENTS.md`.
   - `.gitattributes` existed: append any lines from `$SRC/template/.gitattributes` that it lacks.
4. **Fill the project lines** under `## Project specifics` in `AGENTS.md` (Run, Test, Gotchas). Read what the repo already says: justfile, Makefile, package.json scripts, pyproject.toml, Cargo.toml, go.mod, README, CI config. Use one short line each, with exact commands in backticks. Gotchas are things a fresh agent would get wrong, such as required env, generated files and test quirks. If something is unknown, write `(none found)` rather than guessing. If merged content already covers a line, point to it instead of repeating it. Keep the section short, because it loads into every session.
5. **Seed the first piece of work.** Use the arguments as a description of what the user is working on. If there are none, ask "What are you working on in this project right now?" and wait. If the user has nothing, skip this step.
   - Mint an id with `bash scripts/new-id.sh` and create `relay/tickets/<id>-<verb-phrase>.md` from `relay/templates/ticket.md`: the id in `id:` and the heading, `status: ready`, a one-paragraph Goal, three to six Acceptance boxes, and Context pointers to the files involved. Leave the Handoff block empty.
   - If the work clearly spans several sessions, also create `relay/specs/<noun-phrase>.md` from `relay/templates/spec.md`, split the work into session-sized tickets, list them in the spec, and set `spec:` on each ticket.
   - Remove `.gitkeep` from any folder you put a file in.
6. **Board.** Run `bash scripts/status.sh`. Set the `Summary:` line in `relay/STATUS.md` to one line describing where the project stands.
7. **Commit.** Stage explicitly: the files `init.sh` added, the merged files, the ticket/spec files and any removed `.gitkeep`. Message: `relay: set up`. Do not push.
8. **Reply** in a few lines: what was added, what was merged and where it went, the project lines you filled (and any marked `(none found)`), the seeded ticket, and how to start: open a new session and say `pick up <id>` (the three-character suffix is enough). Do not claim or start the ticket.

## Update

S. **Bring the skill itself up to date first.** Skip this step if `$SRC/.git` does not exist (the skill was copied, not cloned), or if you have already pulled during this run.
   - `git -C "$SRC" status --porcelain` shows anything: someone edited the installed skill. Say so and carry on with the installed version. Never stash, reset or discard those edits.
   - `git -C "$SRC" fetch --quiet` fails (offline, no access): say so in one line and carry on with the installed version.
   - `git -C "$SRC" rev-parse HEAD` equals `git -C "$SRC" rev-parse '@{u}'`: the skill is current. Go on to step 0.
   - `git -C "$SRC" merge-base --is-ancestor HEAD '@{u}'` fails: the install has diverged from its repo. Say so and carry on with the installed version.
   - Otherwise it is behind. Show `git -C "$SRC" log --oneline HEAD..'@{u}'` and ask once whether to update the skill before updating the project. If the arguments said `update all`, take that as yes. On yes, note `git -C "$SRC" rev-parse --short HEAD` as the rollback point and run `git -C "$SRC" pull --ff-only`. Then **read `$SRC/SKILL.md` again and follow its Update section from step 0**, because the copy you loaded is the old one and the new template may need new steps.
   - In the final reply, report the result: skill updated from `<old>` to `<new>` (roll back with `git -C "$SRC" reset --hard <old>`), already current, or skipped and why.

0. **Move from `docs/`.** Skip this step unless `docs/process/pickup.md` exists. If `relay/process/pickup.md` also exists, stop and ask which copy is live. Otherwise relay predates its own folder and shares `docs/` with whatever else is there.
   - Relay's entries are `docs/STATUS.md` and `docs/{process,templates,specs,tickets,decisions,research}/`. If one of those folders holds files relay did not create (say, a docs site's own `specs/`), list them and ask before moving that folder.
   - Tell the user what moves and what stays in `docs/`, and ask once. If the arguments said `update all`, take that as yes and report the move in the final reply. On yes, `git mv` each entry to the same name under `relay/`. Git drops `docs/` if nothing else was in it.
   - Rewrite the paths that moved, and only those, in every file under `relay/`, in `.claude/skills/pickup/SKILL.md`, `.claude/skills/wrap/SKILL.md`, `scripts/status.sh` and `AGENTS.md`. Other `docs/` paths may point at the project's own docs, so leave them alone: `sed -i -E 's#(^|[^-./A-Za-z0-9_])docs/(STATUS\.md|process|templates|specs|tickets|decisions|research)\b#\1relay/\2#g' <files>`. Then replace the `AGENTS.md` pointer block with the template's.
   - Run `bash scripts/status.sh`. It should only rewrite the footer line. Commit the move by itself, staging `relay/`, the removed `docs/` paths and the edited files explicitly, with the message `relay: move from docs/ to relay/`. Then go on to step C, and step 1 will compare only real template changes.
C. **OpenCode command.** OpenCode 1 lists skills only under its `/skills` menu, so `/relay-init` there comes from a command file installed next to OpenCode's config, outside the project. Skip this step if `$SRC/opencode-command.sh` does not exist. Otherwise run `bash "$SRC/opencode-command.sh" --check`. It writes nothing and prints one word:
   - `current`: nothing to do.
   - `stale`: the installed command is an older copy from this skill. Ask once whether to refresh it. If the arguments said `update all`, take that as yes. On yes, run `bash "$SRC/opencode-command.sh"`.
   - `missing`: if `~/.config/opencode` exists (the user has OpenCode), say in one line that `bash "$SRC/opencode-command.sh"` adds `/relay-init` to OpenCode. Do not install it unasked.
   - `conflict`: the user has their own `relay-init` command file. Say so and leave it alone.
   - In the final reply, report what happened. After a refresh, tell the user to fully quit and restart OpenCode.
1. **Compare.** Relay-owned files are everything under `$SRC/template/` except `AGENTS.md`, `CLAUDE.md`, `relay/STATUS.md` and `.gitkeep` files. A bundle file named `X.tmpl` corresponds to the project's `X`: the suffix only hides the template's skills from OpenCode's skill scan. Check each one against the project's copy:
   - missing in the project: **new**
   - different: **changed**. Run `diff -u <project file> <template file>`.
   - identical: skip
   Project-owned files (`AGENTS.md` project lines, `STATUS.md`, tickets, specs, decisions, research) are never replaced.
2. **AGENTS.md pointer block.** If the pointer block in the project's `AGENTS.md` differs from the template's, or is missing, treat the block (only the block) as one more changed item.
3. **Nothing to do?** Say the project is up to date, with the results from steps S and C, and stop. No commit.
4. **Present** the new and changed items, one line each, with a plain summary of what changes. A difference may be a deliberate local edit (projects may drift), so say when a diff looks like a project-specific customisation rather than an older template.
5. **Apply** what the user approves: copy the template file over the project file, add missing `.gitattributes` lines, or swap the pointer block. If the arguments said `update all`, apply everything except items that look like local customisations, and list those as skipped. If `scripts/status.sh` changed, run it afterwards.
6. **Commit** the applied files explicitly. Message: `relay: update from template`. Do not push. Reply with the results from steps S and C, then what was applied and what was skipped.
