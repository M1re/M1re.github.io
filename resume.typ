// Resume generated from profile.yml. Look: cv-style.md (one column, Lato, grey secondary text).
//
// Public build (CI, no phone):
//   typst compile --font-path fonts --ignore-system-fonts resume.typ resume.pdf
// Private build with the phone from the git-ignored private.yml:
//   typst compile --font-path fonts --ignore-system-fonts --input private=private.yml resume.typ cv-private.pdf
//
// ATS rules this template follows:
//  - single column, real text (no images or icons for content)
//  - standard section names
//  - contacts in the body, not in header/footer
//  - ligatures off, so "fi"/"fl" stay separate letters for parsers

#let p = yaml("profile.yml")
// Typst cannot test whether a file exists, so private.yml is read only when its path is passed in.
#let private = if "private" in sys.inputs { yaml(sys.inputs.private) } else { (:) }

#let ok(v) = v != none and str(v) != "" and not str(v).contains("TODO")
#let months = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
#let ym(v) = {
  let s = str(v)
  if lower(s) == "present" { return "Present" }
  let parts = s.split("-")
  if parts.len() >= 2 { months.at(int(parts.at(1)) - 1) + " " + parts.at(0) } else { s }
}
#let year(v) = str(v).split("-").at(0)
#let strip-url(u) = u.replace(regex("^https?://(www\.)?"), "").trim("/", at: end)

#let ink = rgb("#222222")
#let muted = rgb("#555555")
#let rule = rgb("#9a9a9a")

#set document(
  title: p.name + " — " + p.title + " — Resume",
  author: p.name,
  keywords: p.skills.map(g => g.items).flatten(),
)
#set page(paper: "a4", margin: (x: 15mm, y: 14mm))
#set text(font: "Lato", size: 10.2pt, fill: ink, ligatures: false, hyphenate: false, lang: "en")
#set par(justify: false, leading: 0.5em, spacing: 0.5em)
#set list(indent: 0pt, body-indent: 0.5em, spacing: 0.4em, marker: [•])

// ---------- building blocks ----------
// Sticky: a heading always moves to the next page together with its first line.
#let section(title) = block(above: 14pt, below: 6pt, sticky: true, stroke: (bottom: 1pt + rule),
  inset: (bottom: 2.5pt), width: 100%, text(size: 10.5pt, weight: "bold", tracking: 1pt, upper(title)))
#let row(left, right) = grid(columns: (1fr, auto), column-gutter: 1em, left, text(fill: muted, right))
#let dates(a, b) = ym(a) + " – " + ym(b)

// ---------- header (left-aligned) ----------
#text(size: 21pt, weight: "bold", tracking: 0.2pt, p.name)
#v(-2pt)
#text(size: 12pt, p.title)
#if ok(p.at("headline", default: none)) [
  #v(-3pt)
  #text(size: 9.6pt, fill: muted, p.headline)
]
#v(1pt)
#{
  let c = p.contacts
  let items = (p.location,)
  let phone = private.at("phone", default: none)
  if ok(phone) { items.push(box(link("tel:" + str(phone).replace(" ", ""), str(phone)))) }
  if ok(c.at("email", default: none)) { items.push(box(link("mailto:" + c.email, c.email))) }
  for key in ("linkedin", "telegram", "github", "site") {
    let u = c.at(key, default: none)
    // box keeps each contact on one line instead of splitting it at "/"
    if ok(u) { items.push(box(link(u, strip-url(u)))) }
  }
  text(size: 9.2pt, fill: muted, items.join(" · "))
}

// ---------- summary ----------
#if ok(p.at("summary", default: none)) {
  section[Summary]
  p.summary.split("\n").filter(s => s.trim() != "").map(s => par(s.trim())).join()
}

// ---------- skills ----------
#section[Skills]
#for g in p.skills {
  let items = g.items.filter(ok)
  if items.len() > 0 { block(above: 3pt, below: 3pt)[*#g.group:* #items.join(", ")] }
}

// ---------- experience ----------
#section[Experience]
#for (i, e) in p.experience.enumerate() {
  if i > 0 { v(9pt) }
  // The job header is sticky, so it never stays alone at the bottom of a page.
  block(breakable: false, sticky: true, below: 3pt, {
    row([*#e.role*, #e.company], dates(e.start, e.end) + if ok(e.at("location", default: none)) { " · " + e.location } else { "" })
    if ok(e.at("context", default: none)) {
      v(1pt)
      text(style: "italic", fill: muted, e.context)
    }
    if ok(e.at("stack", default: none)) {
      v(1pt)
      text(size: 9.2pt, fill: muted, "Stack: " + e.stack)
    }
  })
  let hl = e.at("highlights", default: ()).filter(ok)
  if hl.len() > 0 { list(..hl.map(h => [#h])) }
}

// ---------- certifications ----------
#let certs = p.at("certifications", default: ()).filter(c => ok(c.name))
#if certs.len() > 0 {
  section[Certifications]
  for c in certs {
    let name = if ok(c.at("url", default: none)) { link(c.url, c.name) } else { c.name }
    block(above: 3pt, below: 3pt)[#name — #c.issuer, #ym(c.date)]
  }
}

// ---------- education ----------
#if p.at("education", default: ()).len() > 0 {
  section[Education]
  for e in p.education {
    row([*#e.degree*, #e.school#if ok(e.at("location", default: none)) [, #e.location]], year(e.start) + " – " + year(e.end))
  }
}

// ---------- languages ----------
#let langs = p.at("languages", default: ()).filter(l => ok(l.name) and ok(l.level))
#if langs.len() > 0 {
  section[Languages]
  langs.map(l => l.name + " " + l.level).join(" · ")
}
