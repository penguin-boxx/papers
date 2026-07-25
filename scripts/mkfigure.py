#!/usr/bin/env python3
"""Build the standalone figure by injecting the .tex's tikzpicture into the shell.

Keeps the one figure in sync with the paper: the tikzpicture is taken from the
LaTeX source, the preamble (fonts/libraries) from figures/lifecycle-fig.tex.

Usage: mkfigure.py <source.tex> <shell.tex> <out.tex>
"""
import re, sys

src, shell, out = sys.argv[1:4]
tex = open(src, encoding="utf-8").read()
pic = re.search(r"\\begin\{tikzpicture\}.*?\\end\{tikzpicture\}", tex, re.S).group(0)
shell_txt = open(shell, encoding="utf-8").read()
open(out, "w", encoding="utf-8").write(shell_txt.replace("%%TIKZPICTURE%%", pic))
