# HW3 Student Plan

## Scope

In scope:

- Three UIKit flows on one shared `StudentStore`: student list, student
  details, subject-filtered list (base, 12 points).
- SnapKit layouts, required accessibility identifiers, meaningful
  accessibility labels, Dynamic Type, no force-unwrapped user input.
- Student-authored unit tests (`StudentDirectoryTests`) and UI tests
  (`StudentDirectoryUITests`).
- Optional add/edit/delete bonus (R-2), only after the base is green and
  committed.

Non-goals:

- MVVM, coordinators (HW4), SwiftLint.
- Persistence, networking, random or time-dependent data.
- Changing the supplied model, seed data, assets, starter tests, project file,
  build settings, CI workflow or assignment documents.
- Fixing the Swift runtime/toolchain problem found in T0 beyond a minimal,
  documented workaround (R-17).

## Approach

MVC boundary:

| Layer | Types | Responsibility |
| --- | --- | --- |
| Model | `Student`, `StudentStore` (supplied) | data, subject filter, bonus validation |
| View | `StudentCell` | show what it is given; no store access |
| Controller | `StudentListViewController`, `StudentDetailViewController` | read from the store, configure views, react to taps, navigate |

- One shared store: `SceneDelegate` is the composition root. It creates the
  only `StudentStore()` and injects it into every controller. No controller
  creates a store.
- No duplicated authoritative arrays (R-7): the list reads
  `store.students` or `store.students(matchingSubject:)` on every data-source
  call; details keep only the student `id` and look the student up in the
  store.
- Subject filter (R-6): the filtered screen is the same
  `StudentListViewController` with `subject: String?`; the rows come only from
  `store.students(matchingSubject:)` (exact, case-sensitive, store order); the
  title is the subject.
- Identifiers: `studentList` (table, also on the filtered list),
  `studentCell.<student.id.uuidString>`, `studentDetails` (details root view),
  `subjectButton.<subject>`.
- Accessibility (R-10): each cell is one accessibility element with a combined
  label (name, age, grade, scholarship status); scholarship is always text,
  never only colour; the avatar has a label.
- Dynamic Type: `preferredFont(forTextStyle:)`,
  `adjustsFontForContentSizeCategory = true`, `numberOfLines = 0`,
  self-sizing cells, details in a scroll view.
- Details (R-8) show all seven fields: avatar image plus ID, name, age, grade,
  scholarship, subjects (buttons), avatar asset name.
- Grade text (R-9) comes from one locale-aware formatting function with a
  `locale` parameter; unit tests pass `en_US_POSIX`, UI tests do not assert
  grade text.
- Missing avatar asset falls back to `avatar-default` without `!`.

Testing approach (R-3): exact rules (counts, order, case, texts, identifiers,
navigation stack) in unit tests with `@testable import StudentDirectory`;
end-to-end flows in XCUITest. UI tests wait for a screen-unique element with
`waitForExistence(timeout: 10)` as a guard only, then `XCTFail` + `throw`
(R-4); no sleeps, polling or timing assertions. One file and one
`XCTestCase` subclass per task; shared helpers in `TestSupport.swift` /
`UITestSupport.swift`.

## Decisions

| R | Question | Decision | Reason |
| --- | --- | --- | --- |
| R-1 | Fork name | `ArseniiKlimenko/apd-hw-3-Klimenko` | consistent with HW2 |
| R-2 | Bonus | do it after the base (T6) | base stays safe and committed first |
| R-3 | Test layers | hybrid: unit tests for rules, XCUITest for flows | each rule is checked where it is most visible |
| R-4 | Waiting in UI tests | `waitForExistence(timeout:)` only as a guard, then `XCTFail` + `throw` | assignment forbids sleeps/polling/timing thresholds |
| R-5 | T1 cannot be red (store already implemented) | characterization tests, green run, mutants as proof, one `test(T1)` commit | no artificial edits of supplied code |
| R-6 | Filtered list | reuse `StudentListViewController` with `subject: String?`, same `studentList` identifier | one code path; UI tests wait for the title before checking cells |
| R-7 | Data source in controllers | read from the store on every access; details hold `id` + store | no second source of truth; correct after bonus mutations |
| R-8 | Detail fields | all seven fields, including ID and avatar asset name | "every student field" literally |
| R-9 | Grade format | locale-aware, one function with `locale` parameter | correct for any locale; tests pin `en_US_POSIX` |
| R-10 | Cell accessibility | one element with a combined label | one VoiceOver stop per student |
| R-11 | CI evidence | worklog records the CI run of the last code commit; CI of the final docs commit is checked after push and reported in chat | recording CI would change the SHA |
| R-12 | Worklog format | template table as index + "Entry N" sections + template "Final review" bullets | template requirements plus the student's format |
| R-13 | Artifact logs | filtered excerpt + `.xcresult` summary, sanitized; raw logs stay outside the repo | readable, no absolute paths |
| R-14 | Repeats of green runs | revised: first "no repeats", then unit tests 20x and UI tests 5x (`-test-iterations`) | student reconsidered the flaky-test risk |
| R-15 | `upstream` remote | none (student's choice; agent recommended keeping it read-only) | see Risks: template updates are checked with `git ls-remote` |
| R-16 | Template reference SHA | `938bf69c34131616d693a67c3706d8dd41543388` | deterministic protected-file checks |
| R-17 | Starter test crashes locally (T0) | (a) minimal workaround in `StudentStore` in a separate `fix(T0)` commit + (d) student informs the instructor | reliable local red/green cycle without leaking stores in tests |
| R-18 | Push cadence | student pushes after each task | local Xcode 26.3 and CI Xcode 16.4 differ; catch CI problems early |
| R-19 | Form of the R-17 workaround (revises the first form) | plain `deinit {}` with a comment, no `#if` | the first form `#if compiler(>=6.2) nonisolated deinit {} #endif` compiles to the same code (fact 12); `deinit {}` is valid for every Swift version, so it does not rely on the unverified behaviour of `#if compiler` on Xcode 16.4 |
| R-20 | Test data for "filter keeps store order" (revises the planned Physics data) | a custom store with ids and names deliberately out of order (`Zed`(3), `Amy`(1), `Mia`(2)) | in the seed every subject list is already in id order and Physics is also in name order, so seed data cannot catch a sorting bug (checked with a script) |

Agent-proposed conventions accepted by the student: task order T0-T7; app
files `StudentListViewController.swift`, `StudentCell.swift`,
`StudentDetailViewController.swift`, `StudentFormatting.swift`; test files and
classes listed under Acceptance criteria; `@MainActor` test classes; log names
`T<n>-red.log`, `T<n>-green.log`, `T<n>-red-mutant-<name>.log`,
`T0-baseline.log`, `final-xcodebuild-test.log`; commits
`test(Tn)` / `feat(Tn)` / `docs(Tn)` (plus `fix(T0)` from R-17) on `main`;
clone at `<workspace>/apd-hw-3-Klimenko`.

## Milestones

- [x] T0: fork, plan, worklog, baseline run (crash found, R-17)
- [x] T0 fix: R-17/R-19 workaround, green run, mutants
- [x] T1: store characterization tests (unit), 7 mutants
- [ ] Student list and reusable cell (T2)
- [ ] Detail screen and navigation (T3)
- [ ] Subject-filtered list (T4)
- [ ] Unit and UI tests (T1-T5, per task)
- [ ] Optional add/edit/delete bonus, if attempted (T6)
- [ ] Local verification and CI review (each task, final in T7)
- [ ] Final diff and evidence review (T7)

## Acceptance criteria

Test names for T1-T4 are the agreed plan; they are fixed before each task and
not renamed afterwards. Unit tests live in `StudentDirectoryTests/`, UI tests
in `StudentDirectoryUITests/`.

- T0: `artifacts/T0-baseline.log` records the exact command on the untouched
  template (actual: `TEST FAILED`, R-17).
- T0 fix (R-17/R-19): with `deinit {}` in `StudentStore` the exact command
  passes 4/4, unit tests 20/20 and UI tests 5/5 (`artifacts/T0-green.log`).
  Proof by the starter test `testStarterStoreIsConstructible`:
  - mutant `remove-deinit` (one line: delete `deinit {}`, comment kept) ->
    crash, `Test crashed with signal abrt`
    (`artifacts/T0-red-mutant-remove-deinit.log`);
  - failed attempt kept as evidence: mutant `plain-deinit` against the first
    form (drop `nonisolated`) survived because it is equivalent (fact 12)
    (`artifacts/T0-mutant-plain-deinit-survived.log`).
- T1 `StudentStoreTests` (unit, `StudentDirectoryTests/StudentStoreTests.swift`,
  helper `makeStudent(id:name:subjects:)` in `TestSupport.swift`). Green at once
  (R-5): 8/8 unit tests, each 20/20, exact command 10/10
  (`artifacts/T1-green.log`). Every mutant changes one line of
  `StudentStore.swift` and fails its target test with that test's rule message
  (`artifacts/T1-red-mutant-<name>.log`):

  | Test | Mutant |
  | --- | --- |
  | `testSeedStoreKeepsSeedStudentsInOrder` | `seed-reversed` (default argument `StudentSeedData.students.reversed()`) |
  | `testStoreUsesInjectedStudents` | `ignore-injected` (`self.students = StudentSeedData.students`) |
  | `testSubjectFilterKeepsStoreOrder` | `sort-by-name` (`.sorted { $0.name < $1.name }`), R-20 data |
  | `testSubjectFilterIsCaseSensitive` | `case-insensitive` (`caseInsensitiveCompare`) |
  | `testSubjectFilterRequiresExactMatch` | `substring` (`$0.contains(subject)`, fails on `"Phys"`), `trim` (trimmed query, fails on `"Physics "`) |
  | `testSubjectFilterWithUnknownSubjectIsEmpty` | `all-on-no-match` (no match returns all students) |
- T2 `StudentListTests` (unit): `testListTitleIsStudents`,
  `testListHasOneRowPerStoreStudent`, `testListRowsFollowStoreOrder`,
  `testListTableHasStudentListIdentifier`,
  `testCellShowsNameAgeGradeAndScholarship`,
  `testReusedCellResetsScholarshipState`,
  `testCellAccessibilityLabelSummarizesStudent`,
  `testCellTextSupportsDynamicType`, `testGradeFormattingFollowsLocale`,
  `testListReflectsStoreChangesAfterReload`.
  `StudentListUITests` (UI): `testLaunchShowsStudentsList`,
  `testSeedStudentCellIsFoundByIdentifier`.
- T3 `StudentDetailTests` (unit):
  `testSelectingRowPushesDetailsOfThatStudent`,
  `testDetailsShowEveryStudentField`,
  `testDetailsViewHasStudentDetailsIdentifier`,
  `testDetailsForMissingStudentShowNoStudentData` (agent-proposed rule, a
  consequence of R-7, not an assignment requirement).
  `StudentDetailUITests` (UI): `testTappingStudentOpensDetails`,
  `testBackReturnsToStudentsList`.
- T4 `SubjectFilterTests` (unit): `testDetailsHaveButtonForEachSubject`,
  `testTappingSubjectPushesListTitledWithSubject`,
  `testFilteredListShowsExactMatchesInStoreOrder`,
  `testFilteredListIsCaseSensitive`,
  `testFilteredRowOpensDetailsOfFilteredStudent`.
  `SubjectFilterUITests` (UI): `testSubjectButtonOpensFilteredList`,
  `testFilteredListRowOpensCorrectDetails`.
- T5 (accessibility/MVC audit) and T6 (bonus): tests agreed before each task.
- T7: exact command green in `artifacts/final-xcodebuild-test.log`, CI green,
  clean anonymous clone green at the submitted SHA.

## Risks and checks

| Risk | Check / mitigation |
| --- | --- |
| Local toolchain (Xcode 26.3, Swift 6.2.4) differs from CI (Xcode 16.4, Swift 6.1); code may compile differently | push after each task (R-18) and read the CI result |
| Implicit deinit of a plain (non-UIKit) app class is MainActor-isolated under Xcode 26 and crashes when released inside XCTest (T0) | R-17 workaround for `StudentStore`; any new plain app class released in tests is raised as a decision before it is added |
| R-15: without `upstream`, template fixes by the instructor are not visible automatically | `git ls-remote https://github.com/Mat-CauThon/apd-hw-3.git HEAD` compared with R-16 in T0 (unchanged) and T7 |
| Off-screen cells are not in the XCUI hierarchy | row counts are unit-tested; UI tests use short lists (`Design`, `Physics`: 4 rows) |
| Two `studentList` tables during a push transition (R-6) | UI tests first wait for a screen-unique element (navigation bar title, `studentDetails`) |
| Grade text depends on locale (R-9) | unit tests pass `en_US_POSIX`; UI tests do not assert grade text |
| Xcode deletes older `.xcresult` bundles; console output may drop `Test case` lines under `-test-iterations` | logs are generated right after each run; repetition counts are taken from `.xcresult`; focused runs use `-resultBundlePath` in the scratchpad |
| Protected files or `StudentStore` declarations change by accident | scratchpad script compares with R-16 after every task (git diff of protected paths + declaration lines) |
| The Xcode GUI rewrites asset catalog `Contents.json` files (seen in T0: 11 avatar files changed and staged while Xcode was open) | protected-file check right before every `git add`; avoid opening `Assets.xcassets` in Xcode; restore with `git restore --staged --worktree StudentDirectory/Assets.xcassets` |
| Personal data / absolute paths in artifacts | logs are sanitized (`<repo>`, `<home>`, `<scratch>`, `<mutant:name>`); grep before every commit |
| Simulator app crashes during mutant runs open macOS crash dialogs | harmless; dismiss with OK / Ignore |
| The empty `deinit {}` in `StudentStore` looks like dead code and may be deleted later | explaining comment in the code; the starter test crashes without it (mutant `remove-deinit`) |
| `deinit {}` not yet built by CI (Xcode 16.4) | resolved: CI run `42516097673` (attempt 2) built `339d150` with Xcode 16.4 and passed 4/4 (fact 14) |
| The CI runner sometimes finds no iOS simulator (`Unable to find a device matching the provided destination specifier`, attempt 1 of `42516097673`) | the student re-runs the job; a repeated failure is raised as a decision (the workflow is protected) |
| Seed data hides ordering bugs (every subject list is in id order; Physics also in name order) | order tests use custom out-of-order data (R-20); the T4 order test is raised again before T4 |

## Verified language facts

Checked locally with throwaway projects/scripts in the scratchpad (never
committed). Environment: Xcode 26.3 (17C529), Swift 6.2.4, iPhone 17
simulator iOS 26.3.1, project settings `SWIFT_VERSION = 5.0`,
`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` (app target only).

1. The `StudentDirectory` scheme is auto-generated (`xcodebuild -list`) and
   the exact command runs both test targets (baseline: 2 unit + 2 UI tests).
2. A new `.swift` file in a synchronized folder is compiled into its target
   without editing `project.pbxproj` (probe file used from a test).
3. Releasing an instance of a plain app class inside the XCTest-hosted app
   process crashes with `SIGABRT` (`swift_task_deinitOnExecutorImpl` ->
   `TaskLocal::StopLookupScope` -> "pointer being freed was not allocated"):
   an empty class, a class with an array, `StudentStore`, also when released
   on a later main-queue turn. Deterministic in every run.
4. `@MainActor` on the test class does not prevent that crash. Test classes
   calling app types compile without warnings with and without `@MainActor`.
5. The deployment target is not the cause: with
   `IPHONEOS_DEPLOYMENT_TARGET=26.0` (command-line override) the crash
   persists; only the back-deploy shim disappears from the stack.
6. A `UIViewController` subclass released in a unit test did not crash
   (not verified that its deinit ran inside the test).
7. The app process creating and releasing a store during launch did not crash
   (starter UI launch test passed, no crash report; deinit execution not
   separately proven).
8. The template CI run (`40850987361`) used Xcode 16.4 (Swift 6.1, iOS 18.5
   SDK) with an iPhone 17 iOS 26.2 simulator and passed all 4 tests.
   Not verified (inference only): Xcode 16.4 ignores
   `SWIFT_DEFAULT_ACTOR_ISOLATION`.
9. `UUID.uuidString` is uppercase; lowercase input is normalized.
10. `xcodebuild` supports `-only-testing`, `-test-iterations`,
    `-clonedSourcePackagesDirPath`, `-resultBundlePath` (`xcodebuild -help`).
11. The template `.xcresult` from the baseline run was deleted by Xcode after
    later runs (only the three newest bundles remained).
12. An explicit deinit is not isolated, with or without `nonisolated`.
    Disassembly of `StudentStore.__deallocating_deinit` (`xcrun objdump`):
    the template (implicit deinit) has an isolated part (`fZ`) and calls into
    the runtime (`deinitOnExecutor`); with `deinit {}` and with
    `nonisolated deinit {}` there is no `fZ` and the deinit is called
    directly. Neither crashes; removing the explicit deinit brings the crash
    back.
13. `-test-iterations N` repeats every selected test N times (`.xcresult`
    shows N repetitions per test). The console output can print fewer
    `Test case` lines than repetitions (19 of 20 seen), so counts are taken
    from `.xcresult`.
14. CI (Xcode 16.4, macOS 15 arm64 image `20261104.0514.1`, iPhone 17
    iOS 26.2 simulator) builds the explicit `deinit {}` and passes all 4
    starter tests (run `42516097673`, attempt 2). Attempt 1 on the same image
    failed before building because no simulator was available; other forks
    of the template were green on the same image the same day, so the agent's
    first explanation ("the new image has no simulators") was wrong.

Not yet verified (checked before first use): synchronous update of
`viewControllers` after `pushViewController` without a window; XCUI finding a
cell by identifier with a combined label; SVG avatars via `UIImage(named:)`;
which cells exist in the XCUI hierarchy on iPhone 17.

## Verification plan

- Focused runs while a task is in progress:
  `xcodebuild -project StudentDirectory.xcodeproj -scheme StudentDirectory -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:<Target>/<Class>`.
- Each green run is repeated (R-14): unit tests `-test-iterations 20`, UI
  tests `-test-iterations 5`; counts are read from `.xcresult`.
- Mutants run in a scratchpad copy with their own `-derivedDataPath`; logs as
  `artifacts/T<n>-red-mutant-<name>.log` with the mutant diff.
- After each task: protected-file check (R-16), personal-data grep, CI run
  after the student's push (R-18).
- Final command, exactly as in the README:
  `xcodebuild -project StudentDirectory.xcodeproj -scheme StudentDirectory -destination 'platform=iOS Simulator,name=iPhone 17' test`
  -> `artifacts/final-xcodebuild-test.log`.

## Run log

| Date | Command | Result | Follow-up |
| --- | --- | --- | --- |
| 2026-11-08 | `git ls-remote https://github.com/Mat-CauThon/apd-hw-3.git HEAD` | `938bf69…` = R-16 | none |
| 2026-11-08 | exact command on the untouched template | `TEST FAILED` (exit 65): `testStarterStoreIsConstructible` crashed, 3 others passed (`artifacts/T0-baseline.log`) | crash diagnosis |
| 2026-11-08 | probe copy, `-only-testing:StudentDirectoryTests` | 3 store-releasing tests crashed (incl. `@MainActor` probe) | fact 3, 4 |
| 2026-11-08 | same + `IPHONEOS_DEPLOYMENT_TARGET=26.0` | same crashes | fact 5; agent's hypothesis rejected |
| 2026-11-08 | probe run C (unit probes + app-launch probe together) | interrupted by the student; design flaw found (launch probe would crash the unit-test host too) | split into C1/C2 |
| 2026-11-08 | C1: deinit probes | empty class, class with array, store on later main-queue turn crashed; `UIViewController` subclass and kept-alive store passed | facts 3, 6 |
| 2026-11-08 | C2: app releases a store at launch + starter UI launch test | passed, no crash report | fact 7 |
| 2026-11-08 | D: probe copy with `#if compiler(>=6.2) nonisolated deinit {} #endif` in `StudentStore` | starter + probe tests passed, no crash | R-17 options |
| 2026-11-08 | exact command, then `-only-testing:StudentDirectoryTests -test-iterations 20` and `-only-testing:StudentDirectoryUITests -test-iterations 5`, first form of the workaround in the repo | all passed (4/4, 20/20, 5/5); console showed 19 of 20 lines for one test | fact 13; superseded by R-19 |
| 2026-11-08 | mutant `plain-deinit` (drop `nonisolated`) on `testStarterStoreIsConstructible` | passed: mutant survived (`artifacts/T0-mutant-plain-deinit-survived.log`) | disassembly -> equivalent mutant (fact 12); R-19 |
| 2026-11-08 | first attempt to regenerate `T0-baseline.log` | failed: baseline `.xcresult` already deleted; the crash section was appended twice | duplicate removed before commit; fact 11 |
| 2026-11-08 | R-19 `deinit {}`: exact command, unit 20x, UI 5x | all passed: 4/4, 20/20 per unit test, 5/5 per UI test (`artifacts/T0-green.log`) | none |
| 2026-11-08 | mutant `remove-deinit` on `testStarterStoreIsConstructible` | failed as expected: `Test crashed with signal abrt` (`artifacts/T0-red-mutant-remove-deinit.log`) | none |
| 2026-11-08 | protected-file check script | first version wrongly reported the allowed `deinit {}` (whitespace in the comparison); fixed; negative check on a copy with a renamed parameter fails as expected | none |
| 2026-11-08 | CI run `42516097673` attempt 1 (push of `339d150`) | failure after ~1.5 min: `Unable to find a device matching the provided destination specifier` (exit 70), nothing built | student re-ran the job |
| 2026-11-08 | CI run `42516097673` attempt 2 | success: Xcode 16.4, iPhone 17 iOS 26.2, 4/4 tests | fact 14 |
| 2026-11-08 | script over `StudentSeedData.swift`: subject lists vs name/id order | every subject is in id order; Physics also in name order | R-20 |
| 2026-11-08 | T1: `-only-testing:StudentDirectoryTests` | passed 8/8 (6 new + 2 starter), no compiler warnings | none |
| 2026-11-08 | T1: `-only-testing:StudentDirectoryTests -test-iterations 20` | every unit test 20/20 | none |
| 2026-11-08 | T1: exact command | passed 10/10 | none |
| 2026-11-08 | T1: 7 mutants, each with `-only-testing` of its target test | all 7 failed on the expected rule message (`artifacts/T1-red-mutant-*.log`) | none |
