# Contributing

How work is filed and progressed here: the issue tracker's labels, the
`Priority` board, and the few rules the tooling does not enforce. Build, release
and commit expectations live with the repository's other docs; this file is the
tracker's contract.

## Priority — exactly one per open issue

Integers rather than words: `1 2 3 4` sorts and orders a board by itself, where
`high`/`medium`/`low` invites a fifth level the moment something doesn't fit.

| Label | Description |
|---|---|
| `priority::1` | A live system is broken or exposed. Drop other work. |
| `priority::2` | Blocks work in flight, or a project-wide fact currently wrong in the record. |
| `priority::3` | Planned, with a date or a dependency. |
| `priority::4` | Hygiene — wording, links, tidying. Do it when nothing above is open. |

## State — at most one, and only when the priority does not already say it

| Label | Description |
|---|---|
| `state::ready` | Actionable now; nothing external is in the way. |
| `state::waiting` | Blocked on something outside this repository. The issue says what. |
| `state::owner-action` | Needs the owner specifically: a click, a credential, a decision. |

## The board

Name it **`Priority`** — it says what the columns order. Four label lists,
`priority::1` leftmost, plus the default `Open` and `Closed`.

Three facts that make the difference between a board that works and one that
lies:

- **Label lists fill themselves.** Applying `priority::2` puts the issue in that
  column; nothing is dragged in by hand. Never populate a list manually — it then
  has to be maintained twice and drifts from the labels.
- **An issue with no priority lands in `Open`**, the leftmost default list, which
  holds open issues matching no other list. So `Open` *is* the untriaged bucket: a
  forgotten label is visible rather than absent.
- **Dragging between label lists swaps the label** (the source is removed). That
  is the only place the tooling enforces one-priority-per-issue; editing labels in
  the sidebar does not.

## The rules that the tooling does not enforce

On the Free tier a `::` label is a **name**, not a scoped label: two priorities on
one issue are accepted without complaint, no label exists until someone creates
it, and nothing ages a priority out. Therefore:

- **Create the labels explicitly in each project** — they are not inherited, from
  a template or from anywhere else.
- **Apply exactly one priority**, and *change* it rather than adding a second.
- **A priority is a claim about now.** A `priority::1` that survives a week means
  the work or the label is wrong.
- **`state::waiting` names its blocker** in the issue. A waiting issue that
  doesn't say what it waits for is a stalled issue with a label on it.
- **The label says how urgent, never what "done" means.** Acceptance criteria stay
  in the issue body.
- **Closing with evidence beats re-labelling.** When the blocker clears, the state
  label comes off and the work happens.

## Do not invent a fifth level

If the four do not fit an issue, the issue is too big or too vague — split it,
rather than adding a fifth priority that means "urgent but not that urgent". A
scheme with five levels has no levels.

## What gets an issue

An issue holds what the tooling cannot: a decision a person has to make, work in
flight that a checkout has claimed, and the reason a change happened. It is not a
second checklist for the build — where a command or CI already reports a
condition, the issue points at it rather than restating it.

- **An issue is a pointer, not a spec.** Acceptance criteria name the command or
  artifact that decides, so an issue cannot be closed by assertion and a stale one
  cannot be mistaken for an instruction to redo approved work.
- **Assignment means work in flight.** An assigned issue is a claim on a
  checkout. Unassigned is the default, not a gap.
- **Priority, not stage.** The board orders by priority only; there are no
  milestones and no stage columns. A step that needs visibility gets an issue, not
  a column.
