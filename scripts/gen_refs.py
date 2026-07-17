#!/usr/bin/env python3
r"""Generate journal-house-style (Informatics and Automation / SPIIRAS) reference
lists from bib.bib in citation order: an English `thebibliographyEng` with real
\bibitem labels, and a Russian-page `thebibliographyRus` with plain \item entries
(same order, so numbering agrees)."""
import re, sys

TEX = 'escape-analysis-proofs.tex'
BIB = 'bib.bib'

src = open(TEX).read()
order = []
for m in re.finditer(r'\\cite\{([^}]*)\}', src):
    for k in m.group(1).split(','):
        k = k.strip()
        if k and k not in order:
            order.append(k)

bib = open(BIB).read()

def parse_entry(key):
    m = re.search(r'@(\w+)\s*\{\s*' + re.escape(key) + r'\s*,', bib)
    if not m:
        sys.exit(f'missing bib entry: {key}')
    etype = m.group(1).lower()
    i = bib.index('{', m.start())
    depth, j = 1, i + 1
    while depth:
        if bib[j] == '{': depth += 1
        elif bib[j] == '}': depth -= 1
        j += 1
    body = bib[i+1:j-1]
    fields = {}
    for fm in re.finditer(r'(\w+)\s*=\s*', body):
        name = fm.group(1).lower()
        p = fm.end()
        if body[p] == '{':
            depth, q = 1, p + 1
            while depth:
                if body[q] == '{': depth += 1
                elif body[q] == '}': depth -= 1
                q += 1
            fields[name] = body[p+1:q-1]
        elif body[p] == '"':
            q = body.index('"', p+1)
            fields[name] = body[p+1:q]
    return etype, fields

def strip_outer_braces(s):
    # {POPLMark} -> POPLMark, but keep accent commands {\"o} intact
    out, i = [], 0
    while i < len(s):
        if s[i] == '{' and (i+1 >= len(s) or s[i+1] != '\\'):
            depth, j = 1, i + 1
            while depth:
                if s[j] == '{': depth += 1
                elif s[j] == '}': depth -= 1
                j += 1
            out.append(strip_outer_braces(s[i+1:j-1]))
            i = j
        else:
            out.append(s[i]); i += 1
    return ''.join(out)

def initials(given):
    parts = re.split(r'[\s.]+', given.strip())
    return ''.join(p[0] + '.' for p in parts if p and p[0].isalpha())

def fmt_author(a):
    a = a.strip()
    if ',' in a:
        last, given = a.split(',', 1)
    else:
        toks = a.split()
        last, given = toks[-1], ' '.join(toks[:-1])
    last = last.strip()
    ini = initials(given)
    return f'{last} {ini}'.strip(), f'{last}~{ini}'.strip()

def fmt_authors(field):
    auth = re.split(r'\s+and\s+', field.replace('\n', ' '))
    eng = ', '.join(fmt_author(a)[0] for a in auth)
    rus = ', '.join(fmt_author(a)[1] for a in auth)
    return eng, rus

def tail_article(f):
    bits = [f["year"]]
    if f.get('volume'): bits.append(f'vol. {f["volume"]}')
    if f.get('number'): bits.append(f'no. {f["number"]}')
    if f.get('pages'):  bits.append(f'pp. {f["pages"].replace("--","--")}')
    return '. '.join(bits) + '.'

eng_items, rus_items = [], []
for key in order:
    etype, f = parse_entry(key)
    title = strip_outer_braces(f['title'].replace('\n', ' ').strip())
    if etype == 'article':
        ea, ra = fmt_authors(f['author'])
        jr = strip_outer_braces(f['journal'].replace('\n', ' ').strip())
        tail = tail_article(f)
        eng = f'{ea} {title}. \\emph{{{jr}.}} {tail}'
        rus = f'\\emph{{{ra}}} {title} // {jr}. {tail}'
    elif etype == 'inproceedings':
        ea, ra = fmt_authors(f['author'])
        bk = strip_outer_braces(f['booktitle'].replace('\n', ' ').strip())
        bits = [f['year']]
        if f.get('pages'): bits.append(f'pp. {f["pages"]}')
        tail = '. '.join(bits) + '.'
        eng = f'{ea} {title}. {bk}. {tail}'
        rus = f'\\emph{{{ra}}} {title} // {bk}. {tail}'
    elif etype == 'misc':
        ea, ra = fmt_authors(f['author']) if f.get('author') else ('', '')
        # URL: prefer an explicit `url` field, else a \url{...} inside `howpublished`.
        url = f.get('url', '').strip()
        if not url and f.get('howpublished'):
            um = re.search(r'\\url\{([^}]*)\}', f['howpublished'])
            if um: url = um.group(1).strip()
        # access date: prefer `urldate = {YYYY-MM-DD}`, else `Accessed: YYYY-MM-DD` in `note`.
        dm = re.search(r'(\d{4})-(\d{2})-(\d{2})', f.get('urldate', ''))
        if not dm and f.get('note'):
            dm = re.search(r'Accessed:\s*(\d{4})-(\d{2})-(\d{2})', f['note'])
        acc = f' (accessed {dm.group(3)}.{dm.group(2)}.{dm.group(1)})' if dm else ''
        tail = f' Available at: \\url{{{url}}}{acc}.' if url else ''
        eng = f'{ea} {title}. {f["year"]}.{tail}'
        rus = f'\\emph{{{ra}}} {title} // {f["year"]}.{tail}'
    else:
        sys.exit(f'unhandled type {etype} for {key}')
    eng_items.append(f'\\bibitem{{{key}}}\n{eng}\n')
    rus_items.append(f'\\item\n{rus}\n')

with open('escape-analysis-proofs-refs-eng.tex', 'w') as fh:
    fh.write('% AUTO-GENERATED from bib.bib by gen_refs.py (citation order); edit the .bib, not this file.\n')
    fh.write('\\begin{thebibliographyEng}{99}\n\n')
    fh.write('\n'.join(eng_items))
    fh.write('\n\\end{thebibliographyEng}\n')

with open('escape-analysis-proofs-refs-rus.tex', 'w') as fh:
    fh.write('% AUTO-GENERATED from bib.bib by gen_refs.py (citation order); edit the .bib, not this file.\n')
    fh.write('\\begin{thebibliographyRus}{99}\n\n')
    fh.write('\n'.join(rus_items))
    fh.write('\n\\end{thebibliographyRus}\n')

print(f'{len(order)} entries written')
