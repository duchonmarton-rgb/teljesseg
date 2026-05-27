# Repartitions and the classical Riemann-Roch-theorem

This repository contains collaboratively maintained TeX notes for the Riemann-Roch theorem, with a planned Lean 4 formalization track.

## Current goals

1. Collecting the so far written TeX files.
2. Mark overlaps in the source.
3. Create a unique and solid LaTeX document.
4. Identifying missing parts from the proof and theory.
5. Make notation, definitions, propositions and proofs consistent and unique.
6. Prepare Lean 4 formalization.

## Structure

```text
.
├── README.md
├── flake.nix
├── flake.lock
├── tex/
│   ├── main.tex
│   ├── preamble.tex
│   ├── sections/
│   ├── figures/
│   └── bibliography.bib
├── lean/
│   ├── lakefile.lean
│   ├── lean-toolchain
│   └── Repartitions/
└── notes/
    └── scratch/
```

The `tex/` directory contains `LaTeX` sources. The `tex/main.tex` should be
the main document, `tex/preamble.tex` should be the place forcommon macros, theorem environments and notations.

The `tex/sections` directory should contain the larger logical parts,
like definitions, preparatory lemmas, repartitions, main steps of the RR proof
and examples.

The `lean/` directory is the place for later Lean 4 formalization. The
structure of Lean files should mimic the structure of the mathematical
flow of the latex document, but should adhere to `mathlib` conventions.

## Contributing

Every contribution should be identifiable. This is especially important
if you upload work sent previously in main, or when you modify somebody
elses work.

In the case of a commit or pull request, please write shortly:
- what you contributed;
- which file you modified;
- contributed new features, corrections, or refactored;
- whether there is an overlap with another file;
- whether a TODO or an open question remained.

Examples for good commit messages:

```text
Add TeX notes on repartition definitions
Merge overlapping divisor notation sections
Fix proof of the degree formula
Mark overlap between local and global Riemann-Roch arguments
```

Avoid commit messages like:

```text
Update
Fix
Stuff
More changes
```

## Uploading work

If you have previously sent work in mail, upload into the repo to
the following place: `tex/incoming`

The name of the file should contain your name or monogram, and the topic, e.g.

```text
tex/incoming/john_doe_repartitions.tex
tex/incoming/alice_carpenter_divisors.tex
```

## Building the TeX notes

With Nix flakes enabled:

```bash
nix develop
latexmk -pdf tex/main.tex

nix build .#all
nix build .#filename
