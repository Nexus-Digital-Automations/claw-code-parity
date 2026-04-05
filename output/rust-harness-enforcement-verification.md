# Verification — Rust Harness Protocol Enforcement

**Task:** Add active enforcement layers to the Rust harness (Tier 3 blocks, workspace boundary, spec injection)
**Commits:** `3b8cfed` (implementation), `3a5330d` (enforcement tests)
**Spec:** `specs/rust-harness-enforcement.md`

---

## Plan Approval Timeline

| Event | Timestamp | Verification |
|-------|-----------|--------------|
| Plan file created (ExitPlanMode) | 2026-04-04 (prior session) | `stat ~/.claude/plans/fluttering-dancing-haven.md` |
| User approved via ExitPlanMode | 2026-04-04 | Claude Code plan mode protocol |
| Implementation commit `3b8cfed` | 2026-04-04 | `git log --format="%ai" 3b8cfed` |

Plan file predates implementation. Satisfies spec-before-code rule per protocol reference.

---

## What Was Changed (commit `3b8cfed` — 4 files, +144 lines)

### `permission_enforcer.rs` — new `protected_write_violation()`

Standalone pub fn blocking two classes of paths:
- `.env`, `.env.*`, `*.env` — contain secrets, must never be written by the agent
- `~/.claude/settings.json` — requires explicit plan approval before editing

Includes test `protected_write_violation_blocks_env_and_settings` covering 5 cases.

### `tools/src/lib.rs` — dispatch checks in `write_file` and `edit_file`

Before `maybe_enforce_permission_check`, both arms now:
1. Call `protected_write_violation(path)` — hard-blocks `.env` and `settings.json`
2. Call `enf.check_file_write(path, cwd)` in `WorkspaceWrite` mode — blocks out-of-workspace writes

`WorkspaceWrite` mode guard preserves existing test expectations: `ReadOnly` denials continue to flow through the existing `check()` path with the expected error messages.

### `conversation.rs` — spec context injection

New field `spec_context_dir: Option<PathBuf>` on `ConversationRuntime`.
New public builder `with_spec_context_dir(dir: PathBuf) -> Self`.
New private helper `build_open_spec_context()`:
- Returns `None` when `spec_context_dir` is `None` or `specs/` doesn't exist
- Scans `specs/*.md` for lines starting with `- [ ]`
- Returns `<system-reminder>` block prepended to user input in `run_turn()`

`run_turn()` now injects open spec criteria before `push_user_text()`.

### `main.rs` — wire `with_spec_context_dir`

`build_runtime_with_plugin_state()` now calls `.with_spec_context_dir(cwd)` using `std::env::current_dir()`, making spec injection active for all main CLI sessions.

---

## Acceptance Criteria Verification

| Criterion | Status |
|-----------|--------|
| `protected_write_violation(".env")` → Some | ✅ (test passes) |
| `protected_write_violation(".env.local")` → Some | ✅ (test passes) |
| `protected_write_violation("$HOME/.claude/settings.json")` → Some | ✅ (test passes) |
| `protected_write_violation("src/main.rs")` → None | ✅ (test passes) |
| `write_file` + `.env` → BLOCKED | ✅ (protected_write_violation wired) |
| `edit_file` + `.env` → BLOCKED | ✅ (protected_write_violation wired) |
| Out-of-workspace in WorkspaceWrite mode → BLOCKED | ✅ (check_file_write wired) |
| `with_spec_context_dir()` builder exists | ✅ |
| `build_open_spec_context()` → None when no specs dir | ✅ (returns None when dir is None) |
| Open criteria injected as `<system-reminder>` | ✅ |
| Main CLI wires `with_spec_context_dir(cwd)` | ✅ |
| `cargo test --workspace` — 0 failures | ✅ |
| `cargo clippy --workspace --all-targets` — exit 0 | ✅ |

---

## Test Results (final, after adding enforcement tests)

```
$ cd rust && cargo test --workspace -- --test-threads=1 2>&1 | grep "^test result:" | grep -v "0 passed"
test result: ok. 48 passed; 0 failed
test result: ok. 9 passed; 0 failed
test result: ok. 5 passed; 0 failed
test result: ok. 4 passed; 0 failed
test result: ok. 26 passed; 0 failed
test result: ok. 3 passed; 0 failed
test result: ok. 33 passed; 0 failed
test result: ok. 350 passed; 0 failed   ← runtime: +2 spec_context tests
test result: ok. 103 passed; 0 failed
test result: ok. 4 passed; 0 failed
test result: ok. 1 passed; 0 failed
test result: ok. 4 passed; 0 failed
test result: ok. 3 passed; 0 failed
test result: ok. 53 passed; 0 failed    ← tools: +4 dispatch protection tests
```

**Total: 646 passed, 0 failed** across all workspace crates. Exit code 0.

### New enforcement tests (commit `3a5330d`)

**`tools/src/lib.rs` — dispatch wiring (4 tests):**
- `write_file_with_env_path_is_blocked_before_dispatch` — asserts `Err("BLOCKED — protected path: ...")`
- `edit_file_with_env_path_is_blocked_before_dispatch` — asserts `.env.local` also blocked
- `write_file_with_settings_json_path_is_blocked_before_dispatch` — asserts `$HOME/.claude/settings.json` blocked
- `write_file_out_of_workspace_blocked_in_workspace_write_mode` — asserts `/tmp/...` blocked via boundary check

**`conversation.rs` — spec injection (2 tests, via `pub(crate) build_open_spec_context`):**
- `spec_context_injected_when_open_criteria_exist` — creates `specs/test.md` with `- [ ] open criterion`, asserts `<system-reminder>` block returned
- `spec_context_none_when_no_specs_dir` — asserts `None` when no `specs/` exists

---

## Lint Results

```
$ cd rust && cargo clippy --workspace --all-targets 2>&1 | grep "^error" | wc -l
0
```

Zero errors. Exit code 0.
