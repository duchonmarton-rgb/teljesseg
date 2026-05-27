# Contributing

Thank you for helping with these notes. The project is collaborative, so the main rule is that every mathematical and editorial change should be easy to identify, review, and merge.

## Repository Layout

- `tex/main.tex` is the main LaTeX entry point.
- `tex/preamble.tex` contains shared packages, theorem environments, macros, and notation.
- `tex/sections/` is for organized sections of the final document.
- `tex/figures/` is for source files for figures and diagrams.
- `tex/bibliography.bib` is the shared bibliography.
- `tex/incoming/` is for contributed or imported TeX drafts that have not yet been merged into the main document.
- `lean/` is reserved for the Lean 4 formalization track.
- `notes/scratch/` is for informal notes, comparisons, and temporary outlines.

Create missing directories when your contribution needs them.

## Contributing TeX

When adding or revising mathematical text:

1. Use the notation already fixed in `tex/preamble.tex` when possible.
2. Put reusable macros in `tex/preamble.tex`, not in individual sections.
3. Keep source references visible when importing or paraphrasing existing material.
4. Mark unresolved mathematical issues explicitly with a short note and your name or initials.
5. Avoid duplicating a proof or definition that already exists elsewhere; if duplication is intentional, explain the overlap.

If you are uploading work that was previously shared by email or chat, place it in `tex/incoming/` first. Use a filename containing your name or monogram and the topic, for example:

```text
tex/incoming/john_doe_repartitions.tex
tex/incoming/ac_divisors.tex
```

After review, the material can be merged into `tex/main.tex` or a file under `tex/sections/`.

## Contributing Lean

The Lean development is planned to follow the mathematical structure of the TeX notes while respecting `mathlib` conventions.

- Work inside `lean/`.
- Keep `lean/lean-toolchain` and `lean/lakefile.lean` as the source of truth for Lean and Lake.
- Prefer small files and namespaces that correspond to mathematical topics.
- State TeX definitions in a Lean-friendly form before attempting long proofs.
- If a theorem is not yet formalized, leave a concise comment explaining the intended statement and any missing prerequisites.

## Nix Workflow

Use the flake development shell so everyone gets the same TeX, Lean, and editor tooling:

```bash
nix develop
```

Useful commands inside the shell:

```bash
latexmk -pdf -lualatex tex/main.tex
watch-latex
nix build .#tex
cd lean && lake build
```

`watch-latex` watches `tex/main.tex` by default. Pass another entry point if needed:

```bash
watch-latex tex/incoming/john_doe_repartitions.tex
```

## Commit And Pull Request Notes

In each commit or pull request, briefly say:

- what you contributed;
- which files you modified;
- whether the change is new text, a correction, a refactor, or formalization work;
- whether it overlaps with existing material;
- whether a TODO, gap, or open question remains.

Good commit messages:

```text
Add TeX notes on repartition definitions
Merge overlapping divisor notation sections
Fix proof of the degree formula
Start Lean statements for divisors on curves
```

Avoid vague messages:

```text
Update
Fix
Stuff
More changes
```

## Checks Before Submitting

Run the narrowest useful checks for your change:

```bash
nix flake check
nix build .#tex
cd lean && lake build
```

If a check is not relevant or currently cannot pass because the corresponding source is still a stub, mention that in the commit or pull request notes.
