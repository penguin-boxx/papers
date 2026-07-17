# Papers

LaTeX sources for a set of related papers on effect systems and escape analysis.
Each paper has a dedicated `make` goal and an IntelliJ IDEA run configuration.

## Papers

| Paper | Source | Venue / class | `make` goal | IDEA run config |
|---|---|---|---|---|
| Effect systems & free variables (RU) | `effect-systems-free-variables.tex` | Труды ИСП РАН · `ProcISPRAS` | `fvar-ru` | *Effect Systems Free Variables* |
| Effect systems & free variables (EN) | `effect-systems-free-variables-en.tex` | `article` | `fvar-en` | *Effect Systems Free Variables EN* |
| …Word (.docx) version of the RU paper | (pandoc pipeline) | Труды ИСП РАН | `fvar-ru-docx` | — |
| Escape-analysis mechanization | `escape-analysis-proofs.tex` | Информатика и автоматизация · `SPIIRAS_Proceedings` | `escape-proofs` | *Proofs Escape Analysis* |
| Escape analysis (Ivannikov) | `escape-analysis-ivannikov.tex` | `article` | `escape` | *Escape Analysis* |
| Effect systems overview (Ivannikov) | `effect-systems-overview-ivannikov.tex` | IEEE · `IEEEtran` | `overview` | *Effect Systems Overview* |
| Effect system as a synergy | `one-plus-one.tex` | ACM · `acmart` | `opo` | *Effect System as a Synergy* |

The shared bibliography for every paper is `bib.bib`.

## Repository layout

```
.
├─ *.tex              paper sources (+ escape-analysis-proofs-refs-{eng,rus}.tex, generated & \input)
├─ bib.bib            shared bibliography
├─ Makefile           one build goal per paper
├─ scripts/           build helpers: gen_refs.py, make-docx.sh, mkbib.py, preprocess.py, filters.lua
├─ styles/            journal classes/bst + docx styles + front matter:
│                       ProcISPRAS.cls, SPIIRAS_Proceedings.cls, IEEEtran.cls, IEEEtran.bst,
│                       ACM-Reference-Format.bst, ispras.csl, reference.docx,
│                       front-ru.md, front-en.md, refs.md, bios.md
├─ figures/           figure sources: lifecycle-fig.tex, cc-by.png/.svg
├─ build/             build artifacts only (git-ignored)
└─ .idea/             IntelliJ project + run configurations
```

`ProcISPRAS.cls` and `SPIIRAS_Proceedings.cls` are **not** part of TeX Live, so they are
bundled in `styles/`. `acmart`, `IEEEtran`, and `article` are provided by TeX Live. The
Makefile and the IDEA run configs put `styles/` on `TEXINPUTS`/`BSTINPUTS` so the compilers
find the bundled classes.

## System-wide dependencies

These tools must be installed on the system (they are **not** vendored in the repo). Versions
in parentheses are the known-good baseline this repo is developed against.

| Tool | Used for | Baseline |
|---|---|---|
| **TeX Live** (`xelatex`, `pdflatex`, `bibtex`, `kpsewhich`) | compiling every paper | TeX Live 2026 |
| **latexmk** | drives the LaTeX/biber/bibtex passes for all `make` goals | 4.87 |
| **Biber** | biblatex backend for the free-variables papers (`fvar-ru`, `fvar-en`) | 2.21 |
| **BibTeX** | bibliography for `escape`, `overview`, `opo` | 0.99e |
| **Python 3** | `gen_refs.py`, and the docx pipeline (`preprocess.py`, `mkbib.py`) | 3.14 |
| **Pygments** (`pygmentize`) | `minted` code highlighting in `overview` (needs `-shell-escape`) | 2.20 |
| **Pandoc** | LaTeX → Word conversion in `fvar-ru-docx` | 3.6 |
| **Poppler** (`pdftoppm`) | rasterizing the TikZ figure for the docx build | 26.06 |

Required TeX Live packages/classes: `biblatex`, `minted`, `tikz`/`pgf`, `booktabs`,
`fontspec`, `csquotes`, `listings`, `amsmath`, plus the classes `acmart` and `IEEEtran`.
Installing the full `texlive-meta` (or the `texlive-latexextra`, `texlive-xetex`,
`texlive-bibtexextra`, `texlive-pictures`, `texlive-fontsrecommended`, `texlive-binextra`
collections) covers all of them.

On Arch / Manjaro:

```sh
sudo pacman -S texlive-meta biber pandoc-cli poppler python-pygments
```

(`biber` and `latexmk` ship inside the `texlive-*` collections; `python`/`python3` is part of
the base system.)

## Building

Run any goal from the repository root:

```sh
make fvar-ru          # effect-systems-free-variables.tex  (xelatex + biber)
make fvar-en          # effect-systems-free-variables-en.tex
make fvar-ru-docx     # Word (.docx) version of the RU paper (pandoc)
make escape-proofs    # escape-analysis-proofs.tex  (regenerates refs, then pdflatex)
make escape           # escape-analysis-ivannikov.tex
make overview         # effect-systems-overview-ivannikov.tex  (pdflatex -shell-escape, minted)
make opo              # one-plus-one.tex
make all              # build every PDF
make clean            # remove build artifacts (latexmk -C + minted caches)
```

## IntelliJ IDEA

Each paper has a run configuration under `.idea/runConfigurations/` (TeXiFy plugin). The
LaTeX configs and their `bib …` bibliography counterparts export `TEXINPUTS`/`BSTINPUTS`
pointing at `styles/`, so compiling from the IDE resolves the bundled journal classes.

## The `.docx` pipeline

`make fvar-ru-docx` runs `scripts/make-docx.sh`, which renders the TikZ figure, slices and
preprocesses the RU paper body, and assembles a Word document via Pandoc using the ISP RAS
template (`styles/reference.docx`), CSL (`styles/ispras.csl`), front matter (`styles/front-*.md`,
`styles/refs.md`, `styles/bios.md`) and Lua filter (`scripts/filters.lua`). All intermediates
land in `build/`; the result is copied to `effect-systems-free-variables.docx`.
