# Pickup

Run this at the start of every session, or when the user says "pick up <id>", "pickup next" or "catch me up". It costs one small file read plus one ticket.

1. Read `relay/STATUS.md`.
2. **If the user's first message names a ticket, says `pickup next`, or describes new work**, go straight there. Do not list the board, do not ask.
   - Named ticket: open `relay/tickets/<id>-*.md`, or `relay/tickets/????-??-??-<suffix>-*.md` when the user gave only the three-character suffix. Read its Handoff block, continue from "Next command". The handoff is enough to continue. When it lacks a detail you need, `git log --grep <id>` lists every claim, work and wrap commit for the ticket; the commits are the raw record, read the diff of the one that matters. If that log shows work commits newer than the last `wrap:` commit, the previous session ended without wrapping and the handoff is older than its work; read those commits before trusting "Next command".
   - `pickup next`: take the first ticket under Ready on the board and treat it as named. Ready holds only startable tickets; Waiting and Blocked are skipped. If Ready is empty, fall through to step 3.
   - Inputs, for a named or next ticket: if its `blocked-by` names tickets that are now `done`, read the `Done:` line of each one's Handoff; if it names a spec, read the spec's Constraints and Decisions so far. Read nothing further up front; every extra file is a cost each pickup pays.
   - New work: create a ticket from `relay/templates/ticket.md` (id from `scripts/new-id.sh`, see conventions). If it belongs to an existing spec, add it to that spec's ticket list.
   - Quick question or five-minute task: skip claiming. Say so in one line and proceed. Wrap still applies if anything gets decided.
3. **Otherwise** reply with the in-flight and ready tickets, one line each, and ask which one. Stop and wait.
4. **Claim** the ticket before any other work, on the main checkout: set `status: in-progress` in its frontmatter (and `branch: ticket/<id>` if step 5 applies), run `scripts/status.sh`, and commit the ticket and `relay/STATUS.md` together with the message `<id>: claim`. A second session reading only the board then sees the ticket in flight. If `status.sh` refuses to write, it names the broken ticket file; fix that file, do not edit the board around it.
5. **Worktree rule:** if another ticket of type `implement` or `fix` is already in flight, and yours is too, work in a git worktree on a branch named `ticket/<id>`, created after the claim commit so the branch starts from it: `git worktree add .worktrees/<id> -b ticket/<id>`, then add `.worktrees/` to `.git/info/exclude` if it is not there yet. The claim stays on main, where other sessions look. Otherwise use the main checkout.
6. Never edit another in-flight ticket's file or handoff block.
