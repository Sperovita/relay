---
name: relay-init
description: Set up relay (file-based session handoff) in the current project, or update an existing relay install from the bundled template. Run by hand only.
disable-model-invocation: true
argument-hint: "[what you are working on now | update]"
---

# relay-init

Relay keeps project memory in markdown under `relay/`, so sessions can be short and disposable. This skill installs it in the project you are in, or brings an existing install up to date. Everything happens inside the project, and you commit but never push. The exceptions are in Update: step S may pull a newer version of this skill into `$SRC`, and step C may refresh this skill's OpenCode command. Both ask first.

Do not open, list or diff files under `$SRC` yourself. It sits outside the project, and many projects deny reads there. Everything you need from the bundle comes out of `"$SRC/init.sh"`, which you run. Run scripts directly, as `"$SRC/init.sh" .` or `scripts/status.sh`, not as `bash <script>`: your shell is already bash, and users' permission rules match the script path. For the same reason, `$SRC` in this file is a placeholder, not a shell variable. Write the bundle's absolute path out in full in every command, such as `<home>/.claude/skills/relay-init/init.sh --diff .` or `git -C <home>/.claude/skills/relay-init fetch --quiet` with the real home folder in place of `<home>`. Never set `SRC=` or any other variable for it, and never `cd` into it. A rule that allows the script path does not match a command that reaches it through a variable. If the permission system blocks a command on the bundle, stop and tell the user which command to allow.

## 0. Find the bundle and the project

- **Bundle:** the directory this file is in, shown as the skill's base directory when it loaded. If no base directory was shown, try `~/.claude/skills/relay-init` with `~` written out as the home directory. Call it `$SRC` below. `"$SRC/init.sh" --show AGENTS.md` must print the template's `AGENTS.md`. If it fails, stop and say so.
- **Project:** `git rev-parse --show-toplevel`. If the current directory is not a git repo, ask whether to `git init` here. If the answer is no, stop.
- **Clean tree:** if `git status --porcelain` shows anything, list it and stop. Ask the user to commit or stash first, so that the relay commit holds only relay.
- **Mode:** if `relay/process/pickup.md` or `docs/process/pickup.md` exists, or the arguments say `update`, use **Update**. Otherwise use **Set up**. The `docs/` path is an install from before relay moved to its own folder.

## Set up

1. **Note what already exists.** Before copying, record which of `AGENTS.md`, `CLAUDE.md` and `.gitattributes` are present. `init.sh` skips existing files, so these need merging.
2. **Copy.** Run `"$SRC/init.sh" .` from the project root. Keep its `+ path` list; that is what you stage later. For an `AGENTS.md` or `.gitattributes` that already existed, it also prints the template text to merge.
3. **Merge files that were already there.** Never drop content. Move it if needed.
   - `AGENTS.md` existed: insert the pointer block from the template copy `init.sh` printed (the paragraph starting "This repo uses relay" through "Open the files above with your read tool when told to.") directly under the file's first heading, or at the top if there is none. If the file has no `## Project specifics` section, append the template's.
   - `CLAUDE.md` existed and is more than `@AGENTS.md`: move its content into `AGENTS.md` verbatim, without rewording, under `## Project specifics` (or a `## From CLAUDE.md` section if it is long or already structured). Then make `CLAUDE.md` just `@AGENTS.md`. Leave any `@path` import lines in `CLAUDE.md` below `@AGENTS.md`: only Claude Code expands them, and in `AGENTS.md` OpenCode would see a bare `@path` line. Skip lines that are already in `AGENTS.md`.
   - `.gitattributes` existed: append the lines `init.sh` listed as missing.
4. **Fill the project lines** under `## Project specifics` in `AGENTS.md` (Run, Test, Gotchas). Read what the repo already says: justfile, Makefile, package.json scripts, pyproject.toml, Cargo.toml, go.mod, README, CI config. Use one short line each, with exact commands in backticks. Gotchas are things a fresh agent would get wrong, such as required env, generated files and test quirks. If something is unknown, write `(none found)` rather than guessing. If merged content already covers a line, point to it instead of repeating it. Keep the section short, because it loads into every session.
5. **Seed the first piece of work.** Use the arguments as a description of what the user is working on. If there are none, ask "What are you working on in this project right now?" and wait. If the user has nothing, skip this step.
   - Mint an id with `scripts/new-id.sh` and create `relay/tickets/<id>-<verb-phrase>.md` from `relay/templates/ticket.md`: the id in `id:` and the heading, `status: ready`, a one-paragraph Goal, three to six Acceptance boxes, and Context pointers to the files involved. Leave the Handoff block empty.
   - If the work clearly spans several sessions, also create `relay/specs/<noun-phrase>.md` from `relay/templates/spec.md`, split the work into session-sized tickets, list them in the spec, and set `spec:` on each ticket.
   - Leave every `.gitkeep` file where it is. They do no harm next to real files.
6. **Board.** Run `scripts/status.sh`. Set the `Summary:` line in `relay/STATUS.md` to one line describing where the project stands.
7. **Commit.** Stage explicitly: the files `init.sh` added, the merged files and the ticket/spec files. Message: `relay: set up`. Do not push.
8. **Reply** in a few lines: what was added, what was merged and where it went, the project lines you filled (and any marked `(none found)`), the seeded ticket, and how to start: open a new session and say `pick up <id>` (the three-character suffix is enough). Do not claim or start the ticket.

## Update

S. **Bring the skill itself up to date first.** Skip this step if you have already pulled during this run, or if `git -C "$SRC" rev-parse --show-toplevel` does not print `$SRC` itself (the skill was copied, not cloned). Do not `ls` or `test` paths under `$SRC`; ask git.
   - If the permission system blocks a `git -C "$SRC"` command, say so in one line and carry on with the installed version.
   - `git -C "$SRC" status --porcelain` shows anything: someone edited the installed skill. Say so and carry on with the installed version. Never stash, reset or discard those edits.
   - `git -C "$SRC" fetch --quiet` fails (offline, no access): say so in one line and carry on with the installed version.
   - `git -C "$SRC" rev-parse HEAD` equals `git -C "$SRC" rev-parse '@{u}'`: the skill is current. Go on to step 0.
   - `git -C "$SRC" merge-base --is-ancestor HEAD '@{u}'` fails: the install has diverged from its repo. Say so and carry on with the installed version.
   - Otherwise it is behind. Show `git -C "$SRC" log --oneline HEAD..'@{u}'` and ask once whether to update the skill before updating the project. If the arguments said `update all`, take that as yes. On yes, note `git -C "$SRC" rev-parse --short HEAD` as the rollback point and run `git -C "$SRC" pull --ff-only`. Then **print the new instructions with `git -C "$SRC" show HEAD:SKILL.md` and follow its Update section from step 0**, because the copy you loaded is the old one and the new template may need new steps.
   - In the final reply, report the result: skill updated from `<old>` to `<new>` (roll back with `git -C "$SRC" reset --hard <old>`), already current, or skipped and why.

0. **Move from `docs/`.** Skip this step unless `docs/process/pickup.md` exists. If `relay/process/pickup.md` also exists, stop and ask which copy is live. Otherwise relay predates its own folder and shares `docs/` with whatever else is there.
   - Relay's entries are `docs/STATUS.md` and `docs/{process,templates,specs,tickets,decisions,research}/`. If one of those folders holds files relay did not create (say, a docs site's own `specs/`), list them and ask before moving that folder.
   - Tell the user what moves and what stays in `docs/`, and ask once. If the arguments said `update all`, take that as yes and report the move in the final reply. On yes, `git mv` each entry to the same name under `relay/`. Git drops `docs/` if nothing else was in it.
   - Rewrite the paths that moved, and only those, in every file under `relay/`, in `.claude/skills/pickup/SKILL.md`, `.claude/skills/wrap/SKILL.md`, `scripts/status.sh` and `AGENTS.md`. Other `docs/` paths may point at the project's own docs, so leave them alone: `sed -i -E 's#(^|[^-./A-Za-z0-9_])docs/(STATUS\.md|process|templates|specs|tickets|decisions|research)\b#\1relay/\2#g' <files>`. Then replace the `AGENTS.md` pointer block with the one `"$SRC/init.sh" --show AGENTS.md` prints.
   - Run `scripts/status.sh`. It should only rewrite the footer line. Commit the move by itself, staging `relay/`, the removed `docs/` paths and the edited files explicitly, with the message `relay: move from docs/ to relay/`. Then go on to step C, and step 1 will compare only real template changes.
C. **OpenCode command.** OpenCode 1 lists skills only under its `/skills` menu, so `/relay-init` there comes from a command file installed next to OpenCode's config, outside the project. Run `"$SRC/opencode-command.sh" --check`. Do not check for the file first; if the command is not found (an older bundle), skip this step. It writes nothing and prints one word:
   - `current`: nothing to do.
   - `stale`: the installed command is an older copy from this skill. Ask once whether to refresh it. If the arguments said `update all`, take that as yes. On yes, run `"$SRC/opencode-command.sh"`.
   - `missing`: if `~/.config/opencode` exists (the user has OpenCode), say in one line that `"$SRC/opencode-command.sh"` adds `/relay-init` to OpenCode. Do not install it unasked.
   - `conflict`: the user has their own `relay-init` command file. Say so and leave it alone.
   - In the final reply, report what happened. After a refresh, tell the user to fully quit and restart OpenCode.
1. **Compare.** Run `"$SRC/init.sh" --diff .`. It lists each relay-owned file (everything in the template except `AGENTS.md`, `CLAUDE.md`, `relay/STATUS.md` and `.gitkeep` files) that is **new** (missing in the project) or **changed**, then prints a diff for each changed file and the content of each new one. Project-owned files (`AGENTS.md` project lines, `STATUS.md`, tickets, specs, decisions, research) are never replaced.
2. **AGENTS.md pointer block.** If the same output says the pointer block is changed or missing, it ends with the template's block. Treat the block (only the block) as one more changed item.
3. **Nothing to do?** Say the project is up to date, with the results from steps S and C, and stop. No commit.
4. **Present** the new and changed items, one line each, with a plain summary of what changes. A difference may be a deliberate local edit (projects may drift), so say when a diff looks like a project-specific customisation rather than an older template.
5. **Apply** what the user approves: `"$SRC/init.sh" --apply . <path>...` copies the template's version over each named file. For `.gitattributes` with project lines of its own, add the missing template lines by hand instead. Swap the pointer block by hand, using the block from step 2. If the arguments said `update all`, apply everything except items that look like local customisations, and list those as skipped. If `scripts/status.sh` changed, run it afterwards.
6. **Commit** the applied files explicitly. Message: `relay: update from template`. Do not push. Reply with the results from steps S and C, then what was applied and what was skipped.
