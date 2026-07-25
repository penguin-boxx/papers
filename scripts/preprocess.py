#!/usr/bin/env python3
"""Preprocess the extracted LaTeX body so pandoc digests it cleanly.
Usage: python3 preprocess.py body-fragment.tex  (edits in place)

- rewrites the 1 TikZ figure -> \\includegraphics{lifecycle.png} + bilingual caption div
- rewrites the 3 booktabs tables -> bilingual caption div + bare tabular
- \\captionisp{RU}{EN} numbering baked in (Рис./Табл. + Fig./Table)
- << >> -> « »   (verified: never inside code)
- bakes "N. " into each \\section title (headings are un-numbered isp paras in Word)
"""
import re, sys

path = sys.argv[1]
t = open(path, encoding='utf-8').read()

def brace(s, i):
    assert s[i] == '{'; d = 0; j = i
    while j < len(s):
        c = s[j]
        if c == '{': d += 1
        elif c == '}':
            d -= 1
            if d == 0: return s[i+1:j], j+1
        j += 1
    raise ValueError('unbalanced brace')

def captionisp(block):
    k = block.index('\\captionisp'); i = block.index('{', k)
    a, j = brace(block, i); i2 = block.index('{', j); b, _ = brace(block, i2)
    norm = lambda x: re.sub(r'\s+', ' ', x.replace('%', ' ')).strip()
    return norm(a), norm(b)

# Cross-reference numbers are derived from float order here (not hand-mapped):
# each figure/table \label is recorded as it is numbered, then \ref to it resolved.
refmap = {}
def label_of(block):
    m = re.search(r'\\label\{([^}]+)\}', block)
    return m.group(1) if m else None

# --- figure ---
fc = [0]
def figsub(m):
    fc[0] += 1; n = fc[0]; block = m.group(0)
    a, b = captionisp(block)
    lab = label_of(block)
    if lab: refmap[lab] = str(n)
    return (f'\\includegraphics[width=12cm]{{lifecycle.png}}\n\n'
            f'\\begin{{ispcap}}\nРис. {n}. ' + a + '\\\\\n' + f'Fig. {n}. ' + b + '\n\\end{ispcap}')
t, nf = re.subn(r'\\begin\{figure\}.*?\\end\{figure\}', figsub, t, flags=re.S)

# --- tables ---
tabular = re.compile(r'\\begin\{tabular\}.*?\\end\{tabular\}', re.S)
cnt = [0]
def tabsub(m):
    cnt[0] += 1; n = cnt[0]; block = m.group(0)
    a, b = captionisp(block); tb = tabular.search(block).group(0)
    lab = label_of(block)
    if lab: refmap[lab] = str(n)
    return ('\\begin{ispcapt}\n' + f'Табл. {n}. ' + a + '\\\\\n' + f'Table {n}. ' + b
            + '\n\\end{ispcapt}\n\n' + tb)
t, nt = re.subn(r'\\begin\{table\}.*?\\end\{table\}', tabsub, t, flags=re.S)

# resolve \ref to figures/tables -> their number (section refs are left for pandoc)
for lab, num in refmap.items():
    t = t.replace('\\ref{' + lab + '}', num)

# --- dedent lstlisting blocks (source indents them; pandoc strips only line 1) ---
def dedent_lst(m):
    head, code = m.group(1), m.group(2)
    lines = code.split('\n')
    indents = [len(l) - len(l.lstrip(' ')) for l in lines if l.strip()]
    k = min(indents) if indents else 0
    return head + '\n'.join(l[k:] if len(l) >= k else l for l in lines)
t = re.sub(r'(\\begin\{lstlisting\}(?:\[[^\]]*\])?\n)(.*?)(?=\n\\end\{lstlisting\})',
           dedent_lst, t, flags=re.S)

# --- trivial inline math -> plain formatting (OMML math objects render with
# missing-glyph boxes in some Word/LO math-font fallbacks; italic/superscript
# text is what the journal's own typesetting uses anyway) ---
t = re.sub(r'\$\^\\epsilon\$', r'\\textsuperscript{ε}', t)
t = re.sub(r'\$([A-Za-z]+)\$', r'\\emph{\1}', t)

# --- guillemets ---
t = t.replace('<<', '«').replace('>>', '»')

# --- section numbering ---
sc = [0]
def sec(m): sc[0] += 1; return '\\section{%d. ' % sc[0]
t = re.sub(r'\\section\{', sec, t)

open(path, 'w', encoding='utf-8').write(t)
print(f"  figures={nf} tables={nt} sections={sc[0]} "
      f"(leftover <<>>={t.count('<<')+t.count('>>')} captionisp={t.count('captionisp')})")
