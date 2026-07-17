-- ISP RAS docx post-processing filters

-- 1. Section headings -> ISP subsection style paragraph (numbers already baked in)
function Header(el)
  return pandoc.Div(
    pandoc.Para(el.content),
    pandoc.Attr("", {}, {["custom-style"] = "ispSubHeader-2 level"})
  )
end

-- 2. Caption Divs -> ISP caption styles (figures centered, tables left-aligned)
local capstyle = { ispcap = "ispPicture_sign", ispcapt = "ispTableSign" }
function Div(el)
  for _, c in ipairs(el.classes) do
    if capstyle[c] then
      el.attributes["custom-style"] = capstyle[c]
      el.classes = {}
      return el
    end
  end
end

-- 3. Cross-references: figures/tables -> number; section refs already numbered
local refnum = {
  ["fig:lifecycle"] = "1",
  ["tbl:free-vars"] = "1", ["tbl:compare"] = "2", ["tbl:map-three"] = "3",
}
function Link(el)
  if el.attributes["reference-type"] == "ref" then
    local r = el.attributes["reference"]
    if refnum[r] then return pandoc.Str(refnum[r]) end
    return el.content  -- section refs: drop the (dead) hyperlink, keep the number text
  end
end

-- 4. Stand-alone image: centre figures, right-align the CC-BY badge
function Para(el)
  if #el.content == 1 and el.content[1].t == "Image" then
    local style = el.content[1].src:match("cc%-by") and "ispRight" or "ispPicture_sign"
    return pandoc.Div({el}, pandoc.Attr("", {}, {["custom-style"] = style}))
  end
end

-- 5. Collapse consecutive citation numbers into ranges (incl. pairs), hyphenated.
--    Runs after citeproc, so it sees rendered numeric citations like "[2, 3]".
local function collapse(inside)
  local toks = {}
  for t in (inside .. ","):gmatch("%s*([^,]-)%s*,") do toks[#toks + 1] = t end
  local out, i = {}, 1
  while i <= #toks do
    if toks[i]:match("^%d+$") then
      local j = i
      while j + 1 <= #toks and toks[j + 1]:match("^%d+$")
            and tonumber(toks[j + 1]) == tonumber(toks[j]) + 1 do
        j = j + 1
      end
      out[#out + 1] = (j > i) and (toks[i] .. "-" .. toks[j]) or toks[i]
      i = j + 1
    else
      out[#out + 1] = toks[i]; i = i + 1
    end
  end
  return table.concat(out, ", ")
end

function Cite(el)
  local s = pandoc.utils.stringify(el.content):gsub("\u{2013}", "-")
  local pre, inside, post = s:match("^(.-)%[(.+)%](.-)$")
  if inside then s = pre .. "[" .. collapse(inside) .. "]" .. post end
  return pandoc.Str(s)
end

-- 6. En-dash -> hyphen inside numeric ranges (e.g. bibliography "pp. 59–70").
function Str(el)
  if el.text:find("\u{2013}") then
    return pandoc.Str((el.text:gsub("(%d)\u{2013}(%d)", "%1-%2")))
  end
end

-- 7. ... and when the en-dash is its own token between two numbers (body ranges).
function Inlines(ils)
  for i = 2, #ils - 1 do
    if ils[i].t == "Str" and ils[i].text == "\u{2013}"
        and ils[i - 1].t == "Str" and ils[i - 1].text:match("%d$")
        and ils[i + 1].t == "Str" and ils[i + 1].text:match("^%d") then
      ils[i] = pandoc.Str("-")
    end
  end
  return ils
end
