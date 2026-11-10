// Resume generated from profile.yml.
// Build: typst compile --font-path fonts resume.typ resume.pdf
//
// ATS rules this template follows:
//  - single column, real text (no images or icons for content)
//  - standard section names
//  - contacts in the body, not in header/footer
//  - ligatures off, so "fi"/"fl" stay separate letters for parsers

#let p = yaml("profile.yml")

#let ok(v) = v != none and str(v) != "" and not str(v).contains("TODO")
#let months = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
#let ym(v) = {
  let s = str(v)
  if lower(s) == "present" { return "Present" }
  let parts = s.split("-")
  if parts.len() >= 2 { months.at(int(parts.at(1)) - 1) + " " + parts.at(0) } else { s }
}
#let strip-url(u) = u.replace(regex("^https?://(www\.)?"), "").trim("/", at: end)

#let ink = rgb("#222222")
#let rule = rgb("#9a9a9a")

#set document(
  title: p.name + " — " + p.title + " — Resume",
  author: p.name,
  keywords: p.skills.map(g => g.items).flatten(),
)
#set page(paper: "a4", margin: (x: 1.5cm, y: 1.3cm))
#set text(font: "Poppins", size: 9.5pt, fill: ink, ligatures: false, hyphenate: false, lang: "en")
#set par(justify: true, leading: 0.55em, spacing: 0.7em)
#set list(indent: 0.6em, body-indent: 0.5em, spacing: 0.42em, marker: [•])
#show list: set par(justify: false)

// ---------- building blocks ----------
#let section(title) = {
  v(0.9em)
  text(size: 12.5pt, weight: "semibold", title)
  v(-0.55em)
  line(length: 100%, stroke: 0.6pt + rule)
  v(0.15em)
}
#let row(left, right) = grid(columns: (1fr, auto), column-gutter: 1em, left, right)

// ---------- header ----------
#align(center)[
  #set par(justify: false)
  #text(size: 21pt, weight: "semibold", p.name)
  #v(-0.6em)
  #text(size: 10.5pt, weight: "medium", p.title)
  #v(-0.35em)
  #{
    let c = p.contacts
    let items = (p.location,)
    if ok(c.at("email", default: none)) { items.push(link("mailto:" + c.email, c.email)) }
    for key in ("linkedin", "telegram", "github", "site") {
      let u = c.at(key, default: none)
      if ok(u) { items.push(link(u, strip-url(u))) }
    }
    text(size: 9pt, weight: "semibold", items.join([ #sym.bullet ]))
  }
]

// ---------- summary ----------
#if ok(p.at("summary", default: none)) {
  section[Professional Summary]
  p.summary
}

// ---------- experience ----------
#section[Professional Experience]
#for (i, e) in p.experience.enumerate() {
  if i > 0 { v(0.55em) }
  row(text(weight: "semibold", e.role), [#ym(e.start) - #ym(e.end)])
  v(-0.45em)
  row(text(weight: "semibold", e.company), text(weight: "semibold", e.at("location", default: "")))
  if ok(e.at("context", default: none)) {
    v(-0.3em)
    text(style: "italic", size: 9pt, e.context)
  }
  let hl = e.at("highlights", default: ()).filter(ok)
  if hl.len() > 0 {
    v(-0.2em)
    list(..hl.map(h => [#h]))
  }
}

// ---------- education ----------
#if p.at("education", default: ()).len() > 0 {
  section[Education]
  for e in p.education {
    row(text(weight: "semibold", e.degree), [#ym(e.start) - #ym(e.end)])
    v(-0.45em)
    row(e.school, e.at("location", default: ""))
  }
}

// ---------- certifications ----------
#let certs = p.at("certifications", default: ()).filter(c => ok(c.name))
#if certs.len() > 0 {
  section[Certifications]
  for c in certs {
    row(
      [*#c.name* -- #c.issuer#if ok(c.at("url", default: none)) [ (#link(c.url)[verify])]],
      ym(c.date),
    )
  }
}

// ---------- skills ----------
#section[Skills]
#for g in p.skills {
  let items = g.items.filter(ok)
  if items.len() > 0 [*#g.group:* #items.join([ #sym.bullet ]) \ ]
}

// ---------- languages ----------
#let langs = p.at("languages", default: ()).filter(l => ok(l.name) and ok(l.level))
#if langs.len() > 0 {
  section[Languages]
  langs.map(l => [*#l.name:* #l.level]).join([ #sym.bullet ])
}
