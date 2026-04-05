---
title: Rust Harness Protocol Enforcement — All Tiers
status: completed
created: 2026-04-04
---

## Vision

Add active enforcement mechanisms to the Rust harness so that the agent cannot violate protocol rules at runtime, not just because the system prompt says not to. Three enforcement layers:

1. **Tier 3 hard blocks** — certain writes are blocked before any tool runs
2. **Workspace boundary enforcement** — write_file/edit_file reject out-of-workspace paths
3. **Tier 2 spec context injection** — open spec criteria prepended to each user turn

## Requirements

1. `.env` files must be blocked from write/edit by the harness before dispatch.
2. `~/.claude/settings.json` must be blocked from write/edit without explicit plan approval.
3. Workspace boundary check (`check_file_write`) must be wired into tool dispatch for `WorkspaceWrite` mode.
4. `ConversationRuntime` must scan `specs/*.md` for `- [ ]` lines and inject them as a `<system-reminder>` block at the start of each user turn.
5. All existing tests must continue to pass.

## Acceptance Criteria

- [x] `protected_write_violation(".env")` → `Some(...)`
- [x] `protected_write_violation("/project/.env.local")` → `Some(...)`
- [x] `protected_write_violation("$HOME/.claude/settings.json")` → `Some(...)`
- [x] `protected_write_violation("/project/src/main.rs")` → `None`
- [x] `write_file` with `.env` path returns `Err("BLOCKED — protected path: ...")`
- [x] `edit_file` with `.env` path returns `Err("BLOCKED — protected path: ...")`
- [x] `write_file` with out-of-workspace path in `WorkspaceWrite` mode → `Err("BLOCKED — workspace boundary: ...")`
- [x] `ConversationRuntime::with_spec_context_dir()` builder method exists
- [x] `build_open_spec_context()` returns `None` when no `specs/` dir exists
- [x] `build_open_spec_context()` returns `Some(...)` with `<system-reminder>` block when open criteria present
- [x] Main CLI wires `with_spec_context_dir(cwd)` on runtime construction
- [x] `cargo test --workspace` — 0 failures
- [x] `cargo clippy --workspace --all-targets` — exit 0

## Technical Decisions

4 files modified, under the 5-file DeepSeek delegation threshold — implemented directly.

| File | Change |
|------|--------|
| `rust/crates/runtime/src/permission_enforcer.rs` | `protected_write_violation()` standalone pub fn + test |
| `rust/crates/tools/src/lib.rs` | Wire `protected_write_violation` + `check_file_write` in `write_file`/`edit_file` arms |
| `rust/crates/runtime/src/conversation.rs` | `spec_context_dir` field, `with_spec_context_dir()` builder, `build_open_spec_context()` helper, injection in `run_turn()` |
| `rust/crates/rusty-claude-cli/src/main.rs` | `.with_spec_context_dir(cwd)` in `build_runtime_with_plugin_state()` |

Workspace boundary check only fires in `WorkspaceWrite` mode — `ReadOnly` and other modes are handled by the existing `maybe_enforce_permission_check` path, preserving existing test expectations.

## Progress

Implemented in commit `3b8cfed` (2026-04-04).
Plan approved via ExitPlanMode (plan file `~/.claude/plans/fluttering-dancing-haven.md`).
