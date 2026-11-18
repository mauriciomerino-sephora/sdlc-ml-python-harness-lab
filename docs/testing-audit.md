# Testing quality audit and local gates

Date: 2026-11-16

## Scope and method

The initial inventory covered all 145 application test modules: 2,486 named test
functions before the subsequent audit changes. Parametrization expands these
into more collected cases. Reviewers inspected module structure, assertions,
fixtures, and test boundaries across that inventory, then deeply reviewed and
probed selected risks. This is a complete static inventory with selective
behavioral evidence, not exhaustive proof of every test's effectiveness.

Benchmark graders are a separate instrument: seven pytest modules, three Godot
grader scripts and their harvesters, plus inline command checks. Their contracts
were inventoried separately. They require representative agent workspaces or game
artifacts for calibration and were not executed as live benchmarks in this work.

The new governed `sensible_testing` skill formalizes the review: name the defect
a test detects, use an independent oracle, and probe high-risk assumptions with
deliberate isolated defects. The existing test-first skill is unchanged. The
end-to-end skill and tester agent reuse the new quality guidance.

## Improvements completed

| Risk | Previous gap | Improvement |
|---|---|---|
| Local test command | Pytest errors became success; tests implicitly ran autofix | Propagate failures and keep formatting explicit |
| Git gates | No mandatory full test gate or installed push stage | Run full CI at commit and push; preserve authorship and existing hooks |
| Hook isolation | Git repository/index overrides could redirect nested test repositories | Clear Git-local variables before running the gate and test contaminated contexts |
| Push behavior | Formatting hooks rewrote existing files during a new branch push | Confine source-editing hooks to commits; exercise stage routing through the real runner |
| Test selection | Unit target ran everything; no integration target | Explicit marker-based unit/integration targets; full gate still runs both |
| Provenance | A file hash was compared only with itself | Assert a known digest and sensitivity to changed file bytes |
| Skill projection | A truncated file beginning with YAML sentinels passed | Compare projected bytes with the source payload |
| Public reports | A field-presence assertion did not prove aggregate allowlisting | Require exactly the public fields and exclude synthetic private content |
| SWE-bench | Resolution test never exercised a failed or missing regression result | Exercise failed/missing required results and assert counts and verdict |
| Atomic persistence | Successful final output did not prove failure behavior | Inject replacement failures; require previous bytes and temporary-file cleanup |
| Local results | Equal durations hid an upper-middle-value calculation | Unequal-duration regression exposes the defect; use the true median |

For example, two local runs taking 20 and 40 minutes previously reported a
40-minute median. The strengthened test expects 30 and fails on the old code.
The correction changes the reported statistic, not historical run artifacts.

Existing tests survived isolated defects that returned constant file hashes,
truncated copied skill bodies, removed public-metric allowlisting, ignored
regression outcomes, or replaced atomic manifest writing with a direct write.
The strengthened assertions target those defects rather than increasing counts
for their own sake. No regression scenario was dropped: the review did not
establish that any candidate lacked distinct protection. Weak assertions were replaced or
extended while preserving existing guarantees.

The revised tests were subsequently run against seven deliberate defects in an
isolated source copy: constant hashing, truncated skill copy, missing metric
allowlisting, ignored regression results, upper-middle median selection, missing
temporary-file cleanup, and non-atomic manifest replacement. All seven were
detected; the unmodified focused baseline passed. Mutations never touched the
shared working tree and are not included in the contribution.

## Running the suites

- `make test-unit`: tests without the `integration` marker.
- `make test-integration`: marked deterministic integration tests.
- `make test`: both selections with coverage; pytest errors fail the command.
- `make ci`: the complete quality, tests, skill-sync, and frontend gates.
- `make setup-hooks`: install the local commit, commit-message, and push hooks.

Integration labels identify explicitly reviewed boundaries, including the real
hook runner and the skills-sync CLI/filesystem flow. Unmarked tests remain in
the default unit selection; the labels are not a claim that every other test is
pure or that every integration scenario is covered. No marker filters apply to
the full gate. See [development hooks](development-hooks.md) for prerequisites,
local autofix behavior, and limitations of opt-in Git hooks.

## Verification

On the completed change, `make test-unit` passed 2,856 selected cases and
`make test-integration` passed 40. The complete `make ci` passed all 2,896 cases,
formatting, lint, security, type checking, generated-skill synchronization, and
the frontend type check and production build. Existing deprecation warnings and
the frontend bundle-size warning remain; neither is a failed check.

### Push-stage regression (2026-11-18)

A subsequent real push exposed source-editing hooks running at the push stage,
which changed existing content and broke integrity checks. Those edits were
restored. Ten regression cases reproduce the routing problem and verify that
all five source-editing hooks remain active at commit time and inactive at push
time. The integration selection now passes 50 cases, including those ten stage
regressions. The complete gate remains mandatory at commit and push.

## Remaining work

Keep follow-up contributions separate from this testing change:

- Extend explicit integration classification as additional boundaries are reviewed.
- Add dedicated lab-frontend behavior tests; type checking and bundling alone do
  not exercise user interaction.
- Strengthen the proposal-evidence checksum oracle beyond its current prefix
  assertion and add a real Node subprocess case. The existing Python/shell
  executor test was renamed to reflect what it actually runs.
- Improve HTTP-boundary coverage and assess live database, broker, and container
  semantics without substituting mock success for real compatibility evidence.
- Calibrate statistical coverage/power and benchmark graders against independent
  truths and reference artifacts; do not infer those properties from a green suite.
- Establish a repeatable resource-budgeted local-model pilot before expanding
  runtime adapters, realistic engineering/ML tasks, or interactive game benchmarks.

Live Docker/model-server checks, paid inference, frontend visual judgement, and
game-reference calibration remain separate operational validation. Local Git
hooks can be bypassed or removed; server-side required CI remains necessary.
