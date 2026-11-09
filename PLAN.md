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
| R-4 | Waiting in UI tests | `waitForExistence(timeout:)` only as a guard, then `XCTFail` + `throw`; guard 10 s, revised to 20 s by R-27 | assignment forbids sleeps/polling/timing thresholds |
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
| R-21 | Cell texts (tests check them exactly) | `Ada Lovelace` / `Age 20` / `Grade 97.5` / `Scholarship` or `No scholarship`; accessibility label `Ada Lovelace, age 20, grade 97.5, scholarship holder` | readable without context; scholarship is always text |
| R-22 | How tests see the cell content | internal read-only views (`nameLabel`, `ageLabel`, `gradeLabel`, `scholarshipLabel`, `avatarView`, `contentStack`) via `@testable` | exact checks that survive layout changes |
| R-23 | Cell layout at very large text sizes | adaptive: avatar beside the text normally, above it for accessibility sizes (student's choice; agent recommended a fixed horizontal layout first) | see Risks |
| R-24 | Missing avatar asset | fall back to `avatar-default`, no crash | the asset exists in the template |
| R-25 | The template never connects `SceneDelegate` (fact 22) | set `configuration.delegateClass = SceneDelegate.self` in `StudentDirectoryApp` (+2 body lines), in `feat(T2)`; the student informs the instructor | minimal, no project file change; without it no UI test can pass |
| R-26 | Test run time (revises R-14 and the per-task runs) | (A) focused runs and mutants with `-parallel-testing-enabled NO`; (B) from T3 no separate first green run and no per-task exact command (CI runs it after every push, T7 runs it); (C) from T3 UI tests x5 only for the task's new UI tests, all UI tests x5 once in T7; all mutants kept | a mutant cost ~2 min, mostly simulator cloning, not the test |
| R-27 | `testSeedStudentCellIsFoundByIdentifier` failed 1 of 5 repetitions (blank screen, empty accessibility tree for 10 s, no crash, cause unknown) | (b) UI guard 10 s -> 20 s (student's choice; the agent recommended a longer relaunch probe first) | see Risks; the likely cause was found later (R-28, fact 26) and fixed (R-30); the 20 s guard is kept |
| R-28 | Mutant `no-scene-delegate-class` survived on the main simulator | (a) test the "saved scene session" hypothesis on a separate fresh simulator (`APD Probe`) | confirmed: facts 26, 30 |
| R-29 | First fix for saved delegate-less sessions | (a) destroy such sessions in `didFinishLaunching` | **did not work** (fact 27); never committed |
| R-30 | Second fix | (a) `StudentDirectoryApp` observes `UIScene.willConnectNotification`; a scene without a delegate gets a new `SceneDelegate`, which builds the window through `connect(_:)` | works on a device with a saved delegate-less session and on a fresh one (fact 28) |
| R-31 | The R-25 line became redundant after R-30 (equivalent mutant) | (a) keep both: R-25 is the standard path, R-30 the fallback; the R-25 line is not proven by any test | two independent mechanisms; recorded honestly as an equivalent mutant |
| R-32 | Subjects on the details screen in T3 | buttons with the subject titles from T3; T4 adds the action and `subjectButton.<subject>` | no rework in T4, no T4 rule in T3 |
| R-33 | Details texts | name as a large title, `ID <uuid>`, `Age 22`, `Grade 91.5`, `No scholarship`, `Avatar avatar-03`, heading `Subjects` + subjects; the navigation title is the name | consistent with R-21, reuses `StudentFormatting` |
| R-34 | Details for a student that is no longer in the store | one label `Student not found`, no fields, no subjects | simple and unit-testable; needed for the bonus delete |
| R-35 | Dynamic Type test for the details screen (not in the original list) | add `testDetailsTextSupportsDynamicType` | rubric item 4; catches a forgotten `adjustsFontForContentSizeCategory` |
| R-36 | Data for `testFilteredListShowsExactMatchesInStoreOrder` (revises the planned Physics data, as R-20) | a custom store with ids and names out of order (`Zed`(3), `Amy`(1), `Mia`(2), `Bob`(4)) | seed Physics is already in id and name order; the UI test covers the real `Design` data |
| R-37 | How a subject button starts the push | `UIAction` with a closure (`addAction(_:for:)`) | no `@objc`, no lookup of the subject by tag or title |
| R-38 | T5 scope | (a) one UI test at the largest text size (`AccessibilityXXXL`): list -> Ada's details -> `Design` button below the screen -> filtered list; plus the audit table under Acceptance criteria | the only rubric item not yet checked end to end; scrolling or overlap at large text sizes is invisible to unit tests |
| R-39 | One store per scene | (a) keep the store in `SceneDelegate` and document it | on iPhone the app has exactly one scene (fact 40), so there is one store; a second window on iPad would get its own store (see Risks) |
| R-40 | How the T5 test proves the large text size applied | (a) two launches in the test: default size, then the largest; the Ada row must be taller at the largest size | a wrong argument name is ignored silently (fact 37) and would give a false green; comparing two heights needs no device-specific number |
| R-41 | Rule name when an XCUI tap fails (it reports its own message) | (c) wrap the tap in `XCTContext.runActivity(named: "Rule: ...")`; the logs print the failed `Rule:` activity as `failure-activity:` | deterministic, the rule is visible in the report (fact 39); a manual `swipeUp()` would depend on swipe speed |
| R-42 | How to split the bonus (T6) | (a) four sub-tasks with their own tests, commits and logs: T6.1 store tests, T6.2 form and add, T6.3 edit, T6.4 swipe-delete and list refresh | each finished part is committed on its own; a missing part does not risk the others or the base (R-2) |
| R-43 | Form for add and edit | (a) own `StudentFormViewController` (two fields, Save, Cancel, error label) in a modal `UINavigationController`, shared by add and edit | unit-testable save path; the form stays open on invalid input (a `UIAlertController` closes on any button and its handlers are not reachable from tests) |
| R-44 | Where the bonus buttons are | `addStudentButton`: right bar button only on the main `Students` list (a new student has no subjects, so a filtered list would not show it); `editStudentButton`: right bar button on the details screen, not on `Student not found` | buttons only where they make sense |
| R-45 | Identifiers of the form (not given by the assignment) | `studentNameField`, `studentAgeField`, `saveStudentButton`, `cancelStudentButton`, `studentFormError` | fixed now, not renamed later |
| R-46 | How screens refresh after a mutation | (a) the list calls `reloadData()` in `viewWillAppear` and right after a delete; details re-read the store after the form saves (`onSave` closure) | no change to the protected store; R-7 already makes the store the only source |
| R-47 | Age text that is not a number (pasted `abc`) | (a) the form shows `Age must be a positive whole number` and does not call the store; `Int(...)`, no `!` | a clear message, no hidden conversion; a `numberPad` field still accepts pasted text |
| R-48 | Name with spaces around it | (a) passed to the store as typed; the store is the only validation authority and keeps the name as given | one validation rule, no second rule in the form |
| R-49 | Swipe-delete on the filtered list | (a) yes: the same controller (R-6) deletes from the shared store, so the student disappears everywhere | one code path, no special case |
| R-50 | Testing "a new UUID" without relying on random values | (a) compare the new id with the fixed test ids | `UUID()` is always version 4 and the fixed ids are version 0 (fact 41), so they can never be equal, whatever random value comes out |
| R-51 | Blank name and non-positive age together: which error | (a) not tested; every test has one invalid field | the assignment does not define the order; a test would pin an unrequired detail |
| R-52 | After adding, the new student is the 11th row below the screen | (a) the list scrolls to the new row | the user sees the result of the save; without it nothing visible changes |
| R-53 | How unit tests press Save | (a) the form's internal `save()` is called directly; the wiring of the button is proven by UI tests | no `action!` in tests |
| R-54 | Age text with spaces (`" 19"`) | (a) strict `Int(text)`: an age error | input taken as typed, like R-48 |
| R-55 | Form titles | `New Student` (add), `Edit Student` (edit) | one form, the title tells which mode is open |
| R-56 | How cancel is tested | (a) a unit test if a presented form's closing is visible synchronously, otherwise (b) a UI test | fact 43: it is not visible, so (b) `testCancelClosesFormWithoutAdding`; the unit test `testCancelDoesNotChangeStore` checks only the store |
| R-57 | Speed-up asked by the student | (a) edit (T6.3) and swipe-delete (T6.4) in one cycle named T6.3: one red and one green commit, one mutant batch | same tests and mutants; saves one full round of messages; risk: stopping midway leaves both parts uncommitted |
| R-58 | Confirmation before deleting | (b) an alert `Delete <name>?` / `This cannot be undone.` with `Delete` (destructive) and `Cancel` (student's choice; the agent recommended no extra alert, as swipe + Delete is already two steps) | see Risks |
| R-59 | How the swipe is built | (a) `trailingSwipeActionsConfigurationForRowAt` with a destructive `UIContextualAction` `Delete` | its `handler` can be called from a unit test, no window or `!` needed |

Agent-proposed conventions accepted by the student: task order T0-T7; app
files `StudentListViewController.swift`, `StudentCell.swift`,
`StudentDetailViewController.swift`, `StudentFormatting.swift`; test files and
classes listed under Acceptance criteria; `@MainActor` test classes; log names
`T<n>-red.log`, `T<n>-green.log`, `T<n>-red-mutant-<name>.log`,
`T0-baseline.log`, `final-xcodebuild-test.log`; commits
`test(Tn)` / `feat(Tn)` / `docs(Tn)` (plus `fix(T0)` from R-17) on `main`;
clone at `<workspace>/apd-hw-3-Klimenko`. T1: factory
`makeStudent(id:name:subjects:)`, the exact-error helper deferred to T6.
T2: `StudentFormatting` is an `enum` with static functions shared by the cell
and the details screen; `UITestSupport.swift` with `launchApp()` and
`waitOrFail(_:rule:)`; one extra unit test for R-23
(`testCellStacksVerticallyForAccessibilityTextSizes`). T3: the details avatar
has the accessibility label `Avatar of <name>`; no disclosure indicator in the
list cells (not required, would be untested); UI tests use Grace Hopper (row
3, always on screen); helpers `makeListInNavigation(store:)`,
`makeLoadedDetails(store:studentID:)`, `assertFollowsDynamicType(_:_:)` in
`TestSupport.swift` (the T2 test keeps its own inline check). T4: buttons are
tapped in unit tests with `sendActions(for: .touchUpInside)` (fact 35);
`makeLoadedFilteredList(store:subject:)`; `makeListInNavigation` got a
defaulted `subject` parameter. T5: `launchApp` got a defaulted `arguments`
parameter; the test is green at once because the code already supports it, so
the proof is mutants (as R-5, one `test(T5)` commit); mutants chosen by the
agent after the probes (`detail-no-scroll-bottom`, `fixed-row-height`).
T6 (accepted with R-42…R-51): the T1 exact-error helper is
`assertThrows(_:error:rule:)` in `TestSupport.swift`; every rejected mutation
also checks that `store.students` is unchanged; error texts
`Name must not be blank` and `Age must be a positive whole number`; T6.1 is
one `test(T6.1)` commit (as T1), T6.2-T6.4 are `test(T6.n)` red then
`feat(T6.n)` green; UI-level test names are fixed before each sub-task.

## Milestones

- [x] T0: fork, plan, worklog, baseline run (crash found, R-17)
- [x] T0 fix: R-17/R-19 workaround, green run, mutants
- [x] T1: store characterization tests (unit), 7 mutants
- [x] Student list and reusable cell (T2), including the scene fixes R-25/R-30
- [x] Detail screen and navigation (T3)
- [x] Subject-filtered list (T4)
- [x] Accessibility/MVC/SnapKit audit and the largest-text-size UI test (T5)
- [x] Unit and UI tests (T1-T6, per task): 58 unit + 13 UI student tests
- [x] Optional add/edit/delete bonus (T6, split by R-42)
  - [x] T6.1 store mutation tests
  - [x] T6.2 form and add
  - [x] T6.3 edit and swipe-delete with confirmation (T6.3 + T6.4 in one cycle, R-57)
- [x] Local verification and CI review (each task, final in T7)
- [x] Final diff and evidence review (T7; the clean-clone run of the submitted SHA is reported in chat, R-11)

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
  `testListReflectsStoreChangesAfterReload`,
  `testCellStacksVerticallyForAccessibilityTextSizes` (R-23).
  `StudentListUITests` (UI): `testLaunchShowsStudentsList`,
  `testSeedStudentCellIsFoundByIdentifier`.
  Red (`artifacts/T2-red.log`): with neutral placeholders
  (`StudentListViewController(store:)`, `StudentCell`, `StudentFormatting`)
  all 13 fail on their rule message; the 8 T1/starter unit tests stay green.
  The `subject` parameter of the list (R-6) is added in T4 together with its
  tests, not in T2.
  Green (`artifacts/T2-green.log`, final code): all 19 unit tests 20/20, all
  4 UI tests 5/5 (main iPhone 17, no clones), and both `StudentListUITests`
  pass on `APD Probe` after a delegate-less scene session was saved (R-30).
  The first UI x5 series with a 10 s guard is kept as
  `artifacts/T2-green-ui5-flaky-attempt.log` (R-27).
  Mutants (one changed line each, `artifacts/T2-red-mutant-<name>.log`):

  | Test | Mutant |
  | --- | --- |
  | `testListTitleIsStudents` | `title-typo` |
  | `testListHasOneRowPerStoreStudent` | `rows-off-by-one` |
  | `testListRowsFollowStoreOrder` | `rows-sorted-by-name` |
  | `testListTableHasStudentListIdentifier` | `table-id-typo` |
  | `testCellShowsNameAgeGradeAndScholarship` | `grade-shows-age`, `avatar-default-always` |
  | `testReusedCellResetsScholarshipState` | `scholarship-no-else` |
  | `testCellAccessibilityLabelSummarizesStudent` | `not-one-a11y-element`, `a11y-label-name-only` |
  | `testCellTextSupportsDynamicType` | `no-dynamic-type`, `fixed-font` |
  | `testGradeFormattingFollowsLocale` | `locale-ignored` |
  | `testListReflectsStoreChangesAfterReload` | `seed-array` (the list reads the seed, a second array, instead of the shared store; a true "copy at init" needs two lines) |
  | `testCellStacksVerticallyForAccessibilityTextSizes` | `always-horizontal` |
  | UI `testLaunchShowsStudentsList` | `no-navigation-controller` |
  | UI `testSeedStudentCellIsFoundByIdentifier` | `cell-id-dash` |
  | UI `StudentListUITests` on `APD Probe` with a saved delegate-less session | `adopt-without-window` (R-30) |

  Equivalent mutant: `no-scene-delegate-class` (R-25 line removed) passes on
  a fresh device because R-30 adopts the scene
  (`artifacts/T2-mutant-no-scene-delegate-class-equivalent.log`, R-31).
- T3 `StudentDetailTests` (unit):
  `testSelectingRowPushesDetailsOfThatStudent`,
  `testDetailsShowEveryStudentField`,
  `testDetailsViewHasStudentDetailsIdentifier`,
  `testDetailsForMissingStudentShowNoStudentData` (agent-proposed rule, a
  consequence of R-7, not an assignment requirement),
  `testDetailsTextSupportsDynamicType` (R-35).
  `StudentDetailUITests` (UI): `testTappingStudentOpensDetails`,
  `testBackReturnsToStudentsList`.
  Red (`artifacts/T3-red.log`): with a neutral
  `StudentDetailViewController(store:studentID:locale:)` and an empty
  `didSelectRow` all 7 fail on their rule; the 19 older unit tests stay green.
  Green (`artifacts/T3-green.log`, R-26): all 24 unit tests 20/20, both T3 UI
  tests 5/5. After green, `testBackReturnsToStudentsList` got a
  `waitOrFail` on the back button, so that a missing button fails with the
  rule name instead of an XCUI tap error (found by mutant `hide-back-button`).
  Mutants (one changed line each, `artifacts/T3-red-mutant-<name>.log`):

  | Test | Mutant |
  | --- | --- |
  | `testSelectingRowPushesDetailsOfThatStudent` | `push-first-row`, `no-push` |
  | `testDetailsShowEveryStudentField` | `id-shows-name`, `subjects-drop-first`, `avatar-name-hidden`, `no-title` |
  | `testDetailsViewHasStudentDetailsIdentifier` | `details-id-typo` |
  | `testDetailsForMissingStudentShowNoStudentData` | `missing-shows-first` |
  | `testDetailsTextSupportsDynamicType` | `details-no-dynamic-type`, `button-fixed-font` |
  | UI `testTappingStudentOpensDetails` | `no-push-ui` |
  | UI `testBackReturnsToStudentsList` | `hide-back-button` |
- T4 `SubjectFilterTests` (unit): `testDetailsHaveButtonForEachSubject`,
  `testTappingSubjectPushesListTitledWithSubject`,
  `testFilteredListShowsExactMatchesInStoreOrder`,
  `testFilteredListIsCaseSensitive`,
  `testFilteredRowOpensDetailsOfFilteredStudent`.
  `SubjectFilterUITests` (UI): `testSubjectButtonOpensFilteredList`,
  `testFilteredListRowOpensCorrectDetails`.
  Red (`artifacts/T4-red.log`): with `subject` stored but unused and subject
  buttons without identifier and action, all 7 fail on their rule; the 24
  older unit tests stay green.
  Green (`artifacts/T4-green.log`, R-26): all 29 unit tests 20/20, both T4 UI
  tests 5/5. Mutants (one changed line each, `artifacts/T4-red-mutant-<name>.log`):

  | Test | Mutant |
  | --- | --- |
  | `testDetailsHaveButtonForEachSubject` | `button-id-typo` |
  | `testTappingSubjectPushesListTitledWithSubject` | `title-not-subject`, `button-opens-full-list`, `no-button-action` |
  | `testFilteredListShowsExactMatchesInStoreOrder` | `filter-ignored`, `filtered-sorted` (R-36 data) |
  | `testFilteredListIsCaseSensitive` | `vc-case-insensitive` (the list filters by itself, ignoring case) |
  | `testFilteredRowOpensDetailsOfFilteredStudent` | `row-from-full-list` (`store.students[row]` instead of the filtered rows) |
  | UI `testSubjectButtonOpensFilteredList` | `button-id-typo-ui`, `filter-ignored-ui` |
  | UI `testFilteredListRowOpensCorrectDetails` | `row-from-full-list-ui` |
- T5 `AccessibilityUITests` (UI):
  `testLargestTextSizeKeepsListDetailsAndFilterUsable` (R-38, R-40, R-41).
  Green at once (R-5; `artifacts/T5-green.log`): the new test 5/5, all 9 UI
  tests once after the `launchApp(arguments:)` change. Mutants (one changed
  line each, `artifacts/T5-red-mutant-<name>.log`):

  | Mutant | Fails with |
  | --- | --- |
  | `detail-no-scroll-bottom` (details stack pinned only `top.leading` to the scroll content, so no content height) | XCUI `Failed to not hittable … subjectButton.Design` inside `Rule: at the largest text size the Design button can be scrolled to and tapped` |
  | `fixed-row-height` (`tableView.rowHeight = 88`) | `Rule: the largest text size makes the Ada row taller than the default size` (88 vs 88) |

  With `detail-no-scroll-bottom` the T3/T4 UI tests still pass at the default
  size (`artifacts/T5-mutant-detail-no-scroll-bottom-default-size-survives.log`),
  so only the T5 test catches this defect.

  Audit (rubric item 4), checked on the code at `test(T5)`:

  | Requirement | Evidence |
  | --- | --- |
  | One shared `StudentStore` | `StudentStore()` appears only in `SceneDelegate.connect(_:)`; every controller gets it by `init` (R-39, fact 40) |
  | No duplicated authoritative arrays | list and details read the store on every access (R-7); mutants `seed-array`, `missing-shows-first`, `row-from-full-list` |
  | MVC | the cell gets a `Student` and never sees the store; controllers read the store and navigate |
  | SnapKit | every constraint uses SnapKit; no `NSLayoutConstraint` and no `translatesAutoresizingMaskIntoConstraints` in the app code |
  | No `!` on user input | no `!`, `try!` or `as!` in the app code outside the supplied seed data; `UIImage(named:) ?? avatar-default` |
  | Identifiers | `studentList`, `studentCell.<id>`, `studentDetails`, `subjectButton.<subject>` (unit and UI tests T2-T4) |
  | Labels | one combined label per cell (R-10), avatar label `Avatar of <name>`, scholarship always as text |
  | Dynamic Type | text styles + `adjustsFontForContentSizeCategory` (unit tests T2, T3), adaptive cell (R-23), details in a scroll view; end to end at `AccessibilityXXXL` (T5) |
- T6.1 `StoreMutationTests` (unit, `StudentDirectoryTests/StoreMutationTests.swift`,
  helper `assertThrows(_:error:rule:)` in `TestSupport.swift`): store of
  `Zed`(1), `Amy`(2), `Mia`(3), unknown id `…09`. Green at once (R-5;
  `artifacts/T6.1-green.log`): all 39 unit tests 20/20. Every mutant changes
  one line of `StudentStore.swift` (where a line occurs twice, the mutant
  names the occurrence: 1 = `addStudent`/`updateStudent`, 2 =
  `updateStudent`/`deleteStudent`) and fails its target test with that test's
  rule (`artifacts/T6.1-red-mutant-<name>.log`):

  | Test | Mutant |
  | --- | --- |
  | `testAddAppendsStudentWithBonusDefaults` | `add-grade-one` (`averageGrade: 1`), `add-prepend` (`insert(…, at: 0)`) |
  | `testAddGivesNewStudentANewID` | `add-reuse-id` (`id: students.first?.id ?? UUID()`) |
  | `testAddRejectsBlankNameWithoutChange` | `blank-no-trim` (`name.isEmpty`), `add-no-validate` (validation line removed in `addStudent`) |
  | `testAddRejectsNonPositiveAgeWithoutChange` | `age-lt-zero` (`age < 0`) |
  | `testAddAcceptsSmallestPositiveAge` | `age-le-one` (`age <= 1`) |
  | `testUpdateChangesOnlyNameAndAge` | `update-skips-age` (age assignment removed) |
  | `testUpdateRejectsInvalidInputWithoutChange` | `update-no-validate` (validation line removed in `updateStudent`) |
  | `testUpdateUnknownIDThrowsWithoutChange` | `update-unknown-silent` (`return` instead of `throw`) |
  | `testDeleteRemovesOnlyThatStudent` | `delete-removes-first` (`remove(at: 0)`) |
  | `testDeleteUnknownIDThrowsWithoutChange` | `delete-unknown-silent` (`return` instead of `throw`) |
- T6.2 `AddStudentTests` (unit): `testMainListHasAddStudentButton`,
  `testFilteredListHasNoAddStudentButton`, `testAddButtonPresentsEmptyAddForm`,
  `testSavingValidInputAddsStudentAndRefreshesList`,
  `testBlankNameShowsErrorAndKeepsStore`,
  `testNonPositiveAgeShowsErrorAndKeepsStore`,
  `testNonNumericAgeShowsErrorAndKeepsStore`, `testNameIsSavedAsTyped`,
  `testCancelDoesNotChangeStore`, `testFormSupportsDynamicType`.
  `AddStudentUITests` (UI): `testAddingStudentShowsItInList`,
  `testInvalidInputShowsErrorAndKeepsForm`, `testCancelClosesFormWithoutAdding`
  (R-56 fallback, fact 43). Helpers: `makeListInWindow(store:)`,
  `assertFieldFollowsDynamicType`, `waitForDisappearanceOrFail`,
  `cells(labelStartingWith:in:)`.
  Red (`artifacts/T6.2-red.log`): with a neutral form stub and no add button
  11 tests fail on their rules; `testCancelDoesNotChangeStore` and
  `testFilteredListHasNoAddStudentButton` pass on the stub (doing nothing
  never saves; no button anywhere) and are proven by mutants.
  Green (`artifacts/T6.2-green.log`): all 49 unit tests 20/20, the 3 new UI
  tests 5/5. Mutants (`artifacts/T6.2-red-mutant-<name>.log`):

  | Test | Mutant |
  | --- | --- |
  | `testMainListHasAddStudentButton` | `add-button-id-typo` |
  | `testFilteredListHasNoAddStudentButton` | `add-button-everywhere` (`if true`) |
  | `testAddButtonPresentsEmptyAddForm` | `form-title`, `present-without-navigation` |
  | `testSavingValidInputAddsStudentAndRefreshesList` | `no-reload`, `no-on-save` |
  | `testBlankNameShowsErrorAndKeepsStore` | `blank-message-wrong`, `error-stays-hidden` |
  | `testNonPositiveAgeShowsErrorAndKeepsStore` | `age-message-wrong` |
  | `testNonNumericAgeShowsErrorAndKeepsStore` | `age-trimmed` (R-54) |
  | `testNameIsSavedAsTyped` | `name-trimmed` (R-48) |
  | `testCancelDoesNotChangeStore` | `cancel-saves` |
  | `testFormSupportsDynamicType` | `field-fixed-font` |
  | UI `testAddingStudentShowsItInList` | `no-scroll` (R-52), `save-no-dismiss` |
  | UI `testCancelClosesFormWithoutAdding` | `cancel-no-dismiss` |
- T6.3 (edit and swipe-delete in one cycle, R-57). `EditStudentTests` (unit):
  `testDetailsHaveEditStudentButton`, `testNotFoundDetailsHaveNoEditButton`,
  `testEditButtonPresentsFilledEditForm`,
  `testSavingEditUpdatesStoreAndRefreshesDetails`,
  `testInvalidEditShowsErrorAndKeepsStore`,
  `testEditOfDeletedStudentShowsNotFound`, `testListReloadsWhenItAppearsAgain`.
  `DeleteStudentTests` (unit): `testSwipeOffersDestructiveDeleteAction`,
  `testSwipeDeleteAsksForConfirmationFirst`,
  `testConfirmedDeleteRemovesStudentFromStoreAndList`,
  `testConfirmedDeleteOnFilteredListRemovesStudentEverywhere`.
  UI: `EditStudentUITests.testEditingStudentUpdatesDetailsAndList`,
  `DeleteStudentUITests.testConfirmedSwipeDeleteRemovesStudent`,
  `DeleteStudentUITests.testCancelledDeleteKeepsStudent`. Helper
  `makeDetailsInWindow(store:studentID:)`.
  Red (`artifacts/T6.3-red.log`): with neutral stubs (the form ignores
  `editing`, no edit button, no swipe action, empty `deleteStudent`, no
  reload on appear) 13 tests fail on their rules;
  `testNotFoundDetailsHaveNoEditButton` passes on the stub and is proven by a
  mutant. Green (`artifacts/T6.3-green.log`): all 60 unit tests 20/20, the 3
  new UI tests 5/5. Mutants (`artifacts/T6.3-red-mutant-<name>.log`):

  | Test | Mutant |
  | --- | --- |
  | `testDetailsHaveEditStudentButton` | `edit-button-id-typo` |
  | `testNotFoundDetailsHaveNoEditButton` | `not-found-has-edit` |
  | `testEditButtonPresentsFilledEditForm` | `edit-title`, `edit-not-prefilled` |
  | `testSavingEditUpdatesStoreAndRefreshesDetails` | `edit-adds-instead`, `details-no-refresh` |
  | `testInvalidEditShowsErrorAndKeepsStore` | `edit-errors-swallowed` (`try?`) |
  | `testEditOfDeletedStudentShowsNotFound` | `not-found-message-wrong` |
  | `testListReloadsWhenItAppearsAgain` | `no-reload-on-appear` |
  | `testSwipeOffersDestructiveDeleteAction` | `swipe-not-destructive` |
  | `testSwipeDeleteAsksForConfirmationFirst` | `swipe-deletes-at-once`, `alert-title-generic` |
  | `testConfirmedDeleteRemovesStudentFromStoreAndList` | `delete-ignores-store`, `delete-no-reload` |
  | `testConfirmedDeleteOnFilteredListRemovesStudentEverywhere` | `filtered-delete-skipped` |
  | UI `testConfirmedSwipeDeleteRemovesStudent` | `confirm-does-not-delete` |
  | UI `testCancelledDeleteKeepsStudent` | `cancel-deletes` |
  | UI `testEditingStudentUpdatesDetailsAndList` | `no-reload-on-appear-ui` |
- T7: the exact README command on the last code commit `46e091b`:
  `TEST SUCCEEDED`, 75/75 (60 unit: 58 student + 2 starter; 15 UI: 13 student
  + 2 starter) (`artifacts/final-xcodebuild-test.log`); all 15 UI tests 5/5
  (`artifacts/T7-ui5.log`, R-26 C); CI green for the last code commit; a clean
  anonymous clone of the submitted SHA green with the exact command (reported
  in chat after the push, R-11). Checks at T7: protected files unchanged
  except R-19/R-25/R-30, template `HEAD` still `938bf69` (R-15), repository
  public, no `fatalError`/`try!`/`as!` in app code, no duplicated test names,
  no tracked build output, secrets or personal paths, no unfilled student placeholders.

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
| R-23 (student's choice): the adaptive cell layout adds code, depends on trait-change handling that does not run by itself without a window (fact 20), and a bug in it is invisible at normal text sizes | a dedicated unit test switches the trait both ways; all other cell tests check texts and labels that do not depend on the layout mode |
| The template app shows no window at all (fact 22); the starter UI tests only check `runningForeground` | R-25 fix in `feat(T2)`; every UI test first waits for a screen element |
| The local simulator locale is `en_UA` (`97,5`), CI probably differs | R-9: unit tests pass a locale, UI tests never assert grade text |
| Lower cells exist in the XCUI tree but are not hittable (fact 17) | UI tests tap only cells near the top |
| The `.xcresult` summary lists only the first failure of a test | logs and fact checks read every failure from the test details (fact 23) |
| A scene session saved by a build without a delegate (the template, an older build) is restored on every launch and bypasses `configurationForConnecting`, so the R-25 fix alone gives a blank app on such a device (fact 26) | R-30 adopts such scenes; checked on `APD Probe` with a saved delegate-less session (green log section 3, mutant `adopt-without-window`) |
| UI test results on the main simulator depend on its saved scene sessions (fact 30) | scene-related checks and mutants run on the separate `APD Probe` simulator with an explicit setup (erase, then a delegate-less launch) |
| A misspelled content-size launch argument is ignored without an error, so a large-text test would silently run at the default size (fact 37) | R-40: the T5 test compares the Ada row height with a default-size launch |
| An XCUI tap that cannot scroll fails with XCUI's own message, not a `Rule:` message | R-41: the tap runs inside a `Rule:` activity; the logs print it as `failure-activity:` |
| R-39: the project allows multiple scenes and targets iPhone and iPad (fact 40); on iPad a second window would build its own `SceneDelegate` and its own `StudentStore`, so two windows would not share data (inference, not run on iPad) | on iPhone, the assignment's device, a second scene is refused (fact 40); moving the store to `AppDelegate` would be the fix if iPad windows are ever needed |
| R-58 (student's choice): an alert's button handlers cannot be called from a unit test, so "the alert's Delete deletes" and "Cancel keeps" are proven only by UI tests | unit tests check that the swipe shows the alert and deletes nothing, and that `deleteStudent(withID:)` deletes; two UI tests cover the confirmed and the cancelled path |
| R-27 (student's choice): the cause of the blank-screen repetition is unknown; a longer guard only helps if the launch was slow, and a real scene-connection defect could show up again on CI or for users | every UI test first waits for a screen-unique element, so a blank screen still fails with the rule name; repeats (R-14) keep looking for it; the first failed series is kept in `artifacts/T2-green-ui5-flaky-attempt.log` |

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
15. With the R-25 scene fix, XCUI finds `app.cells["studentCell.<id>"]` for a
    cell with `isAccessibilityElement = true`, and `label` is the combined
    accessibility label; the inner `UILabel` is still visible to XCUI as a
    `staticText`.
16. The SVG avatars load with `UIImage(named:)`; a missing asset name gives
    `nil`.
17. With 88 pt rows all 10 seed cells exist in the XCUI tree on iPhone 17,
    but the last one is not hittable (off screen).
18. `Double.formatted(.number.precision(.fractionLength(1)).locale(_:))`:
    `en_US_POSIX` -> `97.5`, `uk_UA` -> `97,5`, `94.0` -> `94.0`. The local
    simulator locale is `en_UA`, which gives `97,5`.
19. `UIFont.preferredFont(forTextStyle: .body)` has the text style attribute
    `UIFont.TextStyle.body.rawValue`, but a fixed `UIFont.systemFont(ofSize:)`
    also has a text style attribute (`CTFontRegularUsage`), so a test must
    compare with real text style names.
20. `traitOverrides` on a cell without a window are not applied by
    `layoutIfNeeded()`: neither `traitCollection` nor a
    `registerForTraitChanges` handler sees them. They are applied by
    `updateTraitsIfNeeded()`, or by `layoutIfNeeded()` when the cell is in a
    window. (The agent's first reading, "applied on `layoutIfNeeded()`", was
    wrong; see fact 23.)
21. `pushViewController(_:animated:)` on a navigation controller without a
    window updates `viewControllers` at once, with and without animation.
22. The template never connects `SceneDelegate`: the generated `Info.plist`
    has an empty `UISceneConfigurations`, and
    `application(_:configurationForConnecting:options:)` returns a
    configuration without `delegateClass`, so no window is created. Control
    runs on `7031d9f`: the `HW3 Starter` label never appears; with
    `configuration.delegateClass = SceneDelegate.self` it does.
23. `xcresulttool get test-results summary` lists only the first failure of a
    test; `get test-results test-details` lists all of them.
24. When the system restores a scene session on relaunch,
    `application(_:configurationForConnecting:options:)` is not called, but
    `SceneDelegate` is still created (8 relaunches with `NSLog` probes: launch
    2 restored a session, all 8 showed the list). So the agent's hypothesis
    "restored sessions lose the R-25 `delegateClass`" was not confirmed.
25. `UIImage(named:)` returns the same instance for repeated calls with the
    same asset name (the `===` avatar check in
    `testCellShowsNameAgeGradeAndScholarship` passes, and `avatar-01` is not
    `nil`, fact 16).
26. A scene session saved by a build without `delegateClass` is restored on
    every later launch of any build with the same bundle id;
    `configurationForConnecting` is not called, so `SceneDelegate` is never
    created and the screen stays blank (`APD Probe`: the R-25 build after a
    delegate-less build showed nothing in 8/8 launches). Sessions saved by a
    build with `delegateClass` keep the delegate (fact 24). This is the likely
    cause of the R-27 repetition (not proven for that run).
27. `application.requestSceneSessionDestruction(_:options:)` called in
    `didFinishLaunching` for such a restored session has no effect: the same
    session is restored again and the screen stays blank (8/8).
28. `UIScene.willConnectNotification` is posted for a restored scene without a
    delegate (`scene.delegate == nil`); giving it a new `SceneDelegate` and
    building the window shows the list (8/8 relaunches and both list UI tests
    on a device with a saved delegate-less session). On the normal path the
    notification arrives with the delegate already set, so no second window
    is built (8/8 on a fresh device). The scene keeps the assigned delegate.
29. With `-parallel-testing-enabled NO` (R-26 A) a unit-test mutant takes
    19-27 s instead of about 2 min with simulator clones; all 19 unit tests
    x20 take 16 s and the 4 UI tests x5 take 88 s.
30. UI test results on a simulator depend on its saved scene sessions: the
    R-25-only mutant without `delegateClass` passed on the main iPhone 17
    (sessions saved by builds with a delegate) and failed on a fresh device
    (E1 on `APD Probe`).
31. An `accessibilityIdentifier` on a view controller's root view is visible
    to XCUI as `app.otherElements["<id>"]` (type *other*), not as a scroll
    view.
32. On iOS 26 the standard back button is identified as `BackButton` and its
    label is the previous screen's title (`Students`); tapping it returns to
    that screen.
33. Calling `tableView.delegate?.tableView?(_:didSelectRowAt:)` in a unit test
    on a list inside a navigation controller pushes at once (as fact 21).
34. CI (Xcode 16.4, fresh simulator) builds and passes the R-25/R-30 scene code
    (`MainActor.assumeIsolated`, `UIScene.willConnectNotification`): run
    `42532789200` for `8c275a5`, 23/23 tests.
35. `button.sendActions(for: .touchUpInside)` in a unit test without a window
    runs a `UIAction` added with `addAction(_:for:)` exactly once.
36. After a push, cells of the previous screen are no longer in the XCUI tree
    once the new screen's element exists (`studentCell.<02>` absent right
    after `studentDetails` appeared).
37. The launch arguments `-UIPreferredContentSizeCategoryName
    UICTContentSizeCategoryAccessibilityXXXL` (the raw value of
    `UIContentSizeCategory.accessibilityExtraExtraExtraLarge`) set the largest
    text size: the Ada row is 344 pt instead of 111 pt. The constant's Swift
    name `UIContentSizeCategoryAccessibilityExtraExtraExtraLarge` as the value
    is ignored without an error (111 pt).
38. At the largest text size the `subjectButton.Design` button in Ada's details
    is below the screen (y = 1072, window height 874, not hittable); XCUI
    `tap()` scrolls it into view and taps it. If the scroll view has no content
    height, `tap()` fails with `Failed to not hittable: Button … identifier:
    'subjectButton.Design'`, and the test stops there.
39. A failure inside `XCTContext.runActivity(named:)` marks that activity with
    `isAssociatedWithFailure` in `xcresulttool get test-results activities`, so
    the rule in the activity name can be printed next to XCUI's message.
40. The built `Info.plist` has `UIApplicationSupportsMultipleScenes = 1` and
    `UIDeviceFamily` 1 and 2 (iPhone, iPad). On the iPhone 17 simulator
    `UIApplication.shared.supportsMultipleScenes` is `false`, one scene is
    connected, and `requestSceneSessionActivation` fails with "The current
    device does not support multiple scenes." iPad was not checked.
41. `UUID()` produces version 4 UUIDs (variant bits `10`): 100 000 of 100 000
    on macOS (`swift` script) and in the iPhone 17 test host, including the id
    that `StudentStore.addStudent` creates. The fixed test ids built from bytes
    (`00…01`) have version 0, so a new store id can never equal one of them.
42. `present(_:animated: true)` from a controller in a visible `UIWindow`
    sets `presentedViewController` at once (unit test); without a window
    nothing is presented.
43. `dismiss(animated:)` does not clear `presentedViewController` at once,
    not even with `animated: false` or with `UIView.setAnimationsEnabled(false)`.
    So unit tests cannot see a form close without waiting; closing is checked
    in UI tests (R-56 fallback).
44. A `UIBarButtonItem` with an `accessibilityIdentifier` is
    `app.buttons["<id>"]` in XCUI; `typeText("19")` works in a `numberPad`
    field.
45. After `scrollToRow` to the new 11th row, its cell is in the XCUI tree and
    hittable; its label ends with the locale's grade text (`grade 0,0` with
    `en_UA`), so UI tests match new students by the label prefix
    `<name>, age <age>,`.
46. XCUI: `swipeLeft()` on a cell shows its swipe action as
    `app.buttons["Delete"]`; an alert is `app.alerts["<title>"]` with
    `app.alerts.buttons["<title>"]`; after `tap()` on a filled text field the
    cursor is at the end, so `typeText(" Jr")` appends (checked in the T6.3
    scratch green run before the red commit).

Not yet verified: nothing the current code relies on.

## Verification plan

- Focused runs while a task is in progress:
  `xcodebuild -project StudentDirectory.xcodeproj -scheme StudentDirectory -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:<Target>/<Class>`.
- Each green run is repeated (R-14): unit tests `-test-iterations 20`, UI
  tests `-test-iterations 5`; counts are read from `.xcresult`. From T3
  (R-26): the repeats are the green run, UI repeats cover only the task's new
  UI tests, focused runs and mutants use `-parallel-testing-enabled NO`; the
  exact command runs on CI after every push and in T7.
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
| 2026-11-08 | CI run `42519361024` (push of `7031d9f`) | success: Xcode 16.4, 10/10 tests | none |
| 2026-11-08 | T2 probe round 1 (scratchpad copy) | SVG, locale, push: as expected; fixed font also has a text style; trait override not visible; XCUI found no cell | round 2 |
| 2026-11-08 | T2 probe round 2 | trait handler never ran after `layoutIfNeeded()`; XCUI tree of the app was empty; agent found that the summary shows only the first failure | facts 20, 23; check the scene manifest |
| 2026-11-08 | built `Info.plist` | `UISceneConfigurations` empty | R-25 hypothesis |
| 2026-11-08 | T2 probe round 3 with `delegateClass` | XCUI finds cells by identifier, all 10 exist, last not hittable; `updateTraitsIfNeeded()` / window applies traits | facts 15, 17, 20 |
| 2026-11-08 | control: `HW3 Starter` label on `7031d9f` without / with `delegateClass` | not shown / shown | fact 22, R-25 |
| 2026-11-08 | T2 red: `-only-testing:StudentDirectoryTests -only-testing:StudentDirectoryUITests/StudentListUITests` | `TEST FAILED` as expected: 13 T2 tests fail on their rules, 8 others pass (`artifacts/T2-red.log`) | implement T2 |
| 2026-11-08 | T2 green: same selection | passed 21/21, no compiler warnings, no unsatisfiable-constraint logs | repeats |
| 2026-11-08 | T2: all unit tests x20 | every unit test 20/20 | none |
| 2026-11-08 | T2: all UI tests x5 (10 s guard, simulator clones) | **failed**: `testSeedStudentCellIsFoundByIdentifier` 4/5 (`artifacts/T2-green-ui5-flaky-attempt.log`) | investigate |
| 2026-11-08 | T2: exact command | passed 23/23 | none |
| 2026-11-08 | investigation of the failed repetition (`.xcresult` activities, exported UI hierarchy, frames of the screen recording) | app running and idle, blank white screen, empty accessibility tree for 10 s, no crash report; in another repetition of the series the automation setup took 14 s (load) | relaunch probe |
| 2026-11-08 | relaunch probe: 8 launches with `NSLog` in `didFinishLaunching`, `configurationForConnecting`, `SceneDelegate` | list shown 8/8; launch 2 restored a session without `configurationForConnecting`, `SceneDelegate` still created | fact 24; R-27 |
| 2026-11-08 | T2: all UI tests x5 again (20 s guard, no clones) | passed 4/4, each 5/5, 104 s | mutants |
| 2026-11-08 | T2: 17 mutants on the main iPhone 17 (no clones) | 16 failed on their rule; `no-scene-delegate-class` **passed** (survived); unit mutants 19-27 s each | R-28. The log of this survived run was later overwritten by the agent's re-run under the same name (agent mistake); the result is kept in this row |
| 2026-11-09 | E1-E3 on the new `APD Probe` simulator: delegate-less build (M) fresh / R-25 build (A) after M / M after A | E1: blank, both UI tests fail (mutant killed on a fresh device); E2: **A blank 8/8**; E3: blank | facts 26, 30; R-29 |
| 2026-11-09 | V1-V2: R-29 candidate (destroy delegate-less sessions) over a saved session / fresh | V1 blank 8/8, destruction ignored; V2 list 8/8 | R-29 rejected; R-30 |
| 2026-11-09 | W1-W3: R-30 candidate (adopt the scene) over a saved session / fresh | W2 list 8/8 + both UI tests pass; W3 list 8/8, no adoption on the normal path | fact 28; R-30 applied to the repo |
| 2026-11-09 | T2 final: all unit tests x20, all UI tests x5 (main iPhone 17), both list UI tests on `APD Probe` after a delegate-less launch | 20/20, 5/5, passed (`artifacts/T2-green.log`) | none |
| 2026-11-09 | T2 mutants on the final code: `adopt-without-window` (`APD Probe`, saved session), `no-scene-delegate-class` (fresh `APD Probe`), `no-navigation-controller`, `cell-id-dash` | killed, **passed (equivalent)**, killed, killed | R-31 |
| 2026-11-09 | T3 probe (scratchpad copy): details identifier, back button, delegate push | facts 31-33 | none |
| 2026-11-09 | T3 red: `-parallel-testing-enabled NO -only-testing:StudentDirectoryTests -only-testing:StudentDirectoryUITests/StudentDetailUITests` | `TEST FAILED` as expected: 7 T3 tests fail on their rules, 19 pass, 81 s (`artifacts/T3-red.log`) | implement T3 |
| 2026-11-09 | CI run `42532789200` (push of `8c275a5`, `feat(T2)`) | success: Xcode 16.4, 23/23 | fact 34 |
| 2026-11-09 | T3 green: all unit tests x20; T3 UI tests x5 | 24 tests each 20/20 (13 s); 2 tests each 5/5 (88 s) | mutants |
| 2026-11-09 | T3: 12 mutants | all failed; `hide-back-button` failed on an XCUI tap error, not on a rule message | added a `waitOrFail` on the back button |
| 2026-11-09 | T3 UI tests x5 again and mutant `hide-back-button` again | 2 tests each 5/5; the mutant now fails with `Rule: the details screen has the standard back button` | none |
| 2026-11-09 | T4 probe (scratchpad copy): `sendActions` without a window; previous-screen cells after a push | facts 35, 36 | none |
| 2026-11-09 | T4 red: `-parallel-testing-enabled NO -only-testing:StudentDirectoryTests -only-testing:StudentDirectoryUITests/SubjectFilterUITests` | `TEST FAILED` as expected: 7 T4 tests fail on their rules, 24 pass, 78 s (`artifacts/T4-red.log`) | implement T4 |
| 2026-11-09 | T4 green: all unit tests x20; T4 UI tests x5 | 29 tests each 20/20 (14 s); 2 tests each 5/5 (104 s) | mutants |
| 2026-11-09 | T4: 11 mutants | all failed on their rule messages | none |
| 2026-11-09 | T5 probe (scratchpad copy): two argument names, row heights, `tap()` on the off-screen `Design` button, the same with the `detail-no-scroll-bottom` mutant | facts 37, 38; the mutant fails with an XCUI message, not a rule | R-40, R-41 |
| 2026-11-09 | T5 probe: tap inside a `Rule:` activity with the mutant; `make-log.py` extended to print `failure-activity:` | the activity is marked as failed and printed | fact 39 |
| 2026-11-09 | T5 probe: second scene on iPhone 17 (unit test in the hosted app), built `Info.plist` | refused, `supportsMultipleScenes` false | fact 40, R-39 |
| 2026-11-09 | T5 green: new UI test x5; all UI tests once | 5/5 (83 s); 9/9 (76 s) (`artifacts/T5-green.log`) | mutants |
| 2026-11-09 | T5: mutants `detail-no-scroll-bottom`, `fixed-row-height` | both failed, with the rule as `failure-activity:` and as the assertion message | none |
| 2026-11-09 | `detail-no-scroll-bottom` against the T3/T4 UI tests | 4/4 passed (survives at the default size) | only T5 catches it |
| 2026-11-09 | T6.1 probe: `UUID()` version on macOS and in the iPhone 17 test host | version 4 in 100 000 of 100 000, also for the store's id | fact 41, R-50 |
| 2026-11-09 | T6.1 green: all unit tests x20 | 39 tests each 20/20, no compiler warnings (`artifacts/T6.1-green.log`) | mutants |
| 2026-11-09 | T6.1: 12 mutants | 11 failed on their rules; `add-reuse-id` did not compile: the agent's batch script built the line with a zsh `${…/…/…}` substitution, where `()` in the pattern is a glob group, so the mutant became `UUID()()` (agent mistake) | re-run with the line written out: failed on its rule; the invalid log was replaced by the re-run (the invalid run proved nothing) |
| 2026-11-09 | T6.2 probes (scratchpad copy): present/dismiss in a window, bar button id, `numberPad` typing, the 11th row after `scrollToRow` | facts 42-45; dismissal is not visible synchronously | R-56 fallback: cancel closing checked by a UI test |
| 2026-11-09 | T6.2 red: `-parallel-testing-enabled NO -only-testing:StudentDirectoryTests -only-testing:StudentDirectoryUITests/AddStudentUITests` | `TEST FAILED` as expected: 11 T6.2 tests fail on their rules; 41 pass (39 older + 2 that a stub cannot break), 99 s (`artifacts/T6.2-red.log`) | implement T6.2 |
| 2026-11-09 | T6.2 green: all unit tests x20; T6.2 UI tests x5 | 49 tests each 20/20; 3 tests each 5/5, no compiler warnings (`artifacts/T6.2-green.log`) | mutants |
| 2026-11-09 | T6.2: 16 mutants (13 unit, 3 UI) | all failed on their rule messages | none |
| 2026-11-09 | T6.3: tests and implementation first run together in a scratchpad copy (R-57 speed-up) | green with the implementation; XCUI swipe, alert and cursor behaviour as expected | fact 46; tests copied to the repo with neutral stubs |
| 2026-11-09 | T6.3 red: `-parallel-testing-enabled NO -only-testing:StudentDirectoryTests -only-testing:EditStudentUITests -only-testing:DeleteStudentUITests` | first run: 13 failed, but one `XCTUnwrap` had no rule message; the agent's first fix did not apply (wrong pattern) and a run was wasted; after the fix: 13 fail on their rules, 50 pass (`artifacts/T6.3-red.log`) | implement T6.3 |
| 2026-11-09 | T6.3 green: all unit tests x20; new UI tests x5 | 60 tests each 20/20; 3 tests each 5/5 (`artifacts/T6.3-green.log`) | mutants |
| 2026-11-09 | T6.3: 18 mutants (14 unit, 4 UI) | all failed on their rule messages | none |
| 2026-11-09 | PLAN review during T6.3 | R-52…R-56 were used in T6.2 but missing from the decisions table (agent mistake, found by the agent) | rows added |
| 2026-11-09 | T7 static checks: `git ls-remote` of the template, repository visibility, test names, `fatalError`/`try!`/`as!`, tracked junk, secrets, `TODO` | template `938bf69` = R-16; public; 60 unit + 15 UI test methods, no duplicates; none; none; none; only the Final review lines | none |
| 2026-11-09 | T7: exact README command on `46e091b` | `TEST SUCCEEDED`, 75/75, 225 s (`artifacts/final-xcodebuild-test.log`) | none |
| 2026-11-09 | T7: all UI tests x5 (`-parallel-testing-enabled NO`) | 15 tests each 5/5, 719 s (`artifacts/T7-ui5.log`) | none |
| 2026-11-09 | T7 log headers | the agent first wrote 72 tests / 12 UI tests as the expectation (miscounted the UI tests: 13 student, not 10); both headers regenerated from the same runs before the commit | none |
