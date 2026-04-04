---
title: Multi-Provider Support — DeepSeek and Kimi K2
status: completed
created: 2026-04-04
---

## Vision

Extend Claw Code to support DeepSeek and Kimi K2 in addition to the existing Anthropic, xAI, and
OpenAI providers. Both new providers expose OpenAI-compatible APIs, so they can be wired in using
the existing `OpenAiCompatClient` without new HTTP code.

## Requirements

1. `claw --model deepseek` routes requests to DeepSeek's API (`https://api.deepseek.com/v1`)
2. `claw --model kimi` routes requests to Kimi's API (`https://api.moonshot.cn/v1`)
3. API keys are read from env vars (`DEEPSEEK_API_KEY`, `KIMI_API_KEY`)
4. Base URLs are overridable via env vars (`DEEPSEEK_BASE_URL`, `KIMI_BASE_URL`)
5. All existing providers continue to work without regression
6. CLI aliases cover common shorthands (see table below)

## Acceptance Criteria

- [x] `resolve_model_alias("deepseek")` → `"deepseek-chat"`
- [x] `resolve_model_alias("r1")` → `"deepseek-reasoner"`
- [x] `resolve_model_alias("kimi")` → `"kimi-k2"`
- [x] `detect_provider_kind("deepseek-chat")` → `ProviderKind::DeepSeek`
- [x] `detect_provider_kind("kimi-k2")` → `ProviderKind::Kimi`
- [x] `ProviderClient::from_model("deepseek-chat")` constructs `OpenAiCompatClient` with DeepSeek config
- [x] `ProviderClient::from_model("kimi-k2")` constructs `OpenAiCompatClient` with Kimi config
- [x] All existing tests pass (575 tests, 0 failures)
- [x] `cargo clippy --workspace --all-targets` — no `^error` output

## Technical Decisions

### Files Modified (4 — below 5-file delegation threshold)

| File | Change |
|------|--------|
| `rust/crates/api/src/providers/openai_compat.rs` | Added `deepseek()` and `kimi()` config factories; new base URL constants; `DEEPSEEK_ENV_VARS`/`KIMI_ENV_VARS`; extended `credential_env_vars()` |
| `rust/crates/api/src/providers/mod.rs` | Added `DeepSeek`/`Kimi` to `ProviderKind`; 5 new `MODEL_REGISTRY` entries; extended alias resolution, `metadata_for_model`, `detect_provider_kind` (deepseek/kimi checked before openai/xai in env-var fallback) |
| `rust/crates/api/src/client.rs` | Added `DeepSeek`/`Kimi` enum variants; factory match arms; updated all delegating methods |
| `rust/crates/rusty-claude-cli/src/main.rs` | Added CLI-level aliases: `deepseek`, `r1`/`deepseek-r1`, `kimi`/`kimi-k2` |

### Provider Details

| Provider | Base URL | Key Env | Models | CLI Aliases |
|----------|----------|---------|--------|-------------|
| DeepSeek | `https://api.deepseek.com/v1` | `DEEPSEEK_API_KEY` | `deepseek-chat` (V3), `deepseek-reasoner` (R1) | `deepseek`, `r1`, `deepseek-r1` |
| Kimi K2 | `https://api.moonshot.cn/v1` | `KIMI_API_KEY` | `kimi-k2` | `kimi`, `kimi-k2` |

### Retrospective Note (Spec Created After Implementation)

This spec was created after implementation because the user request ("configure it to work with
multiple AI providers") came without a prior clarify-first round and the implementation was
straightforward enough to execute against an approved plan. The plan file at
`~/.claude/plans/streamed-waddling-blum.md` served as the pre-implementation specification and was
explicitly approved by the user before any code was written. This spec formalizes that plan as a
permanent record in the `specs/` directory per protocol.

## Progress

- [x] User request received and plan created (plan file approved before coding)
- [x] Implemented all four file changes
- [x] `cargo clippy --workspace --all-targets` — exit 0, no `^error` lines
- [x] `cargo test --workspace -- --test-threads=1` — 575 passed, 0 failed
- [x] Committed as `9e868d5` and pushed to `main`
