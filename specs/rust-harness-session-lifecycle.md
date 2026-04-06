---
title: Rust Harness Session Lifecycle — Stop Hook, Turn Data, Agent Mode
status: completed
created: 2026-04-05
---

## Vision

Close four session lifecycle gaps so the Rust harness produces the same data files as Python-hook-driven sessions. The reviewer and stop hook scripts depend on these files to validate work and know the agent mode.

## Requirements

1. Stop hook commands configured under `hooks.Stop` in `settings.json` must fire when the session ends.
2. Each user turn must append `{prompt, timestamp, task_id, prompt_id}` to `~/.claude/data/user_requests_{session_id}.json`.
3. Each user turn must write `~/.claude/data/current_task_{session_id}.json` with task scoping data.
4. On startup, `~/.claude/data/agent_mode.json` must exist; if absent, bootstrap it with `{"mode": "claw"}`.
5. All existing tests must continue to pass.

## Acceptance Criteria

- [x] `HookEvent::Stop` variant exists with `as_str()` → `"Stop"`
- [x] `RuntimeHookConfig::stop()` returns configured stop commands
- [x] `RuntimeHookConfig::with_stop()` builder exists
- [x] `Stop` commands parsed from `settings.json` `hooks.Stop` key
- [x] `HookRunner::run_stop(session_id)` fires configured commands via stdin JSON payload
- [x] `run_stop` is noop when no stop commands configured
- [x] `ConversationRuntime::run_stop_hook()` delegates to hook runner
- [x] Stop hook wired at both exit points in `run_repl()` (`/exit`/`/quit` and `ReadOutcome::Exit`)
- [x] `write_turn_data()` appends to `user_requests_{session_id}.json` on each turn
- [x] `write_turn_data()` writes `current_task_{session_id}.json` on each turn
- [x] `write_agent_mode_if_absent()` writes `{"mode": "claw"}` if file absent
- [x] `write_agent_mode_if_absent()` is a no-op if file already exists
- [x] `cargo test --workspace` — 0 failures (712 passed)
- [x] `cargo clippy --workspace --all-targets` — exit 0

## Technical Decisions

4 files modified, under the 5-file DeepSeek delegation threshold — implemented directly.

| File | Change |
|------|--------|
| `rust/crates/runtime/src/config.rs` | `stop: Vec<String>` field + `stop()` + `with_stop()` + config parsing + extend() |
| `rust/crates/runtime/src/hooks.rs` | `HookEvent::Stop` + `HookRunner::run_stop()` + 2 tests |
| `rust/crates/runtime/src/conversation.rs` | `write_turn_data()` + `run_stop_hook()` + 1 test; wired in `run_turn()` |
| `rust/crates/rusty-claude-cli/src/main.rs` | `write_agent_mode_if_absent()` + `LiveCli::run_stop_hook()` + wired in `run_repl()` |

Stop hook fires best-effort (ignores result) so it never blocks exit.
`write_turn_data` never panics — all errors silently ignored.

## Progress

Implemented. All acceptance criteria satisfied. 712 tests pass.
