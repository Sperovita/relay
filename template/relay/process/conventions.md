# Relay conventions

Relay: sessions are legs, the ticket is the baton, wrap passes it, pickup takes it. Loose on purpose. Change anything here that stops earning its keep.

## Layout

```
relay/
  STATUS.md        board; regenerated from ticket frontmatter, only the Summary line is hand-edited
  specs/           one file per multi-session piece of work
  tickets/         one file per session-sized piece of work
  decisions/       architecture decision records, Nygard shape
  research/        subagent output; read by tickets, not by the main session
  process/         this folder
  templates/       copy these
scripts/status.sh  lints ticket frontmatter, then rebuilds STATUS.md
```

## Naming

- Tickets and decisions: `NNNN-verb-phrase.md`, four digits, lowercase, dashes. Next number is the highest existing plus one in that folder.
- Specs: `noun-phrase.md`.
- Paths inside documents are repo-relative with forward slashes. Never absolute. Never machine-specific.

## Ticket sizing

- A ticket fits in one sitting with context to spare. If sessions degrade before finishing, split it. If setup dominates each session, merge tickets.
- `type` is a field, not a boundary. An `investigate` ticket that turns into `design` just changes the field. Types: `investigate`, `research`, `design`, `implement`, `fix`, `ops`.
- Several tiny bugs can share one `fix` ticket. Nothing else should be batched.
- A contract (schema, API, migration, file format, wire shape) lives inside exactly one ticket. Split by layer or by feature, never across a contract: two tickets that each own half of an interface can both finish, both pass their own tests, and not work together.
- Research goes to a subagent (Opus or below) that writes into `relay/research/` and returns a short summary. The file is the deliverable.

## Decision records

Write one when a choice constrains future work and someone would otherwise re-litigate it. Do not write one for choices that are tiny, temporary, single-developer trivia, or already captured in a standard or the spec. Fields: Context, Decision, Consequences, Status. Supersede by writing a new one and linking both ways.

## Parallel sessions

- One session, one ticket. Two sessions never share a ticket; split it into two.
- Claim before working, so a second session sees it as in flight.
- Two `implement` or `fix` tickets in flight at once means worktrees, branch `ticket/<id>`. Research, design, and investigate sessions can share the main checkout with one implement session.
- Worktrees live inside the repo at `.worktrees/<id>`, listed in `.git/info/exclude` (local, never committed). Inside the repo works when only the repo is writable, and the exclude keeps `git add -A` on main from committing the worktree.
- The claim commit goes on main, branch or not. Work and wrap commits for a worktree ticket go on its branch.
- Each session writes only its own ticket file. STATUS.md is regenerated, so it does not conflict.
- STATUS.md is the one file every session writes. If it conflicts on a merge, rebase or pull, take either side (`git checkout --ours relay/STATUS.md` or `--theirs`, it does not matter which) and rerun `scripts/status.sh`. Never hand-merge the board.
- Merging worktree branches is a deliberate human step, not part of wrap.

## Commits

- Every commit for a ticket carries its id: `<id>: claim`, `<id>: <what changed>`, `wrap: <id> <summary>`. Then `git log --grep <id>` lists the ticket's whole record, which is the fallback when a handoff lacks a detail.

## Context budget

- Wrap before any break longer than an hour. Resuming from files is cheap; a cold cache on a large context is not.
- Keep `AGENTS.md` to pointers plus a few project specifics. It loads into every session.

## Verbs

- `wrap` ends a leg. `pickup <id>` starts one on a named ticket. `catch me up` shows the board and asks.
- Named to avoid Claude Code built-ins: `/resume` picks a past session there, and `--continue` reopens the last one.
