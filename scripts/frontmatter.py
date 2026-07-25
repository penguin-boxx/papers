#!/usr/bin/env python3
"""Generate the docx front matter from the LaTeX source so it never goes stale.

Reads effect-systems-free-variables.tex, extracts the ISP RAS front-matter macros
(title/keywords/abstract/author/affiliation/doi/volume/pages/running titles/bios)
and emits, into the build dir:
    front-ru.md  front-en.md  bios.md      (pandoc custom-style divs)
    reference.docx                          (styles/reference.docx with the three
                                             running-head files re-filled)
Single-author paper; extend the name handling if co-authors are added.

Usage: frontmatter.py <source.tex> <build-dir>
"""
import re, sys, os, zipfile

SRC, BUILD = sys.argv[1], sys.argv[2]
REF = "styles/reference.docx"
tex = open(SRC, encoding="utf-8").read()


# ---- LaTeX field extraction -------------------------------------------------
def read_braces(s, i, n):
    """From index i, skip optional [..] args, read n balanced {..} groups."""
    out = []
    while len(out) < n:
        while i < len(s) and s[i] in " \n\t":
            i += 1
        if i < len(s) and s[i] == "[":                 # skip optional arg
            depth = 0
            while i < len(s):
                depth += (s[i] == "[") - (s[i] == "]")
                i += 1
                if depth == 0:
                    break
            continue
        assert s[i] == "{", f"expected {{ near {s[i-8:i+8]!r}"
        depth, start = 0, i
        while i < len(s):
            depth += (s[i] == "{") - (s[i] == "}")
            i += 1
            if depth == 0:
                out.append(s[start + 1:i - 1])
                break
    return out


def macro(name, n=1):
    m = re.search(r"\\" + name + r"\b", tex)
    if not m:
        raise ValueError("macro not found: " + name)
    return read_braces(tex, m.end(), n)


def tex2md(s):
    """Convert the inline LaTeX used in these fields to Markdown."""
    s = re.sub(r"%[^\n]*\n?", "", s)                   # strip LaTeX line comments
    s = s.replace("\\,", " ").replace("~", " ")
    s = re.sub(r"\\\\", " ", s)                        # line break -> space
    s = s.replace("<<", "«").replace(">>", "»")
    s = re.sub(r"\\emph\{([^{}]*)\}", r"*\1*", s)
    s = re.sub(r"\\texttt\{([^{}]*)\}", r"`\1`", s)
    s = s.replace("---", "—")
    s = re.sub(r"\s+", " ", s).strip()
    return s


title_en, title_ru = (tex2md(x) for x in macro("title", 2))
kw_en, kw_ru = (tex2md(x) for x in macro("keywords", 2))
abs_en, abs_ru = (tex2md(x) for x in macro("abstract", 2))
name_en_raw, name_ru_raw = macro("authorname", 2)
affil_en, affil_ru = (tex2md(x) for x in macro("affil", 2))
orcid = macro("orcid")[0].strip()
email = macro("email")[0].strip()
doi = macro("doi")[0].strip()
vol = macro("volhead")[0].strip()
issue = macro("issuehead")[0].strip()
pages = macro("pageshead")[0].strip().replace("--", "-")
year = macro("yearhead")[0].strip()
th_ru = tex2md(macro("titleheadru")[0])
th_en = tex2md(macro("titleheaden")[0])

name_en = name_en_raw.replace("\\,", " ").strip()      # "A. S. Stoyan"
name_ru = name_ru_raw.replace("\\,", " ").strip()      # "А. С. Стоян"


def surname_first(name):                               # "A. S. Stoyan" -> "Stoyan A.S."
    toks = name.split()
    return toks[-1] + " " + "".join(toks[:-1])


cite_ru = (f"{surname_first(name_ru)} {title_ru}. Труды ИСП РАН, {year}, "
           f"том {vol}, вып. {issue}, с. {pages}. DOI: {doi}")
cite_en = (f"{surname_first(name_en)} {title_en}. Trudy ISP RAN/Proc. ISP RAS, {year}, "
           f"vol. {vol}, issue {issue}, pp. {pages} (in Russian). DOI: {doi}")

# ---- bios (between the "Информация об авторах" heading and \end{document}) ---
bio_region = tex.split("Information about authors")[1].split(r"\end{document}")[0]
bio_region = re.sub(r"\\setlength\{[^}]*\}\{[^}]*\}", "", bio_region)
bio_region = re.sub(r"^\}", "", bio_region.strip())
bios = [tex2md(p) for p in re.split(r"\n\s*\n", bio_region) if p.strip()]
bio_ru, bio_en = bios[0], bios[1]


# ---- emit markdown ----------------------------------------------------------
def fill(t, **kw):
    for k, v in kw.items():
        t = t.replace("@@" + k + "@@", v)
    return t


FRONT_RU = r'''::: {custom-style="ispDoiBadge"}
**DOI: @@DOI@@**`<w:r><w:tab/></w:r>`{=openxml}![](cc-by.png){width="2.5cm"}
:::

::: {custom-style="ispHeader"}
@@TITLE@@
:::

::: {custom-style="ispAuthor"}
@@NAME@@, ORCID: @@ORCID@@ \<@@EMAIL@@\>
:::

::: {custom-style="ispAuthor"}
@@AFFIL@@
:::

::: {custom-style="ispAnotation"}
**Аннотация.** @@ABSTRACT@@
:::

::: {custom-style="ispAnotation"}
**Ключевые слова:** @@KEYWORDS@@
:::

::: {custom-style="ispAnotation"}
**Для цитирования:** @@CITE@@
:::

```{=openxml}
<w:p><w:r><w:br w:type="page"/></w:r></w:p>
```
'''

FRONT_EN = r'''::: {custom-style="ispHeader1"}
@@TITLE@@
:::

::: {custom-style="ispAuthor"}
@@NAME@@, ORCID: @@ORCID@@ \<@@EMAIL@@\>
:::

::: {custom-style="ispAuthor"}
@@AFFIL@@
:::

::: {custom-style="ispAnotation"}
**Abstract.** @@ABSTRACT@@
:::

::: {custom-style="ispAnotation"}
**Keywords:** @@KEYWORDS@@
:::

::: {custom-style="ispAnotation"}
**For citation:** @@CITE@@
:::
'''

BIOS = r'''::: {custom-style="ispSubHeader-1 level"}
Информация об авторах / Information about authors
:::

::: {custom-style="ispText_main"}
@@BIO_RU@@
:::

::: {custom-style="ispText_main"}
@@BIO_EN@@
:::
'''

os.makedirs(BUILD, exist_ok=True)
open(os.path.join(BUILD, "front-ru.md"), "w", encoding="utf-8").write(fill(
    FRONT_RU, DOI=doi, TITLE=title_ru, NAME=name_ru, ORCID=orcid, EMAIL=email,
    AFFIL=affil_ru, ABSTRACT=abs_ru, KEYWORDS=kw_ru, CITE=cite_ru))
open(os.path.join(BUILD, "front-en.md"), "w", encoding="utf-8").write(fill(
    FRONT_EN, TITLE=title_en, NAME=name_en, ORCID=orcid, EMAIL=email,
    AFFIL=affil_en, ABSTRACT=abs_en, KEYWORDS=kw_en, CITE=cite_en))
open(os.path.join(BUILD, "bios.md"), "w", encoding="utf-8").write(fill(
    BIOS, BIO_RU=bio_ru, BIO_EN=bio_en))


# ---- running heads: refill the three header files of reference.docx ----------
def esc(t):
    return t.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


heads = {
    "word/header1.xml": f"{name_en}. {th_en}. Trudy ISP RAN/Proc. ISP RAS, {year}, "
                        f"vol. {vol}, issue {issue}, pp. {pages}.",           # even = EN
    "word/header2.xml": f"{name_ru}. {th_ru}. Труды ИСП РАН, {year}, "
                        f"том {vol}, вып. {issue}, с. {pages}.",              # odd = RU
    "word/header3.xml": f"Труды ИСП РАН, том {vol}, вып. {issue}, {year} г. // "
                        f"Trudy ISP RAN/Proc. ISP RAS, vol. {vol}, issue {issue}, {year}.",
}
with zipfile.ZipFile(REF) as zin, \
     zipfile.ZipFile(os.path.join(BUILD, "reference.docx"), "w", zipfile.ZIP_DEFLATED) as zout:
    for item in zin.infolist():
        data = zin.read(item.filename)
        if item.filename in heads:
            xml = data.decode("utf-8")
            xml = re.sub(r"(<w:t[^>]*>).*?(</w:t>)",
                         lambda m, v=esc(heads[item.filename]): m.group(1) + v + m.group(2),
                         xml, count=1, flags=re.S)
            data = xml.encode("utf-8")
        zout.writestr(item, data)

print(f"frontmatter: vol {vol}, issue {issue}, pp {pages}, {year}; "
      f"author {surname_first(name_en)}; doi {doi}")
