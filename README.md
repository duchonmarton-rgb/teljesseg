# Repartitions and the Classical Riemann-Roch Theorem

This repository contains collaboratively maintained TeX notes for the Riemann-Roch theorem, with a planned Lean 4 formalization track.

## Current Goals

1. Collect the TeX files written so far.
2. Mark overlaps between existing sources.
3. Build a single coherent LaTeX document.
4. Identify missing parts of the proof and surrounding theory.
5. Make notation, definitions, propositions, and proofs consistent.
6. Prepare a Lean 4 formalization.

## Structure

```text
.
├── README.md
├── CONTRIBUTING.md
├── flake.nix
├── flake.lock
├── tex/
│   ├── main.tex
│   ├── preamble.tex
│   ├── sections/
│   ├── figures/
│   ├── incoming/
│   └── bibliography.bib
├── lean/
│   ├── lakefile.lean
│   ├── lean-toolchain
│   └── Repartitions/
└── notes/
    └── scratch/
```

The `tex/` directory contains the LaTeX sources. The main entry point is `tex/main.tex`. Shared macros, theorem environments, packages, and notation belong in `tex/preamble.tex`.

The `tex/sections/` directory is for the larger logical parts of the notes: definitions, preparatory lemmas, repartitions, the main steps of the Riemann-Roch proof, and examples. The `tex/incoming/` directory is for contributed or imported drafts before they are merged into the main document.

The `lean/` directory is for the planned Lean 4 formalization. Its structure should follow the mathematical flow of the TeX document while still using `mathlib` conventions.

## Nix Workflow

This repository uses a Nix flake for reproducible TeX and Lean tooling. With flakes enabled, enter the development shell with:

```bash
nix develop
```

The shell provides the TeX Live environment used by the notes, the project fonts, `latexmk`, `texlab`, `chktex`, Lean 4 with Lake, and useful tools such as `ripgrep`, `fd`, `nil`, and `alejandra`.

Build the main PDF through Nix:

```bash
nix build .#tex
```

The generated PDF is available at:

```text
result/tex.pdf
```

For local editing inside `nix develop`, compile directly with:

```bash
latexmk -pdf -lualatex tex/main.tex
```

To continuously rebuild while editing, run:

```bash
watch-latex
```

`watch-latex` watches `tex/main.tex` by default. You can pass another TeX entry point, for example:

```bash
watch-latex tex/incoming/marton_a_varga_residue_theorem.tex
```

Check the flake outputs with:

```bash
nix flake check
```

## Lean 4

The development shell includes Lean 4 and Lake:

```bash
nix develop
cd lean
lake build
```

The Lean directory is currently the place for future formalization work. Keep Lean files under `lean/`, and use `lean/lean-toolchain` and `lean/lakefile.lean` as the source of truth for the Lean project.

## Contributing

See `CONTRIBUTING.md` for the contribution workflow, naming conventions for incoming drafts, commit-message guidance, and recommended checks.
