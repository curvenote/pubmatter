#import "@preview/tidy:0.2.0"
#import "./pubmatter.typ"

#let example = (it) => {
  box(fill: luma(95%), inset: (x: 10pt), width: 100%, it)
}

#let fm = pubmatter.load((
  title: "pubmatter",
  subtitle: "A typst library for parsing and showing publication frontmatter",
  authors: (
    (
      name: "Rowan Cockett",
      email: "rowan@curvenote.com",
      orcid: "0000-0002-7859-8394",
      github: "rowanc1",
      affiliations: ("Curvenote Inc.", "Executable Books"),
    ),
  ),
  open-access: true,
  license: "CC-BY-4.0",
  venue: "Typst Package",
  date: "2024/01/26",
  abstract: [
    Utilities for loading and working with authors, affiliations, abstracts, keywords and other frontmatter information common in scientific publications.

    Our goal is to introduce standardized ways of working with this content to expose metadata to scientific publishers who are interested in using typst in a standardized way. The specification for this pubmatter is based on MyST Markdown and Quarto, and can load their YAML files directly.
  ],
  keywords: ("typst package", "open-science", "standards")
))


#show raw.where(lang: "example"): (it) => {
  set text(font: "Noto Sans", size: 9pt)
  box(inset: (left: 10pt, y: 5pt), stroke: (left: blue + 2pt))[
    #raw(lang: "typst", it.text.replace(regex("pubmatter."), ""))
      #box(fill: luma(95%), inset: (x: 10pt, y: 5pt), width: 100%, eval("[" + it.text + "]", scope: (
        pubmatter: pubmatter,
        fm: fm,
        authors: fm.authors,
        affiliations: fm.affiliations,
      )
    ))
  ]
}


#let theme = (color: red.darken(20%), font: "Noto Sans")
#set page(header: pubmatter.show-page-header(theme: theme, fm), footer: pubmatter.show-page-footer(fm))
#state("THEME").update(theme)
#show link: it => [#text(fill: blue)[#it]]

#pubmatter.show-title-block(fm)
#state("THEME").update((color: purple.darken(20%), font: "Noto Sans"))
#pubmatter.show-abstract-block(fm)

#set text(font: "Noto Serif", size: 9pt)

== Loading Frontmatter

The frontmatter can contain all information for an article, including title, authors, affiliations, abstracts and keywords. These are then normalized into a standardized format that can be used with a number of `show` functions like `show-authors`. For example, we might have a YAML file that looks like this:

```yaml
author: Rowan Cockett
date: 2024/01/26
```

You can load that file with `yaml`, and pass it to the `load` function:

```typst
#let fm = pubmatter.load(yaml("pubmatter.yml"))
```

This will give you a normalized data-structure that can be used with the `show` functions for showing various parts of a document.

You can also use a `dictionary` directly:


```example
#let fm = pubmatter.load((
  author: (
    (
      name: "Rowan Cockett",
      email: "rowan@curvenote.com",
      orcid: "0000-0002-7859-8394",
      affiliations: "Curvenote Inc.",
    ),
  ),
  date: datetime(year: 2024, month: 01, day: 26),
  doi: "10.1190/tle35080703.1",
))
#pubmatter.show-author-block(fm)
```

#pagebreak()

= Theming

The theme including color and font choice can be set using the `THEME` state.
For example, this document has the following theme set:

```typst
#let theme = (color: red.darken(20%), font: "Noto Sans")
#set page(header: pubmatter.show-page-header(theme: theme, fm), footer: pubmatter.show-page-footer(fm))
#state("THEME").update(theme)
```

Note that for the `header` the theme must be passed in directly. This will hopefully become easier in the future, however, there is a current bug that removes the page header/footer if you set this above the `set page`. See #link("https://github.com/typst/typst/issues/2987")[\#2987].

The `font` option only corresponds to the frontmatter content (abstracts, title, header/footer etc.) allowing the body of your document to have a different font choice.

#pagebreak()

= Normalized Frontmatter Object

The frontmatter object has the following normalized structure:

```yaml
title: content
subtitle: content
short-title: string             # alias: running-title, running-head
# Authors Array
# simple string provided for author is turned into ((name: string),)
authors:                        # alias: author
  - name: string
    url: string                 # alias: website, homepage
    email: string
    phone: string
    fax: string
    orcid: string               # alias: ORCID
    note: string
    corresponding: boolean      # default: `true` when email set
    equal-contributor: boolean  # alias: equalContributor, equal_contributor
    deceased: boolean
    roles: string[]             # must be a contributor role
    affiliations:               # alias: affiliation
      - id: string
        index: number
# Affiliations Array
affiliations:                   # alias: affiliation
  - string                      # simple string is turned into (name: string)
  - id: string
    index: number
    name: string
    institution: string         # use either name or institution
# Other publication metadata
open-access: boolean
license:                        # Can be set with a SPDX ID for creative commons
  id: string
  url: string
  name: string
doi: string                     # must be only the ID, not the full URL
date: datetime                  # validates from 'YYYY-MM-DD' if a string
citation: content
# Abstracts Array
# content is turned into ((title: "Abstract", content: string),)
abstracts:                      # alias: abstract
  - title: content
    content: content
```

#pagebreak()
Note that you will usually write the affiliations directly in line, in the following example, we can see that the output is a normalized affiliation object whtat is linked by the `id` of the affiliation (just the name if it is a string!).

```example
#let fm = pubmatter.load((
  authors: (
    (
      name: "Rowan Cockett",
      affiliations: "Curvenote Inc.",
    ),
    (
      name: "Steve Purves",
      affiliations: ("Executable Books", "Curvenote Inc."),
    ),
  ),
))
#raw(lang:"yaml", yaml.encode(fm))
```

#pagebreak()
= API Documentation

#let docs = tidy.parse-module(
  read("./pubmatter.typ"),
  name: "pubmatter",
)

#let validate-docs = tidy.parse-module(
  read("./validate-frontmatter.typ"),
  name: "validate-frontmatter",
)

#tidy.show-module(docs)
#tidy.show-module(validate-docs)
