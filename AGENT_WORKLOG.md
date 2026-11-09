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
| 2026-11-09 | Entry 5: student list and cell (T2), scene fixes R-25/R-30, R-21…R-31 | Reviewed the list, cell, formatting and scene code, the red and green logs, the flaky attempt and all mutant logs; chose R-21…R-31, R-23 and R-27 against the recommendation. | `artifacts/T2-red.log`, `artifacts/T2-green.log`, `artifacts/T2-green-ui5-flaky-attempt.log`, `artifacts/T2-red-mutant-*.log` (17), `artifacts/T2-mutant-no-scene-delegate-class-equivalent.log` |
| 2026-11-09 | Entry 6: details screen and navigation (T3), R-32…R-35, CI of `feat(T2)` | Reviewed the details screen and push code, the red and green logs and all twelve mutant logs; accepted R-32…R-35 and the back-button guard added after red. | `artifacts/T3-red.log`, `artifacts/T3-green.log`, `artifacts/T3-red-mutant-*.log` (12) |
| 2026-11-09 | Entry 7: subject filter (T4), R-36…R-37 | Reviewed the filter and subject-button code, the red and green logs and all eleven mutant logs; accepted R-36 and R-37 and pushed feat(T3) before the red commit. | `artifacts/T4-red.log`, `artifacts/T4-green.log`, `artifacts/T4-red-mutant-*.log` (11) |
| 2026-11-09 | Entry 8: accessibility/MVC audit and largest-text-size UI test (T5), R-38…R-41, CI of `feat(T3)` and `feat(T4)` | Reviewed the T5 UI test, the launchApp change, the audit table and both mutant logs; chose R-38…R-41 as recommended after the probes showed a silent false green. | `artifacts/T5-green.log`, `artifacts/T5-red-mutant-*.log` (2), `artifacts/T5-mutant-detail-no-scroll-bottom-default-size-survives.log` |
| 2026-11-09 | Entry 9: bonus plan R-42…R-49 and store mutation tests (T6.1), R-50…R-51 | Reviewed the bonus plan, the ten store tests, the assertThrows helper and all twelve mutant logs; accepted R-42…R-51 as recommended. | `artifacts/T6.1-green.log`, `artifacts/T6.1-red-mutant-*.log` (12) |
| 2026-11-09 | Entry 10: add form and add button (T6.2), R-52…R-56, CI of `test(T5)` | Reviewed the form and list code, the red and green logs and all sixteen mutant logs; accepted R-52…R-56 and the UI-test fallback for cancel. | `artifacts/T6.2-red.log`, `artifacts/T6.2-green.log`, `artifacts/T6.2-red-mutant-*.log` (16) |
| 2026-11-09 | Entry 11: edit and swipe-delete with confirmation (T6.3, includes T6.4), R-57…R-59, CI of `feat(T6.2)` |Reviewed the edit and delete code, the red and green logs and all eighteen mutant logs; chose R-57 and R-59 as recommended and R-58 against the recommendation.| `artifacts/T6.3-red.log`, `artifacts/T6.3-green.log`, `artifacts/T6.3-red-mutant-*.log` (18) |
| 2026-11-09 | Entry 12: final verification (T7), CI of `feat(T6.3)` | Reviewed the final exact-command log, the UI x5 log, the CI result of feat(T6.3) and the final checks. | `artifacts/final-xcodebuild-test.log`, `artifacts/T7-ui5.log` |

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

## Entry 5 — Student list and reusable cell (T2) (2026-11-08 – 2026-11-09)

### Tool/agent task

Build the list screen (UIKit, SnapKit, reusable cell, title `Students`,
`studentList` / `studentCell.<id>`, Dynamic Type, accessibility) test-first:
red with neutral placeholders, then the implementation, repeats (R-14,
R-26) and mutants. Verify the UIKit/XCUI facts the tests rely on first.

### Output reviewed

- Facts checked in scratchpad copies before use (`PLAN.md` facts 15-25):
  SVG avatars, locale formatting (the local simulator locale is `en_UA`), the
  text style attribute of fixed fonts, trait updates without a window
  (`updateTraitsIfNeeded()`), synchronous push, XCUI cell lookup.
- Template defect found while checking XCUI: `SceneDelegate` is never
  connected, the app shows no window (fact 22). Fixed in `StudentDirectoryApp`
  (R-25).
- Red (`test(T2)`): 11 unit + 2 UI tests fail on their rules against neutral
  placeholders; 8 older unit tests stay green.
- Implementation: `StudentFormatting` (R-21, R-9), `StudentCell` (SnapKit,
  `preferredFont` + `adjustsFontForContentSizeCategory`, one accessibility
  element, adaptive stack R-23, avatar fallback R-24),
  `StudentListViewController` (reads the shared store on every call, R-7),
  `SceneDelegate` as the composition root with one `StudentStore`.
- Repeats found a flaky UI test (4/5: blank screen, empty accessibility tree,
  no crash). The student chose R-27 (b), guard 10 s -> 20 s, instead of the
  agent's recommendation to probe further first.
- A mutant without `delegateClass` then survived on the main simulator. On a
  separate simulator (`APD Probe`, R-28) the agent showed that a scene session
  saved by a delegate-less build is restored on every launch and bypasses
  `configurationForConnecting`, so the R-25 fix alone leaves the app blank on
  such a device (fact 26); this also explains the flaky repetition most
  likely. R-29 (destroy such sessions) did not work and was never committed;
  R-30 (adopt a delegate-less scene on `UIScene.willConnectNotification`)
  works and is in this commit. R-31: the R-25 line is kept although it became
  an equivalent mutant.
- R-26 (student's choice A+B+C) cut a unit mutant from about 2 min to 19-27 s.
- Agent mistakes, all found by the agent itself:
  - read only the first failure of a test from the `.xcresult` summary and
    concluded wrongly that trait overrides apply on `layoutIfNeeded()`;
    fixed the log tool to read every failure (facts 20, 23);
  - expected that restored sessions lose the `delegateClass` (fact 24
    disproved it), and later expected R-29 to work (fact 27 disproved it);
  - overwrote the log of the survived `no-scene-delegate-class` run by
    re-running the mutant under the same name; the result is kept in the
    `PLAN.md` run log;
  - said in the T2 plan that the placeholder would be
    `StudentListViewController(store:subject:)`; the `subject` parameter was
    left for T4 so that no T4 rule enters T2 untested (told the student).

### Accepted/rejected/revised decision

Accepted R-21, R-22, R-24, R-25, R-26 (A+B+C), R-28, R-30 and R-31 as
recommended. Chose R-23 (b) adaptive cell layout and R-27 (b) 20 s UI guard
against the recommendations: large text stays readable, and the longer guard
costs nothing on green runs. R-29 (destroy old scene sessions) was tried and
rejected because it did not work; R-30 (give a restored scene without a
delegate a SceneDelegate) fixed the blank screen on a device with an old
session. R-26 cut one mutant run from about 2 min to under 30 s.

### Verification command/result

- Red: `-only-testing:StudentDirectoryTests -only-testing:StudentDirectoryUITests/StudentListUITests`
  -> 13 T2 tests fail on their rules, 8 pass.
- Final green: all unit tests `-test-iterations 20` -> 19 tests, each 20/20;
  all UI tests `-test-iterations 5` -> 4 tests, each 5/5; both
  `StudentListUITests` pass on `APD Probe` after a delegate-less launch.
- Mutants: 17 killed on their rule; `no-scene-delegate-class` equivalent
  after R-30.
- CI of `test(T1)` (run `42519361024`): success, Xcode 16.4, 10/10.
- Protected-file check vs `938bf69`: unchanged except the approved
  `StudentStore` deinit (R-19) and `StudentDirectoryApp` (R-25, R-30).

### Artifact links

- `artifacts/T2-red.log`, `artifacts/T2-green.log`
- `artifacts/T2-green-ui5-flaky-attempt.log` (failed attempt, R-27)
- `artifacts/T2-red-mutant-<name>.log` (17 mutants, table in `PLAN.md`)
- `artifacts/T2-mutant-no-scene-delegate-class-equivalent.log` (R-31)

---

## Entry 6 — Details screen and navigation (T3) (2026-11-09)

### Tool/agent task

Build the details screen (every field, `studentDetails`, Dynamic Type) and the
push from the list test-first, with R-26 run settings; check the CI result of
`feat(T2)`.

### Output reviewed

- Facts checked first in a scratchpad copy (`PLAN.md` facts 31-33): the root
  view identifier is an `otherElements` match in XCUI, the iOS 26 back button
  is `BackButton` labelled `Students`, a delegate call pushes at once.
- Decisions R-32…R-35 (all as recommended): subject buttons from T3, details
  texts, `Student not found` for a missing student, an extra Dynamic Type
  test. Agent conventions accepted: avatar label `Avatar of <name>`, no
  disclosure indicator, UI tests on Grace Hopper.
- Red (`test(T3)`): 7 tests fail on their rules against a neutral details
  controller and an empty `didSelectRow`; 19 older unit tests stay green.
- Implementation: `StudentDetailViewController` (scroll view + vertical
  stack with SnapKit, labels via `StudentFormatting`, subject buttons,
  not-found label), `didSelectRow` pushes the tapped student's details.
- Green with R-26: 24 unit tests 20/20 in 13 s, the 2 new UI tests 5/5.
- 12 mutants killed. The agent noticed that `hide-back-button` failed on an
  XCUI tap error instead of a rule message and added a `waitOrFail` on the
  back button to `testBackReturnsToStudentsList` after the red commit; the
  test and the mutant were run again (5/5; the mutant now fails on
  `Rule: the details screen has the standard back button`).
- CI of `feat(T2)` (run `42532789200`): success on Xcode 16.4, 23/23, so the
  R-25/R-30 scene code also works on CI (fact 34).

### Accepted/rejected/revised decision

Accepted R-32…R-35 as recommended: subject buttons from T3 so T4 only adds
the action, details texts consistent with the list cell, "Student not found"
for a missing student (needed later for delete), and an extra Dynamic Type
test. Accepted the agent's change after red: the back-button test now waits
for the button, so a missing button fails with a rule message. CI confirmed
that the T2 scene fixes also work on Xcode 16.4.

### Verification command/result

- Red: `-only-testing:StudentDirectoryTests -only-testing:StudentDirectoryUITests/StudentDetailUITests`
  -> 7 T3 tests fail on their rules, 19 pass.
- Green: all unit tests `-test-iterations 20` -> 24 tests, each 20/20;
  `StudentDetailUITests` `-test-iterations 5` -> 2 tests, each 5/5.
- Mutants: 12 killed, each on its target test's rule.
- Protected-file check vs `938bf69`: unchanged except the approved
  `StudentStore` deinit and `StudentDirectoryApp`.

### Artifact links

- `artifacts/T3-red.log`, `artifacts/T3-green.log`
- `artifacts/T3-red-mutant-<name>.log` (12 mutants, table in `PLAN.md`)

---

## Entry 7 — Subject filter (T4) (2026-11-09)

### Tool/agent task

Make every subject on the details screen a button identified as
`subjectButton.<subject>` that pushes a list of the students with exactly that
subject, in store order, titled with the subject (R-6), test-first.

### Output reviewed

- Facts checked first in a scratchpad copy (`PLAN.md` facts 35-36):
  `sendActions(for:)` runs a `UIAction` without a window; cells of the
  previous screen leave the XCUI tree after a push, so "02 is absent" is a
  valid UI check.
- Decisions: R-36 (custom out-of-order data for the order test, because seed
  Physics would not catch a sorting bug, as found in T1) and R-37 (`UIAction`
  closures), both as recommended; the agent's T4 conventions accepted.
- Red (`test(T4)`): 7 tests fail on their rules with `subject` stored but
  unused and buttons without identifier or action; 24 older unit tests stay
  green. Before this commit the agent told the student to push `feat(T3)`
  first, so that CI would not run on the red commit.
- Implementation: `StudentListViewController(store:subject:)` reads
  `store.students(matchingSubject:)` and uses the subject as title; subject
  buttons get the identifier and a `UIAction` that pushes the filtered list.
- Green with R-26: 29 unit tests 20/20, the 2 new UI tests 5/5; 11 mutants
  killed, including the typical bug "a filtered row opens the student of the
  full list" in both a unit and a UI variant.
- CI of `feat(T3)` (run `42536402652`) was still running when this entry was
  written; its result goes into the next entry (R-11).

### Accepted/rejected/revised decision

Accepted R-36 (custom out-of-order data, the same lesson as R-20 in T1:
seed Physics would hide a sorting bug) and R-37 (UIAction closures) as
recommended, and the agent's T4 conventions. Followed the advice to push
feat(T3) before committing the red T4 tests, so CI never ran on a red
commit. The typical bug "a filtered row opens a student of the full list"
is caught by both a unit and a UI test.

### Verification command/result

- Red: `-only-testing:StudentDirectoryTests -only-testing:StudentDirectoryUITests/SubjectFilterUITests`
  -> 7 T4 tests fail on their rules, 24 pass.
- Green: all unit tests `-test-iterations 20` -> 29 tests, each 20/20;
  `SubjectFilterUITests` `-test-iterations 5` -> 2 tests, each 5/5.
- Mutants: 11 killed, each on its target test's rule.
- Protected-file check vs `938bf69`: unchanged except the approved
  `StudentStore` deinit and `StudentDirectoryApp`.

### Artifact links

- `artifacts/T4-red.log`, `artifacts/T4-green.log`
- `artifacts/T4-red-mutant-<name>.log` (11 mutants, table in `PLAN.md`)

---

## Entry 8 — Accessibility/MVC audit and largest text size (T5) (2026-11-09)

### Tool/agent task

Audit the rubric's architecture and accessibility items on the code (one
shared store, no duplicated arrays, MVC, SnapKit, no `!`, identifiers, labels,
Dynamic Type) and check the one item not yet tested end to end: the real app
at the largest Dynamic Type size (R-38).

### Output reviewed

- CI of the previous code commits (R-11): `feat(T3)` run `42536402652`
  success, 30/30 tests; `feat(T4)` run `42537854911` success, 37/37 tests
  (Xcode 16.4). The agent's working notes said "31/31" for `feat(T3)`; the
  agent found the wrong count while writing this entry by counting the passed
  tests in the CI log (agent mistake; it did not reach the repository).
- Facts checked first in a scratchpad copy (`PLAN.md` facts 37-40): only the
  raw value `UICTContentSizeCategoryAccessibilityXXXL` sets the text size, the
  Swift constant name is ignored silently (row 111 pt instead of 344 pt);
  `tap()` scrolls to the off-screen `Design` button; a failed tap marks the
  surrounding activity as failed.
- The probes showed two risks that became decisions: a silent false green
  (R-40: compare with a default-size launch) and an XCUI failure message
  without the rule (R-41: a `Rule:` activity; the agent's log script prints it
  as `failure-activity:`).
- R-39: the agent's preview said "on iPhone the app has one scene" from
  memory. The audit found that the project allows multiple scenes and targets
  iPad too; a probe then confirmed that iPhone refuses a second scene
  (fact 40). The iPad case (two windows, two stores) is recorded as a risk,
  not tested.
- New test `AccessibilityUITests.testLargestTextSizeKeepsListDetailsAndFilterUsable`;
  `launchApp` got a defaulted `arguments` parameter. No app code changed, so
  the test was green at once (R-5); proof by two mutants that only break at
  the largest size. The claim "the T3/T4 UI tests do not catch
  `detail-no-scroll-bottom`" was checked by a run, not assumed.
- The student found in the Markdown preview that the index table above did
  not render: its separator row had lost the third cell's `---` (`-` since
  `test(T1)`, empty since `feat(T4)`). Restored to the template's
  `| --- | --- | --- | --- |`. The agent's per-task checks compared protected
  files and paths, not the Markdown, so they missed it.
- Audit claims (no `NSLayoutConstraint`, no `!`/`try!`/`as!`, one
  `StudentStore()`, no store in the cell) were checked with `grep` on the
  current code.

### Accepted/rejected/revised decision

Accepted R-38…R-41 as recommended. The probe changed the plan: a misspelled text-size argument is ignored without an error, so I chose R-40 (compare with a default-size launch) to rule out a false green, and R-41 so that a failed scroll still names its rule. Accepted R-39 knowing that the iPad two-window case is not tested.

### Verification command/result

- Green: `-only-testing:StudentDirectoryUITests/AccessibilityUITests
  -test-iterations 5` -> 5/5 (83 s); all UI tests once -> 9/9 (76 s).
- Mutants: `detail-no-scroll-bottom` and `fixed-row-height` killed, each with
  its rule (`failure-activity:` or the assertion message).
- `detail-no-scroll-bottom` against `StudentDetailUITests` and
  `SubjectFilterUITests` -> 4/4 passed, so only T5 catches it.
- Protected-file check vs `938bf69`: unchanged except the approved
  `StudentStore` deinit and `StudentDirectoryApp`.

### Artifact links

- `artifacts/T5-green.log`
- `artifacts/T5-red-mutant-detail-no-scroll-bottom.log`,
  `artifacts/T5-red-mutant-fixed-row-height.log`
- `artifacts/T5-mutant-detail-no-scroll-bottom-default-size-survives.log`

---

## Entry 9 — Bonus plan and store mutation tests (T6.1) (2026-11-09)

### Tool/agent task

Plan the optional bonus (add/edit/delete) and, as its first part, prove the
supplied `addStudent`, `updateStudent` and `deleteStudent` with
characterization tests (as T1), including "invalid input and unknown ids do
not mutate state".

### Output reviewed

- The bonus store API is already implemented in the supplied (protected)
  `StudentStore`, so the bonus is UI plus tests. The agent proposed splitting
  it into T6.1-T6.4 (R-42) and the UI decisions R-43…R-49 (own form view
  controller, button placement, form identifiers, refresh through
  `viewWillAppear` and an `onSave` closure, non-numeric age, names as typed,
  swipe-delete also on the filtered list); all accepted as recommended.
- New questions for T6.1: R-50 (how to test "a new UUID" without relying on
  random values) and R-51 (no test for the order of two errors); both as
  recommended. R-50 rests on fact 41, probed on macOS and in the simulator.
- Ten tests in `StoreMutationTests` plus the exact-error helper
  `assertThrows(_:error:rule:)` deferred from T1; green at once, 20/20.
- Twelve mutants. Lines that occur twice in the store (`try validate(…)`,
  `throw StudentStoreError.unknownID(id)`) are mutated by explicit
  occurrence, so `add` and `update` (and `update` and `delete`) are proven
  separately. The agent's first batch built the `add-reuse-id` line with a
  zsh substitution that treated `()` as a glob group, so that mutant did not
  compile and proved nothing; the agent found it from the empty result
  (0 tests) and re-ran it with the line written out (agent mistake).

### Accepted/rejected/revised decision

Accepted R-42…R-51 as recommended. Split the bonus into four parts so that each point is committed on its own. For R-50 I accepted comparing the new id with the fixed test ids because the probe showed UUID() is always version 4. The add-reuse-id mutant first failed to compile because of the agent’s script; I checked that the re-run fails on the rule.

### Verification command/result

- UUID probe: version 4 in 100 000 of 100 000 (macOS script and iPhone 17
  test host).
- Green: all unit tests `-test-iterations 20` -> 39 tests, each 20/20, no
  compiler warnings.
- Mutants: 12 killed, each on its target test's rule (one after the re-run
  described above).
- Protected-file check vs `938bf69`: unchanged except the approved
  `StudentStore` deinit and `StudentDirectoryApp`.
- CI of `test(T5)` (run `42541717925`) was still running when this entry was
  written; its result goes into the next entry (R-11).

### Artifact links

- `artifacts/T6.1-green.log`
- `artifacts/T6.1-red-mutant-<name>.log` (12 mutants, table in `PLAN.md`)

---

## Entry 10 — Add form and add button (T6.2) (2026-11-09)

### Tool/agent task

Add a student through a two-field form opened from `addStudentButton` on the
main list; reject blank names, non-positive and non-numeric ages without
changing the store; refresh the list after a save (bonus points 1 and part of
4), test-first.

### Output reviewed

- CI of `test(T5)` (run `42541717925`): success, 38/38 tests (Xcode 16.4),
  including the largest-text-size UI test.
- Decisions R-52…R-56 accepted as recommended. The student asked to reach the
  end faster without losing quality; the agent kept every check and saved
  time by writing the implementation in a scratchpad copy while the student
  made the red commit, and by running the green runs and all mutants in one
  background chain.
- Probes (`PLAN.md` facts 42-45): a form presented from a list in a window
  appears at once, but its dismissal is not visible synchronously even
  without animation. So "the form closes" is checked only by UI tests, and
  cancel got the third UI test, the agreed fallback of R-56.
- Red (`test(T6.2)`): 11 tests fail on their rules with a neutral stub. Two
  new tests pass on the stub because doing nothing is correct for them
  (cancel never saves; a filtered list has no button); both are proven by
  mutants (`cancel-saves`, `add-button-everywhere`).
- Implementation: `StudentFormViewController` (SnapKit stack, text-style
  fonts, R-45 identifiers, `Int(text)` without `!`, store errors mapped to the
  agreed messages); the list's add button only without a subject, `onSave`
  reloads and scrolls to the new last row.
- The agent first added a VoiceOver announcement of the error message, then
  removed it before the tests ran because it was not agreed and no test
  checks it.
- The red commit was kept local until the green commit, so CI never runs on
  a red commit (`test(T6.1)` waits with it).

### Accepted/rejected/revised decision

Accepted R-52…R-56 as recommended. The probe showed that a unit test cannot see the form close, so I accepted the agreed fallback of R-56: a third UI test for cancel. Asked the agent to speed up without losing quality; it overlapped the implementation with my red commit instead of dropping checks.

### Verification command/result

- Red: `-only-testing:StudentDirectoryTests -only-testing:StudentDirectoryUITests/AddStudentUITests`
  -> 11 T6.2 tests fail on their rules, 41 pass.
- Green: all unit tests `-test-iterations 20` -> 49 tests, each 20/20;
  `AddStudentUITests` `-test-iterations 5` -> 3 tests, each 5/5.
- Mutants: 16 killed (13 unit, 3 UI), each on its target test's rule.
- Protected-file check vs `938bf69`: unchanged except the approved
  `StudentStore` deinit and `StudentDirectoryApp`.

### Artifact links

- `artifacts/T6.2-red.log`, `artifacts/T6.2-green.log`
- `artifacts/T6.2-red-mutant-<name>.log` (16 mutants, table in `PLAN.md`)

---

## Entry 11 — Edit and swipe-delete (T6.3, includes T6.4) (2026-11-09)

### Tool/agent task

Edit a student's name and age from `editStudentButton` on the details screen
with the add form's validation, and delete a student by swipe from any list
with a confirmation alert; refresh the details and lists after every change
(bonus points 2, 3 and the rest of 4), test-first.

### Output reviewed

- CI of `feat(T6.2)` (run `42544689820`, pushed together with `test(T6.1)`
  and `test(T6.2)`): success, 61/61 tests (Xcode 16.4).
- Decisions: R-57 (one cycle for edit and delete, to save time) and R-59 as
  recommended; R-58 (confirmation alert) against the recommendation. The
  agent stated the risk once (alert handlers are not reachable from unit
  tests) and split the tests so that none depends on it: unit tests check the
  alert and the delete method, two UI tests check the confirmed and the
  cancelled path (`PLAN.md` Risks).
- To save time the agent wrote the tests and the implementation together in a
  scratchpad copy and ran them green first; this also checked the XCUI
  behaviour the UI tests rely on (fact 46). Only then the tests went into the
  repository with neutral stubs for the red run.
- Red (`test(T6.3)`): 13 tests fail on their rules. In the first red run one
  `XCTUnwrap` had no rule message; the agent's first fix used a wrong text
  pattern and did not apply, so one run was wasted before the fix (agent
  mistake, found by the agent).
- Implementation: the form gets an `editing` id (title `Edit Student`, fields
  filled, `updateStudent`); the details screen rebuilds itself from the store
  after a save and has no edit button on `Student not found`; lists reload in
  `viewWillAppear` (R-46), offer a destructive `Delete` swipe action that
  presents `Delete <name>?`, and only the alert's `Delete` deletes from the
  shared store (also from a filtered list, R-49).
- While writing this entry the agent found that R-52…R-56 (T6.2) had been
  used in tests, commits and Entry 10 but were missing from the `PLAN.md`
  decisions table (agent mistake); the rows were added.

### Accepted/rejected/revised decision

Chose R-58 (a confirmation alert) against the recommendation: deleting a student cannot be undone, so I want a second, explicit step. I accept the risk that the alert’s buttons are proven only by UI tests; the unit tests check the alert and the delete method separately. Accepted R-57 to finish faster with the same tests and mutants.

### Verification command/result

- Red: `-only-testing:StudentDirectoryTests -only-testing:StudentDirectoryUITests/EditStudentUITests -only-testing:StudentDirectoryUITests/DeleteStudentUITests`
  -> 13 tests fail on their rules, 50 pass.
- Green: all unit tests `-test-iterations 20` -> 60 tests, each 20/20; the
  3 new UI tests `-test-iterations 5` -> each 5/5.
- Mutants: 18 killed (14 unit, 4 UI), each on its target test's rule.
- Protected-file check vs `938bf69`: unchanged except the approved
  `StudentStore` deinit and `StudentDirectoryApp`.

### Artifact links

- `artifacts/T6.3-red.log`, `artifacts/T6.3-green.log`
- `artifacts/T6.3-red-mutant-<name>.log` (18 mutants, table in `PLAN.md`)

---

## Entry 12 — Final verification (T7) (2026-11-09)

### Tool/agent task

Run the exact README command on the last code commit, repeat every UI test,
re-check the protected files and the repository rules, and prepare the
submission (`SUBMISSION.md`).

### Output reviewed

- CI of `feat(T6.3)` (run `42585094949`, the last code commit `46e091b`):
  success, 75/75 tests on Xcode 16.4 (`gh run view --log` left out the test
  step; the count comes from the job log through the GitHub API).
- Exact command on `46e091b`: `TEST SUCCEEDED`, 75/75 (60 unit: 58 student +
  2 starter; 15 UI: 13 student + 2 starter), iPhone 17, iOS 26.3.1.
- All 15 UI tests `-test-iterations 5`: each 5/5.
- Checks: template `HEAD` still `938bf69` (R-15/R-16); repository public;
  protected files unchanged except the approved R-19 deinit and R-25/R-30 app
  delegate lines; no `fatalError`, `try!` or `as!` in app code; no duplicated
  test names; no tracked build output, secrets or personal paths.
- The agent first wrote 72 tests / 12 UI tests into the expectation lines of
  the two final logs (it had counted 10 student UI tests instead of 13); it
  found the error with the static test count and regenerated both headers
  from the same runs before the commit (agent mistake).
- Only this documentation commit follows `46e091b`; the code is unchanged, so
  the logs describe the submitted code. After the push the agent checks a
  clean anonymous clone of the final SHA with the exact command and reports
  the result and the CI run of the final commit in chat (R-11: recording them
  here would change the SHA).

### Accepted/rejected/revised decision

Accepted the final verification as planned. The agent miscounted the UI tests in two log headers; I checked that the regenerated headers match the runs (75 tests, 15 UI).

### Verification command/result

- `xcodebuild -project StudentDirectory.xcodeproj -scheme StudentDirectory -destination 'platform=iOS Simulator,name=iPhone 17' test`
  -> `TEST SUCCEEDED`, 75/75 (225 s).
- `-only-testing:StudentDirectoryUITests -test-iterations 5` -> 15 tests,
  each 5/5 (719 s).
- Protected-file check vs `938bf69`: unchanged except the approved
  `StudentStore` deinit and `StudentDirectoryApp`.

### Artifact links

- `artifacts/final-xcodebuild-test.log`
- `artifacts/T7-ui5.log`

---

## Final review

- Agent/tool disclosure: Claude Code (Claude Opus 5.5) in the desktop app planned, proposed every non-obvious decision with options, wrote code, tests, logs and these documents. I made every decision (R-1…R-59), reviewed each diff and ran every git add, commit and push myself.
- Accepted and rejected/revised recommendations: I chose against the recommendation four times: R-15 (no upstream remote), R-23 (adaptive cell layout), R-27 (longer UI guard instead of a relaunch probe) and R-58 (confirmation alert before deleting). I revised R-14 (repeated green runs), R-19 (simpler deinit workaround), R-20/R-36 (custom out-of-order test data) and asked for R-26/R-57 to save time without dropping checks.
- Exact local test command and result: xcodebuild -project StudentDirectory.xcodeproj -scheme StudentDirectory -destination ‘platform=iOS Simulator,name=iPhone 17’ test → TEST SUCCEEDED, 75/75 on 46e091b (artifacts/final-xcodebuild-test.log); all 15 UI tests 5/5 (artifacts/T7-ui5.log).
- CI URL/status: https://github.com/ArseniiKlimenko/apd-hw-3-Klimenko/actions/runs/42585094949 - success, 75/75 on Xcode 16.4 for the last code commit 46e091b.
- Known limitation or remaining risk: the template needed two app-level workarounds (R-19 deinit, R-25/R-30 scene delegate) that I reported to the instructor; on iPad two windows would get two separate stores (R-39, not tested); the alert’s Delete and Cancel buttons are proven only by UI tests (R-58).
- Comment: Testing is very long process!!!