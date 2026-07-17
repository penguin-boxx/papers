#!/usr/bin/env python3
# Derive an explicit `doi` field from `url = {https://doi.org/...}` for entries
# that lack one, so the ISP RAS CSL can print "DOI: 10.xxxx" instead of a URL.
import re, sys

src, dst = sys.argv[1], sys.argv[2]
text = open(src, encoding='utf-8').read()
parts = re.split(r'(?=@\w+\s*\{)', text)
out = []
for p in parts:
    if p.strip().startswith('@') and not re.search(r'(?im)^\s*doi\s*=', p):
        m = re.search(r'(?i)url\s*=\s*[{"]\s*https?://(?:dx\.)?doi\.org/([^}"\s]+)', p)
        if m:
            doi = m.group(1).replace('\\_', '_')
            p = re.sub(r'(@\w+\s*\{[^,]+,)', r'\1\n    doi = {' + doi + '},', p, count=1)
    out.append(p)
open(dst, 'w', encoding='utf-8').write(''.join(out))
