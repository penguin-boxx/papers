#!/usr/bin/env bash
# Regenerate effect-systems-free-variables.docx (Труды ИСП РАН layout) from the LaTeX source.
# Run from anywhere: the script cd's to the repo root (its own parent directory).
#
# Hand-maintained sources (edit only when the template/front matter changes):
#   styles/reference.docx  — ISP RAS page geometry + isp styles + pandoc-target overrides
#   styles/front-ru.md styles/front-en.md styles/refs.md styles/bios.md — front matter / refs / bios
#   scripts/filters.lua    — headings->isp style, caption divs, cross-ref numbers, centred image
#   scripts/preprocess.py scripts/mkbib.py — body preprocessor / DOI-field deriver
#   styles/ispras.csl      — ISP RAS house reference style (surname-first, [n]., DOI:)
#   figures/lifecycle-fig.tex — standalone TikZ source for the one figure
#   figures/cc-by.png      — CC-BY badge referenced by styles/front-ru.md
#
# All intermediates and the final .docx are written under build/ (git-ignored); the
# result is also copied to the repo root as effect-systems-free-variables.docx.
set -euo pipefail
cd "$(dirname "$0")/.."            # repo root
export TEXINPUTS=.:styles:         # so the figure build finds anything in styles/

SRC=effect-systems-free-variables.tex
BUILD=build
CSL=styles/ispras.csl
mkdir -p "$BUILD"

echo "[1/4] render figure"
xelatex -interaction=nonstopmode -halt-on-error -output-directory="$BUILD" figures/lifecycle-fig.tex >/dev/null
pdftoppm -png -r 600 "$BUILD/lifecycle-fig.pdf" "$BUILD/lifecycle" >/dev/null
mv -f "$BUILD/lifecycle-1.png" "$BUILD/lifecycle.png"

echo "[2/4] extract + preprocess body"
sed -n '/\\maketitleru/,/\\maketitleen/p' "$SRC" | sed '1d;$d' > "$BUILD/body-fragment.tex"
python3 scripts/preprocess.py "$BUILD/body-fragment.tex"

echo "[3/4] latex body -> markdown"
pandoc "$BUILD/body-fragment.tex" -f latex -t markdown-raw_tex --wrap=preserve -o "$BUILD/body.md"

echo "[4/4] assemble docx"
python3 scripts/mkbib.py bib.bib "$BUILD/ispras-refs.bib"
pandoc styles/front-ru.md styles/front-en.md "$BUILD/body.md" styles/refs.md styles/bios.md \
  -f markdown+superscript-implicit_figures -t docx \
  --citeproc --bibliography="$BUILD/ispras-refs.bib" --csl="$CSL" \
  --lua-filter=scripts/filters.lua --reference-doc=styles/reference.docx \
  --resource-path="$BUILD:figures:." \
  -o "$BUILD/effect-systems-free-variables.docx"
cp -f "$BUILD/effect-systems-free-variables.docx" effect-systems-free-variables.docx
echo "done -> effect-systems-free-variables.docx"
