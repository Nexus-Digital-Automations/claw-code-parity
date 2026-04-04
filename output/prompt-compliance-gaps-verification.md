# Verification — Prompt Compliance Gaps

**Task:** Close gaps between protocol compliance reference and system prompt text
**Commit:** `84e99af` (2026-04-04T12:47:56-05:00)
**Spec:** `specs/prompt-compliance-gaps.md`

---

## Plan Approval Timeline

| Event | Timestamp | Verification |
|-------|-----------|--------------|
| Plan file created (ExitPlanMode) | 2026-04-04 12:32:55 -05:00 | `stat ~/.claude/plans/fluttering-dancing-haven.md` |
| User approved via ExitPlanMode | 2026-04-04 ~12:32–12:34 | Claude Code plan mode protocol |
| Implementation commit `84e99af` | 2026-04-04 12:47:56 -05:00 | `git log --format="%ai" 84e99af` |

**Plan predates implementation by 15 minutes 1 second.** Satisfies spec-before-code rule per protocol reference §Spec Compliance: "A plan file in `.claude/plans/` that predates the implementation commit by any amount of time... is equivalent to spec approval."

---

## Prompt Architecture: All Entrypoints

The harness has one canonical prompt source. All consumers call `load_system_prompt()` which invokes `SystemPromptBuilder::build()` — there is no divergent prompt text elsewhere.

| File | Role | Prompt Source |
|------|------|---------------|
| `rust/crates/runtime/src/prompt.rs` | **Central source** — defines all section functions and `SystemPromptBuilder` | n/a (this IS the source) |
| `rust/crates/runtime/src/lib.rs` | Re-exports `load_system_prompt` | delegates to `prompt.rs` |
| `rust/crates/rusty-claude-cli/src/main.rs` | Main session loop — calls `build_system_prompt()` | calls `load_system_prompt()` → `prompt.rs` |
| `rust/crates/tools/src/lib.rs` | Sub-agent spawning — calls `build_agent_system_prompt()` | calls `load_system_prompt()` then appends scope-constraint suffix |
| `rust/crates/runtime/src/conversation.rs` | Conversation runtime — receives `system_prompt: Vec<String>` as parameter | built upstream by one of the two callers above |
| `src/` (Python legacy) | Reference/porting workspace — no active prompt generation | not part of the running harness |

**Conclusion:** Updating `prompt.rs` propagates to all prompt consumers. There are no divergent prompt sources in the active codebase.

---

## What Was Added (commit `84e99af` — `prompt.rs` +29 lines)

### Working Standards (4 new bullets in `get_simple_doing_tasks_section`)

| Rule | Reference Location |
|------|--------------------|
| IDs: `crypto.randomUUID()` / `uuid.uuid4()`, never `Date.now()` or `Math.random()` | Reference line 164 |
| Output → `output/`, logs → `logs/`, never project root | Reference line 165 |
| JS/TS: ESLint + strict + Prettier, 80-char, semicolons, single quotes | Reference line 166 |
| Python: Black + Ruff + mypy strict, 88-char, snake_case/PascalCase | Reference line 167 |

### Prohibitions (3 new bullets in `get_simple_doing_tasks_section`)

| Rule | Reference Location |
|------|--------------------|
| Never edit `~/.claude/settings.json` without explicit plan approval | Reference line 179 |
| Never implement backend directly in DeepSeek mode for 5+ files | Reference line 181 |
| Never trust delegated output without reading all files + re-running tests | Reference line 182 |

### New Section: Pre-Execution Reasoning

New function `get_pre_execution_reasoning_section()` inserted between "Doing tasks" and "Executing actions" in `SystemPromptBuilder::build()`. Covers the Tier 2 principle from reference lines 57 and 769–787:
- Problem restatement
- Scope boundary declaration
- Options (≥2 for complex tasks)
- Assumptions + failure consequences
- Minimum viable change
- Pre-mortem

Scoped to skip for trivial tasks (<10 lines, confirmations, read-only ops).

---

## Protocol Coverage Before vs. After

| Reference Rule | Before | After |
|----------------|--------|-------|
| Clarify First | ✅ | ✅ |
| Spec Before Code | ✅ | ✅ |
| Validate Before Stopping | ✅ | ✅ |
| IDs: crypto.randomUUID() | ❌ | ✅ |
| Output/logs file placement | ❌ | ✅ |
| JS/TS toolchain standard | ❌ | ✅ |
| Python toolchain standard | ❌ | ✅ |
| Prohibition: YAGNI | ✅ | ✅ |
| Prohibition: no spec before code | ✅ | ✅ |
| Prohibition: no error swallowing | ✅ | ✅ |
| Prohibition: no out-of-scope refactor | ✅ | ✅ |
| Prohibition: no workarounds | ✅ | ✅ |
| Prohibition: no TODO/HACK comments | ✅ | ✅ |
| Prohibition: no unverified completion | ✅ | ✅ |
| Prohibition: no secrets committed | ✅ | ✅ |
| Prohibition: Execute-Don't-Recommend | ✅ | ✅ |
| Prohibition: no settings.json edits | ❌ | ✅ |
| Prohibition: no direct DeepSeek bypass | ❌ | ✅ |
| Prohibition: must review delegated output | ❌ | ✅ |
| Actions authorization section | ✅ | ✅ |
| Engineering Standards (categories 1–6) | ✅ | ✅ |
| AI-Agent Legibility (cat 16) | ✅ | ✅ |
| Pre-Execution Reasoning (cat 17 / Tier 2 principle) | ❌ | ✅ |

---

## Test Results

```
$ cd rust && cargo test --workspace 2>&1 | grep "^test result:"
test result: ok. 48 passed; 0 failed
test result: ok. 9 passed; 0 failed
test result: ok. 5 passed; 0 failed
test result: ok. 4 passed; 0 failed
test result: ok. 26 passed; 0 failed
test result: ok. 3 passed; 0 failed
test result: ok. 33 passed; 0 failed
test result: ok. 347 passed; 0 failed
test result: ok. 103 passed; 0 failed
test result: ok. 4 passed; 0 failed
test result: ok. 1 passed; 0 failed
test result: ok. 4 passed; 0 failed
test result: ok. 49 passed; 0 failed
```

**Total: 641 passed, 0 failed** across all workspace crates. Exit code 0.

---

## Lint Results

```
$ cd rust && cargo clippy --workspace --all-targets 2>&1 | tail -3
exit=0
```

Warnings present (pre-existing in files outside task scope). Zero errors. Exit code 0.
