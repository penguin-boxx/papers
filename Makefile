# Makefile — build goals for the papers in this repo.
# One goal per article; every goal is meant to run from the repo root.
#
# The journal class/style files live in styles/ now, so point (pdf|xe)latex and
# bibtex at that directory (trailing ":" keeps the standard texmf trees on the path).
export TEXINPUTS := .:styles:$(TEXINPUTS)
export BSTINPUTS := .:styles:$(BSTINPUTS)

.PHONY: all fvar-ru fvar-en fvar-ru-docx escape-proofs escape overview opo clean

all: fvar-ru fvar-en escape-proofs escape overview opo

## effect-systems-free-variables — Труды ИСП РАН (RU). latexmk drives xelatex + biber
## and reruns until references/citations resolve (pdflatex can't do the Cyrillic bib heading).
fvar-ru:
	latexmk -pdf -xelatex effect-systems-free-variables.tex

## English translation of the free-variables paper.
fvar-en:
	latexmk -pdf -xelatex effect-systems-free-variables-en.tex

## Word (.docx) version of the RU paper — pandoc pipeline (scripts/ + styles/ + figures/).
fvar-ru-docx:
	bash scripts/make-docx.sh

## escape-analysis-proofs — Информатика и автоматизация / SPIIRAS. gen_refs.py rebuilds the
## reference lists from bib.bib in citation order; no bibtex run is involved.
escape-proofs:
	python3 scripts/gen_refs.py
	latexmk -pdf escape-analysis-proofs.tex

## escape-analysis-ivannikov — Ivannikov conference (article + bibtex, plain style).
escape:
	latexmk -pdf escape-analysis-ivannikov.tex

## effect-systems-overview-ivannikov — IEEE. minted requires -shell-escape.
overview:
	latexmk -pdf -pdflatex="pdflatex -shell-escape -interaction=nonstopmode" effect-systems-overview-ivannikov.tex

## one-plus-one — "Effect System as a Synergy" (acmart + bibtex).
opo:
	latexmk -pdf one-plus-one.tex

## Remove regenerable build artifacts (LaTeX aux/PDF via latexmk, minted caches, and the
## gen_refs.py-generated escape-analysis-proofs reference lists).
clean:
	-latexmk -C
	$(RM) -r _minted*
	$(RM) *.bbl
	$(RM) escape-analysis-proofs-refs-eng.tex escape-analysis-proofs-refs-rus.tex
