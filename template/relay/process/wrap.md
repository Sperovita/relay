# Wrap

Run this when the user says wrap, at a natural stopping point, or before any break longer than an hour. Everything here is written for a reader with zero context: concrete repo-relative paths, forward slashes, the reasoning behind choices.

1. **Identify the claimed ticket.** If this was an unclaimed quick task, skip to step 4.
2. **Overwrite the ticket's Handoff block.** Replace the previous contents entirely:
   - Done: what now works, with the files that changed.
   - Left: what remains, in the order to do it.
   - Decisions (and why): anything a future session would otherwise re-debate.
   - Gotchas / dead ends: what was tried and failed, so nobody tries it again.
   - Next command: the exact command or first action for the next session.
3. **Set status** in the frontmatter: `done` if every acceptance box is checked, `blocked` with `blocked-by:` filled if waiting on something, else leave `in-progress`. If on a worktree, make sure `branch:` is set.
4. **Decision record.** If a decision was made that constrains future work, create `relay/decisions/<id>-verb-phrase.md` from `relay/templates/adr.md`, with the id from `scripts/new-id.sh`. Skip it for decisions that are tiny, temporary, single-file, or already covered elsewhere. If a decision replaces an older one, write a new record and mark the old one superseded.
5. **Spec.** If the active spec's decisions, constraints, or ticket list changed, update it. If this wrap closed the spec's last ticket and no open question remains, set its `Status: done`; the board then moves it out of the Specs list, so a cold session stops reading it as current.
6. **Status board.** Run `scripts/status.sh` from the repo root. It lints the tickets first and refuses to write if one has a duplicate id, an unknown status, no id, title or type, or a filename that does not start with its id; fix the file it names, never the board. If the script cannot run on this machine, regenerate `relay/STATUS.md` by hand in the same shape. Update the `Summary:` line only if the overall picture changed.
7. **Commit.** Stage the relay files and any code explicitly. Message: `wrap: <id> <short description>` or `wrap: quick <short description>`. Do not push.
8. **Reply with three lines:** what is done, what is next, and the branch name if not on the main checkout.
