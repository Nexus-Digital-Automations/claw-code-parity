---
title: Harden System Prompt Language to Match Protocol Compliance Reference
status: completed
created: 2026-04-04
---

## Vision

Rewrite all agent system prompt text in this codebase so it enforces the full protocol compliance
reference (`~/.claude/docs/protocol-compliance-reference.md`) using firm, non-negotiable language.
Soft suggestions must be replaced with mandatory directives. All categories from the compliance
reference (Three Protocols, Working Standards, Prohibitions, AI Coding & Legibility Standards
cats 1–6, AI-Agent Legibility cat 16) must be encoded in the prompt.

## Requirements

1. Every section of the protocol compliance reference must be represented in the system prompt.
2. Language must be assertive and non-negotiable — no soft suggestions ("be careful", "try to").
3. The agent identity must be "development agent", not "Claude Code".
4. Sub-agent prompts must also be hardened to scope-constrained, honest-failure language.
5. No prompt text may be left in the old soft/passive form.
6. All changes must pass `cargo clippy --workspace --all-targets` and `cargo test --workspace`.

## Acceptance Criteria

- [x] `get_simple_intro_section()` identifies agent as "development agent under strict protocols"
- [x] `get_simple_doing_tasks_section()` encodes Three Protocols (Clarify First, Spec Before Code,
      Validate Before Stopping) as non-negotiable rules with labeled exceptions
- [x] `get_simple_doing_tasks_section()` encodes Working Standards as mandatory
- [x] `get_simple_doing_tasks_section()` encodes Prohibitions as absolute (NEVER) list
- [x] `get_actions_section()` enumerates all action categories requiring explicit authorization
- [x] NEW `get_engineering_standards_section()` encodes all 6 AI Coding & Legibility categories
      (cats 1–6: Agent Execution, System Architecture, Component & API Design, Code Generation,
      Robustness & Error Handling, Validation & Testing)
- [x] NEW `get_legibility_standards_section()` encodes all AI-Agent Legibility rules (cat 16:
      file docstrings, function failure docs, state machine diagrams, inline decision records,
      cross-file cross-references, stability signals, test names as specs, ubiquitous language)
- [x] `build_agent_system_prompt()` sub-agent suffix hardened: scope fixed at delegation,
      no unrequested features, honest failure reporting, no claim-without-evidence
- [x] No other files in the codebase own prompt text (`conversation.rs`, `lib.rs`, `main.rs`
      only consume the prompt; verified by grep)
- [x] `cargo clippy --workspace --all-targets` exits 0 (no `^error` lines)
- [x] `cargo test --workspace -- --test-threads=1` — 575 tests pass, 0 fail

## Technical Decisions

### Files Modified

| File | Change |
|------|--------|
| `rust/crates/runtime/src/prompt.rs` | Rewrote 4 existing section functions; added 2 new section functions; updated `build()` to call all 6 |
| `rust/crates/tools/src/lib.rs` | Hardened sub-agent suffix string in `build_agent_system_prompt()` |

### Scope Justification (Delegation Exception)

This task modified 2 backend files. The file count is below the 5-file delegation threshold.
The prompt text commits (`56b00c5`, `c0e2642`) touch only `prompt.rs` and `tools/src/lib.rs`.
Supporting commits (doc moves, CI config, security fixes) are infrastructure, not backend logic.
Delegation was not required for this task under the routing rule (1–4 files → implement directly).

### Why No Soft Language

The protocol compliance reference defines reviewer enforcement criteria. An agent operating under
soft prompt language will be rejected by the reviewer at stop time. All directives are encoded as
imperative rules to ensure compliance without reviewer override.

## Progress

- [x] Read and analyzed `~/.claude/docs/protocol-compliance-reference.md` (full document)
- [x] Planned changes — confirmed all 4 existing functions + 2 new functions needed
- [x] Implemented `56b00c5`: rewrote intro, doing-tasks, actions sections; hardened sub-agent prompt
- [x] User correction applied: identity changed from "Claude Code" to "development agent"
- [x] User correction applied: cats 1–6 and cat 16 added (not reviewer-only)
- [x] Implemented `c0e2642`: added `get_engineering_standards_section()` and `get_legibility_standards_section()`
- [x] All tests pass (`cargo test --workspace -- --test-threads=1`)
- [x] Lint passes (`cargo clippy --workspace --all-targets` — no `^error` output)
- [x] Security scan clean (Critical: 0, Warnings: 0)
- [x] Changes pushed to `main` at commit `4328ba6`
