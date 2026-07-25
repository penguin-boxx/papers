#!/usr/bin/env bash
# Regenerate effect-systems-free-variables.docx (Труды ИСП РАН layout) from the LaTeX source.
# Run from anywhere: the script cd's to the repo root (its own parent directory).
#
# Front matter (title/authors/abstract/keywords/citation/bios) and the running heads
# are generated FROM the .tex by scripts/frontmatter.py — never hand-edit them.
#
# Hand-maintained sources (edit only when the template/style/logic changes):
#   styles/reference.docx  — ISP RAS page geometry + isp styles + pandoc-target overrides
#   styles/refs.md         — the "Список литературы / References" heading + citeproc anchor
#   styles/ispras.csl      — ISP RAS house reference style (surname-first, [n]., DOI:)
#   scripts/filters.lua    — headings->isp style, caption divs, cross-ref numbers, centred image
#   scripts/frontmatter.py — front matter + running heads from the .tex macros
#   scripts/preprocess.py scripts/mkbib.py — body preprocessor / DOI-field deriver
#   figures/lifecycle-fig.tex — standalone TikZ source for the one figure
#   figures/cc-by.png      — CC-BY badge placed by the generated front-ru.md
#
# Generated into build/ each run: front-ru.md front-en.md bios.md reference.docx
# (header-patched), plus body/refs intermediates and the final .docx. The result is
# also copied to the repo root as effect-systems-free-variables.docx.
set -euo pipefail
cd "$(dirname "$0")/.."            # repo root
export TEXINPUTS=.:styles:         # so the figure build finds anything in styles/

SRC=effect-systems-free-variables.tex
BUILD=build
CSL=styles/ispras.csl
mkdir -p "$BUILD"

echo "[1/4] render figure (tikzpicture extracted from the .tex)"
python3 scripts/mkfigure.py "$SRC" figures/lifecycle-fig.tex "$BUILD/lifecycle-fig.tex"
xelatex -interaction=nonstopmode -halt-on-error -output-directory="$BUILD" "$BUILD/lifecycle-fig.tex" >/dev/null
pdftoppm -png -r 600 "$BUILD/lifecycle-fig.pdf" "$BUILD/lifecycle" >/dev/null
mv -f "$BUILD/lifecycle-1.png" "$BUILD/lifecycle.png"

echo "[2/4] extract + preprocess body"
sed -n '/\\maketitleru/,/\\maketitleen/p' "$SRC" | sed '1d;$d' > "$BUILD/body-fragment.tex"
python3 scripts/preprocess.py "$BUILD/body-fragment.tex"

echo "[3/4] latex body -> markdown"
pandoc "$BUILD/body-fragment.tex" -f latex -t markdown-raw_tex --wrap=preserve -o "$BUILD/body.md"

echo "[4/4] assemble docx"
python3 scripts/frontmatter.py "$SRC" "$BUILD"   # front-*.md, bios.md, reference.docx from the .tex
python3 scripts/mkbib.py bib.bib "$BUILD/ispras-refs.bib"
pandoc "$BUILD/front-ru.md" "$BUILD/front-en.md" "$BUILD/body.md" styles/refs.md "$BUILD/bios.md" \
  -f markdown+superscript-implicit_figures -t docx \
  --citeproc --bibliography="$BUILD/ispras-refs.bib" --csl="$CSL" \
  --lua-filter=scripts/filters.lua --reference-doc="$BUILD/reference.docx" \
  --resource-path="$BUILD:figures:." \
  -o "$BUILD/effect-systems-free-variables.docx"
cp -f "$BUILD/effect-systems-free-variables.docx" effect-systems-free-variables.docx
echo "done -> effect-systems-free-variables.docx"
