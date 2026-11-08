# HW3 Agent Worklog

If no agent or AI tool was used, say so explicitly. If one was used, record
each material task, inspect the resulting diff, and record one recommendation
you rejected or revised; if none was rejectable, explain why.

Tool used: Claude Code (Claude Opus 5.5), desktop app, working in this
repository and in a scratchpad outside it. Every change was reviewed by the
student as a diff before the student committed it manually.

| Date | Tool/task | Student review | Evidence |
| --- | --- | - | --- |
| 2026-11-08 | Entry 1: template reading, plan, decisions R-1…R-18 | Read the plan and every R-n option; asked for a theory walkthrough and a test-by-test explanation; revised R-14 and chose R-15 against the recommendation. | `PLAN.md` |
| 2026-11-08 | Entry 2: baseline run and crash diagnosis (T0) | Reviewed the baseline log and the crash diagnosis; paused the probe run over macOS crash dialogs; chose R-17/R-18; restored the assets rewritten by Xcode. | `artifacts/T0-baseline.log` |
| 2026-11-08 | Entry 3: starter crash workaround, R-19 (T0 fix) | Reviewed the 6-line StudentStore diff, the green log and both mutant logs; chose R-19 (b) after the equivalent-mutant finding. | `artifacts/T0-green.log`, `artifacts/T0-red-mutant-remove-deinit.log`, `artifacts/T0-mutant-plain-deinit-survived.log` |
| 2026-11-08 | Entry 4: store characterization tests (T1), CI of `fix(T0)` | Reviewed the six store tests, the TestSupport factory, the green log and all seven mutant logs; chose R-20 (b); re-ran the failed CI job. | `artifacts/T1-green.log`, `artifacts/T1-red-mutant-*.log` (7) |

---

## Entry 1 — Planning (2026-11-08)

### Tool/agent task

Asked the agent to read the whole template (README, tasks and grades,
submission rules, plan/worklog templates, `.gitignore`, CI workflow, project
settings, sources, starter tests) and, without writing code, propose a task
split with approach, edge cases, risks and planned tests, plus the decisions
that are the student's to make. On request, the agent explained the
assignment and the theory behind it (app/scene lifecycle, view controller
lifecycle, navigation stack, table view and cell reuse, Auto Layout and
SnapKit, MVC, reference vs value types and the single shared store, exact
case-sensitive filtering, accessibility identifiers vs labels, Dynamic Type,
force unwraps, unit vs UI tests, `@MainActor`, `xcodebuild` and CI) and then
listed which rule each planned unit and UI test checks.

### Output reviewed

- The agent pointed out that this homework is not a Swift Package: it is an
  Xcode iOS app project (UIKit + SnapKit 6.0.0), Swift language mode 5 with
  `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, all types `internal`, so unit
  tests need `@testable import`; the supplied `StudentStore` already
  implements filtering and the bonus mutations.
- Task split T0-T7 and decisions R-1…R-16 with options and recommendations;
  the student chose R-15 (no `upstream` remote) against the recommendation and
  revised R-14 from "no repeats" to "unit 20x, UI 5x".
- Checked before relying on them: Xcode 26.3 and an iPhone 17 simulator are
  installed; `xcodebuild -list` shows the `StudentDirectory` scheme; the
  template CI run on `938bf69` is green; `gh repo fork --clone` would make
  `upstream` the default `gh` repository, so the agent proposed
  `gh repo fork --clone=false` + `git clone` instead.
- The fork and the clone were created by the student; the agent only verified
  them (public fork, parent `Mat-CauThon/apd-hw-3`, HEAD `938bf69`, only an
  `origin` remote, Actions workflow `active` after the student enabled it).

### Accepted/rejected/revised decision

As with previous assignments, I began by clarifying the working format that suits me best for these tasks. We went over the nuances and the assignment itself; then, following my guidance, the AI ​​made 14 architectural decisions and established an overall work plan. I also asked for a detailed explanation of the proposed UI and unit tests, which I then approved. In most cases, I accepted the implementation options recommended by the AI - not out of blind trust, but because I understood the subject matter and the pros and cons of each approach. The only decision I initially made and later changed concerned re-running tests to verify their stability. At first, I opted against re-runs, fearing that doing so would take too long and put too much strain on my laptop (which turned out to be the case). However, I ultimately decided to include the re-runs, as a single "green" (passing) test run is not sufficient proof that a test is stable.

The one recommendation I did not follow was R-15: the AI recommended keeping the
instructor's repository as a read-only `upstream` remote, and I chose to keep
only `origin`. The accepted risk (template fixes are not visible automatically)
is recorded in `PLAN.md` and covered by a `git ls-remote` check in T0 and T7.

### Verification command/result

- `xcodebuild -list -project StudentDirectory.xcodeproj` -> scheme
  `StudentDirectory`, targets `StudentDirectory`, `StudentDirectoryTests`,
  `StudentDirectoryUITests`.
- `gh run list -R Mat-CauThon/apd-hw-3` -> latest template run `success`.
- `git ls-remote https://github.com/Mat-CauThon/apd-hw-3.git HEAD` ->
  `938bf69c34131616d693a67c3706d8dd41543388` (R-16).

### Artifact links

- `PLAN.md` (Scope, Approach, Decisions, Acceptance criteria, Risks)

---

## Entry 2 — Baseline run and crash diagnosis (T0) (2026-11-08)

### Tool/agent task

Run the exact required command on the untouched template, record it, and
verify the first language/tool facts in throwaway scratchpad copies.

### Output reviewed

- The exact command failed on the untouched template:
  `testStarterStoreIsConstructible` crashed with `SIGABRT` while a
  `StudentStore` was being released; the template CI is green because it uses
  Xcode 16.4, while the local machine uses Xcode 26.3.
- Diagnosis in scratchpad copies (repository untouched): the implicit deinit
  of every plain app class is MainActor-isolated under Xcode 26 and crashes
  inside the XCTest host; `@MainActor` on the test class does not help; the
  app itself releasing a store at launch did not crash; an explicit deinit in
  `StudentStore` removed the crash. Details: `PLAN.md` -> Verified language
  facts 3-8.
- Options R-17 and R-18 were presented; the student chose R-17 (a)+(d)
  (workaround + inform the instructor) and R-18 (a) (push after each task).
- Agent mistakes, recorded honestly:
  - The agent's first hypothesis (the iOS 18.0 deployment target and its
    back-deploy shim cause the crash) was wrong; the agent disproved it itself
    with a `IPHONEOS_DEPLOYMENT_TARGET=26.0` run.
  - The agent's first probe run mixed an app-launch probe with unit probes in
    one run, which would have crashed the unit-test host and mixed the
    results; the agent noticed it after the student interrupted the run and
    split it into C1/C2.
  - The student noticed macOS crash dialogs ("You can't use this version of
    the application…") during the probe runs and asked about them; the agent
    explained they come from the crashing simulator app and checked that no
    `xcodebuild` process was still running.
- Before the `docs(T0)` commit the student's `git add` failed (terminal was
  in the parent folder). The agent's status check then found 11 protected
  `Assets.xcassets/avatar-*/Contents.json` files modified (2x/3x slots,
  `"author" : "xcode"`) and already staged; neither the agent nor the student
  changed them on purpose. Most likely the open Xcode GUI rewrote them (not
  proven). The student restored them with
  `git restore --staged --worktree StudentDirectory/Assets.xcassets`; the
  protected-file check passed again.

### Accepted/rejected/revised decision

Problem: on my machine (Xcode 26.3) the exact required command fails on the
untouched template. The starter test `testStarterStoreIsConstructible` crashes
(SIGABRT) when a `StudentStore` is released: with the project's default
MainActor isolation, Xcode 26 makes the implicit deinit of plain classes
isolated, and that path crashes inside the XCTest host. The template CI is
green only because it builds with Xcode 16.4, so my local toolchain and CI
differ, and every unit test that creates and releases a store would crash
locally.

- Accepted R-17 (a)+(d): a minimal workaround in `StudentStore` in a separate
  `fix(T0)` commit, and I report the problem to you. Without it I
  cannot get a reliable local red/green cycle; a separate commit keeps the
  change to supplied code visible and easy to revert if the template is fixed.
- Rejected R-17 (b) "leave the template untouched and rely on CI": the final
  local run would always be red and my tests would have to keep every store
  alive on purpose.
- Rejected R-17 (c) "install Xcode 16.4": a large download for a project that
  is clearly made for Xcode 26.
- Accepted R-18 (a): I push after every task, so CI on Xcode 16.4 checks each
  change early instead of at submission.
- I paused the diagnosis when macOS crash dialogs appeared; after the
  explanation I let the agent continue.

### Verification command/result

- `xcodebuild -project StudentDirectory.xcodeproj -scheme StudentDirectory -destination 'platform=iOS Simulator,name=iPhone 17' test`
  on `938bf69` -> `** TEST FAILED **`, exit 65, 3 passed / 1 failed
  ("Test crashed with signal abrt").
- Probe runs: see `PLAN.md` -> Run log.

### Artifact links

- `artifacts/T0-baseline.log` (excerpt, `.xcresult` summary, crash stack)

---

## Entry 3 — Starter crash workaround (T0 fix) (2026-11-08)

### Tool/agent task

Apply the R-17 workaround to `StudentStore`, prove it with a green run of the
exact command plus repeats (R-14) and with a mutant, and keep the change to
the supplied file minimal.

### Output reviewed

- First form (as agreed in R-17):
  `#if compiler(>=6.2) nonisolated deinit {} #endif`. Exact command 4/4,
  unit tests 20/20, UI tests 5/5.
- Agent mistake (found by the agent itself): the agent expected the mutant
  "drop `nonisolated`" to bring the crash back, i.e. it assumed the keyword
  was essential. The mutant survived. Disassembly of the deinit showed that
  `deinit {}` and `nonisolated deinit {}` compile to the same code; only the
  implicit deinit is isolated (`PLAN.md` -> fact 12). The survived mutant is
  kept as evidence of the failed attempt.
- New decision R-19 presented (keep the first form vs plain `deinit {}`); the
  student chose plain `deinit {}` with an explaining comment, no `#if`. Final
  diff of `StudentDirectory/StudentStore.swift`: 6 added lines (4 comment
  lines, `deinit {}`, one blank line); no signature, stored property or name
  changed.
- Green again with R-19: exact command 4/4, unit tests 20/20, UI tests 5/5.
  One-line mutant `remove-deinit` (delete `deinit {}`, keep the comment) makes
  the starter test crash again, so the starter test proves the workaround.
- Tooling problems found and fixed by the agent before the commit:
  - regenerating `T0-baseline.log` failed because Xcode had already deleted
    the baseline `.xcresult`, and the crash section was appended twice; the
    duplicate was removed (`PLAN.md` -> fact 11);
  - `xcodebuild` printed 19 of 20 `Test case` lines in the 20x run although
    `.xcresult` shows 20/20; repetition counts are now read from `.xcresult`
    (fact 13);
  - the protected-file check script first reported the allowed `deinit {}`
    as a failure (whitespace in the comparison); fixed and checked against a
    copy with a renamed parameter, which fails as expected.
- CI has not built `deinit {}` with Xcode 16.4 yet; this is checked after the
  student pushes this commit (R-18) and recorded in the next entry (R-11).

### Accepted/rejected/revised decision

Accepted R-19 (b): plain `deinit {}` instead of the agreed
`#if compiler(>=6.2) nonisolated deinit {} #endif`. The surviving mutant and
the disassembly showed that both forms compile to the same code, so the `#if`
and `nonisolated` only added a dependency on unverified Xcode 16.4 behaviour.
`deinit {}` is ordinary syntax for every Swift version; the code comment and
the `remove-deinit` mutant protect it from being deleted as dead code.

### Verification command/result

- `xcodebuild -project StudentDirectory.xcodeproj -scheme StudentDirectory -destination 'platform=iOS Simulator,name=iPhone 17' test`
  -> `** TEST SUCCEEDED **`, 4/4.
- Same with `-only-testing:StudentDirectoryTests -test-iterations 20` -> each
  unit test 20/20; with `-only-testing:StudentDirectoryUITests -test-iterations 5`
  -> each UI test 5/5 (counts from `.xcresult`).
- Mutant `remove-deinit`,
  `-only-testing:StudentDirectoryTests/StarterStudentDirectoryTests/testStarterStoreIsConstructible`
  -> `** TEST FAILED **`, "Test crashed with signal abrt".
- Protected-file check vs `938bf69`: protected paths unchanged; the only
  declaration change in `StudentStore.swift` is `deinit {}`.

### Artifact links

- `artifacts/T0-green.log` (exact command, unit 20x, UI 5x)
- `artifacts/T0-red-mutant-remove-deinit.log` (mutant diff + crash)
- `artifacts/T0-mutant-plain-deinit-survived.log` (failed attempt, equivalent mutant)

---

## Entry 4 — Store characterization tests (T1) (2026-11-08)

### Tool/agent task

Write the agreed unit tests for the supplied `StudentStore` (seed order,
injected students, exact case-sensitive subject filter in store order, unknown
subject), run them green with repeats, and prove each test with a one-line
mutant (R-5). Also check the first CI run of `fix(T0)` (R-11, R-18).

### Output reviewed

- New files: `StudentDirectoryTests/StudentStoreTests.swift` (6 tests in
  `StudentStoreTests`, `@MainActor`, every assertion message names its rule)
  and `StudentDirectoryTests/TestSupport.swift` (`makeStudent(id:name:subjects:)`,
  UUID built from bytes, so no `!`). No app code changed.
- While planning the mutants, the agent noticed that the planned data for the
  order test (seed Physics) cannot catch a sorting bug and checked it with a
  script: every seed subject list is already in id order and Physics is also
  in name order. New decision R-20; the student chose custom out-of-order data.
  The same problem exists for the planned T4 order test and will be raised
  before T4.
- Green: 8/8 unit tests, every test 20/20 repetitions, exact command 10/10.
- Mutants: 7 one-line changes of `StudentStore.swift`, each run against its
  target test only; all 7 failed with the expected rule message (`substring`
  on `"Phys"`, `trim` on `"Physics "`).
- CI of `fix(T0)` (run `42516097673`): attempt 1 failed before building
  (`Unable to find a device matching the provided destination specifier`).
  Agent mistake, found by the agent itself in the next check: it first
  explained this as "the new runner image has no simulators"; other forks were
  green on the same image the same day. The student re-ran the job; attempt 2
  passed 4/4 with Xcode 16.4, so `deinit {}` also builds on CI.

### Accepted/rejected/revised decision

Accepted R-20 (b): the order test uses a custom store with ids and names out
of order. The planned seed Physics data is already in id and name order, so a
sorting bug would have passed unnoticed. Accepted the T1 conventions (factory
`makeStudent`, the error helper deferred to T6, one `test(T1)` commit as in
R-5). CI attempt 1 of `fix(T0)` failed only because the runner had no
simulator; I re-ran it and it passed with Xcode 16.4.

### Verification command/result

- `xcodebuild … test -only-testing:StudentDirectoryTests` -> 8/8 passed.
- Same with `-test-iterations 20` -> every unit test 20/20 (from `.xcresult`).
- Exact command -> `** TEST SUCCEEDED **`, 10/10.
- Mutants `seed-reversed`, `ignore-injected`, `sort-by-name`,
  `case-insensitive`, `substring`, `trim`, `all-on-no-match` -> each
  `** TEST FAILED **` on its target test.
- CI: https://github.com/ArseniiKlimenko/apd-hw-3-Klimenko/actions/runs/42516097673
  -> attempt 1 failure (no simulator), attempt 2 success.
- Protected-file check vs `938bf69`: unchanged (only the R-19 `deinit {}` in
  `StudentStore.swift`).

### Artifact links

- `artifacts/T1-green.log` (all unit tests, 20x, exact command)
- `artifacts/T1-red-mutant-seed-reversed.log`, `…-ignore-injected.log`,
  `…-sort-by-name.log`, `…-case-insensitive.log`, `…-substring.log`,
  `…-trim.log`, `…-all-on-no-match.log`

---

## Final review

- Agent/tool disclosure: TODO (student)
- Accepted and rejected/revised recommendations: TODO (student)
- Exact local test command and result: TODO (student)
- CI URL/status: TODO (student)
- Known limitation or remaining risk: TODO (student)
