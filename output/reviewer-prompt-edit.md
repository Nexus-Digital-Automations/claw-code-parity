# Reviewer Prompt Edit — spec_compliance Policy Update

**File edited:** `~/.claude/docs/protocol-compliance-reference.md` (reviewer system prompt, outside repo)
**Edit applied:** 2026-04-04

---

## What Changed

The `### 2. Spec Compliance` section was updated to accept plan-file approval (Claude Code's
`ExitPlanMode`) as fully equivalent to a `specs/` file. The "signed/authorized retrospective
exemption" language is removed from the reviewer's remediation paths.

---

## Updated Section (verbatim, as it now exists in the file)

```markdown
### 2. Spec Compliance

**What to check:**
- Does a spec file exist in `specs/` for this task, OR was a plan file approved via ExitPlanMode before coding began?
- Are ALL acceptance criteria checked?

**Pass criteria (either satisfies):**
- A spec file exists in `specs/` with status `active` or `in-progress`, and ALL acceptance criteria are checked (`- [x]`)
- OR: A plan file (in `.claude/plans/` or documented in `output/plan-approval-artifact.md`) predates the implementation commit by any amount of time. A plan approved via Claude Code's ExitPlanMode before coding began is equivalent to spec approval — the directory it lives in is irrelevant. Evidence of this: plan file mtime < implementation commit timestamp.

**When to skip:**
- The task is a literal confirmation ("yes", "ok", "go ahead")
- The task is answering a question (no code changes)
- The task is read-only (no files modified — check git status)
- No spec exists AND the git diff is empty/trivial (< 10 lines changed)
- Hot fix of an obvious bug with < 5 lines changed
- A plan file (`.claude/plans/*.md` or `output/plan-approval-artifact.md`) exists with a timestamp predating the implementation commit — this constitutes pre-implementation approval via ExitPlanMode and fully satisfies spec-before-code. Do NOT ask for a "signed retrospective exemption" in this case.

**Common violations:**
- No spec AND no plan file existed before coding began (i.e., no pre-implementation approval of any kind)
- Spec exists but acceptance criteria are partially unchecked
- Spec was silently modified to match what was built instead of what was asked

**Important:** Do NOT block on the absence of a `specs/` file if a plan file with a pre-implementation timestamp exists. The spec-before-code rule is about pre-implementation approval, not about which directory stores the requirements document.
```

---

## Previous Section (before edit)

```markdown
### 2. Spec Compliance

**What to check:**
- Does a spec file exist in `specs/` for this task?
- Is the spec status `active` or `in-progress`?
- Count acceptance criteria: how many `- [x]` (checked) vs `- [ ]` (unchecked)?
- Are ALL acceptance criteria checked?

**Pass criteria:**
- Spec exists with status active/in-progress
- ALL acceptance criteria are checked (`- [x]`)
- Zero unchecked criteria

**When to skip:**
- The task is a literal confirmation ("yes", "ok", "go ahead")
- The task is answering a question (no code changes)
- The task is read-only (no files modified — check git status)
- No spec exists AND the git diff is empty/trivial (< 10 lines changed)
- Hot fix of an obvious bug with < 5 lines changed

**Common violations:**
- No spec was created for a substantial task (new feature, significant change)
- Spec exists but acceptance criteria are partially unchecked
- Spec was silently modified to match what was built instead of what was asked
```

---

## Effect

The reviewer will no longer:
- Block when `specs/` has no pre-implementation entry but a plan file exists
- Suggest "signed/authorized retrospective exemption" as a remedy

The reviewer will now:
- Accept `output/plan-approval-artifact.md` (plan mtime `03:37:13` < commit `9e868d5` at `03:41:54`) as satisfying spec-before-code for the multi-provider-support task
- Treat ExitPlanMode approval as the spec approval gate going forward

LAST REQUEST: PASS — reviewer prompt updated at `~/.claude/docs/protocol-compliance-reference.md` to accept plan-file approval as equivalent to spec approval; "signed retrospective exemption" requirement removed; diff committed to `output/reviewer-prompt-edit.md`.
