#import "@preview/scienceicons:0.0.6": orcid-icon, email-icon, open-access-icon, github-icon
#import "./validate-frontmatter.typ": load, show-citation

#let THEME = state("THEME", (color: blue.darken(20%), font: ""))

#let with-theme(func) = {
  locate(loc => {
    let theme = THEME.at(loc)
    func(theme)
  })
}

/// Create a ORCID link with an ORCID logo
///
/// ```example
/// #pubmatter.orcid-link(orcid: "0000-0002-7859-8394")
/// ```
///
/// - orcid (str): Use an ORCID identifier with no URL, e.g. `0000-0000-0000-0000`
/// -> content
#let orcid-link(
  orcid: none,
) = {
  let orcid-green = rgb("#AECD54")
  if (orcid == none) { return orcid-icon(color: orcid-green) }
  return link("https://orcid.org/" + orcid, orcid-icon(color: orcid-green))
}

/// Create a DOI link
///
/// ```example
/// #pubmatter.doi-link(doi: "10.1190/tle35080703.1")
/// ```
///
/// - doi (str): Only include the DOI identifier, not the URL
/// -> content
#let doi-link(doi: none) = {
  if (doi == none) { return none }
  // Proper practices are to show the whole DOI link in text
  return link("https://doi.org/" + doi, "https://doi.org/" + doi)
}

/// Create a mailto link with an email icon
///
/// ```example
/// #pubmatter.email-link(email: "rowan@curvenote.com")
/// ```
///
/// - email (str): Email as a string
/// -> content
#let email-link(email: none) = {
  if (email == none) { return none }
  return link("mailto:" + email, email-icon(color: gray))
}

/// Create a link to Wikipedia with an OpenAccess icon.
///
/// ```example
/// #pubmatter.open-access-link()
/// ```
///
/// -> content
#let open-access-link() = {
  let orange = rgb("#E78935")
  return link("https://en.wikipedia.org/wiki/Open_access", open-access-icon(color: orange))
}


/// Create a link to a GitHub profile with the GitHub icon.
///
/// ```example
/// #pubmatter.github-link(github: "rowanc1")
/// ```
///
/// - github (str): GitHub username (no `@`)
/// -> content
#let github-link(github: none) = {
  return link("https://github.com/" + github, github-icon())
}


/// Create a spaced content array separated with a `spacer`.
///
/// The default spacer is `  |  `, and undefined elements are removed.
///
/// ```example
/// #pubmatter.show-spaced-content(("Hello", "There"))
/// ```
///
/// - spacer (content): How to join the content
/// - content (array): The various things to going together
/// -> content
#let show-spaced-content(spacer: text(fill: gray)[#h(8pt) | #h(8pt)], content) = {
  content.filter(h => h != none and h != "").join(spacer)
}

/// Show authors
///
/// ```example
/// #pubmatter.show-authors(authors)
/// ```
///
/// - size (length): Size of the author text
/// - weight (weight): Weight of the author text
/// - show-affiliations (boolean): Show affiliations text
/// - show-orcid (boolean): Show orcid logo
/// - show-email (boolean): Show email logo
/// - show-github (boolean): Show github logo
/// - authors (fm, array): The frontmatter object or authors directly
/// -> content
#let show-authors(
  size: 10pt,
  weight: "semibold",
  show-affiliations: true,
  show-orcid: true,
  show-email: true,
  show-github: true,
  authors,
) = {
  // Allow to pass frontmatter as well
  let authors = if (type(authors) == dictionary and "authors" in authors) {authors.authors} else { authors }
  if authors.len() == 0 { return none }

  return box(inset: (top: 10pt, bottom: 5pt), width: 100%, {
    with-theme((theme) => {
      authors.map(author => {
        text(size, font: theme.font, weight: weight, author.name)
        if (show-affiliations and "affiliations" in author) {
          text(size: 2.5pt, [~]) // Ensure this is not a linebreak
          if (type(author.affiliations) == str) {
            super(author.affiliations)
          } else if (type(author.affiliations) == array) {
            super(author.affiliations.map((affiliation) => str(affiliation.index)).join(","))
          }
        }
        if (show-orcid and "orcid" in author) {
          orcid-link(orcid: author.orcid)
        }
        if (show-github and "github" in author) {
          github-link(github: author.github)
        }
        if (show-email and "email" in author) {
          email-link(email: author.email)
        }
      }).join(", ", last: ", and ")
    })
  })
}


/// Show affiliations
///
/// ```example
/// #pubmatter.show-affiliations(affiliations)
/// ```
///
/// - size (length): Size of the affiliations text
/// - fill (color): Color of of the affiliations text
/// - affiliations (fm, array): The frontmatter object or affiliations directly
/// -> content
#let show-affiliations(size: 8pt, fill: gray.darken(50%), affiliations) = {
  // Allow to pass frontmatter as well
  let affiliations = if (type(affiliations) == dictionary and "affiliations" in affiliations) {affiliations.affiliations} else { affiliations }
  if affiliations.len() == 0 { return none }
  return box(inset: (bottom: 9pt), width: 100%, {
    with-theme((theme) => {
      set text(size, font: theme.font, fill: fill)
      affiliations.map(affiliation => {
        super(str(affiliation.index))
        text(size: 2.5pt, [~]) // Ensure this is not a linebreak
        if ("name" in affiliation) {
          affiliation.name
        } else if ("institution" in affiliation) {
          affiliation.institution
        }
      }).join(", ")
    })
  })
}


/// Show author block
///
/// ```example
/// #pubmatter.show-author-block(fm)
/// ```
///
/// - fm (fm): The frontmatter object
/// -> content
#let show-author-block(fm) = {
  show-authors(fm)
  show-affiliations(fm)
}

/// Show title
///
/// ```example
/// #pubmatter.show-title(fm)
/// ```
///
/// - fm (fm): The frontmatter object
/// -> content
#let show-title(fm) = {
  with-theme(theme => {
    set text(font: theme.font)
    let title = if (type(fm) == dictionary and "title" in fm) {fm.title} else if (type(fm) == str or type(fm) == content) { fm } else { none }
    let subtitle = if (type(fm) == dictionary and "subtitle" in fm) {fm.subtitle} else { none }
    if (title != none) {
      box(inset: (bottom: 2pt), width: 100%, text(17pt, weight: "bold", fill: theme.color, title))
    }
    if (subtitle != none) {
      parbreak()
      box(width: 100%, text(12pt, fill: gray.darken(30%), subtitle))
    }
  })
}

/// Show title block
///
/// ```example
/// #pubmatter.show-title-block(fm)
/// ```
///
/// - fm (fm): The frontmatter object
/// -> content
#let show-title-block(fm) = {
  with-theme(theme => {
    show-title(fm)
    show-author-block(fm)
  })
}

/// Show page footer
///
/// ```example
/// #pubmatter.show-page-footer(fm)
/// ```
///
/// - fm (fm): The frontmatter object
/// -> content
#let show-page-footer(fm) = {
  return block(
    width: 100%,
    stroke: (top: 1pt + gray),
    inset: (top: 8pt, right: 2pt),
    with-theme((theme) => [
      #set text(font: theme.font)
      #grid(columns: (75%, 25%),
        align(left, text(size: 9pt, fill: gray.darken(50%),
            show-spaced-content((
              if("venue" in fm) {emph(fm.venue)},
              if("date" in fm and fm.date != none) {fm.date.display("[month repr:long] [day], [year]")}
            ))
        )),
        align(right)[
          #text(
            size: 9pt, fill: gray.darken(50%)
          )[
            #counter(page).display() of #locate((loc) => {counter(page).final(loc).first()})
          ]
        ]
      )
    ])
  )
}

/// Show page header
///
/// ```example
/// #pubmatter.show-page-header(theme: (font: "Noto Sans"), fm)
/// ```
///
/// - theme (theme): The theme object, There is a bug in the first page state update, so theme must be passed directly. See #link("https://github.com/typst/typst/issues/2987")[\#2987]
/// - fm (fm): The frontmatter object
/// -> content
#let show-page-header(theme: THEME, fm) = {
  locate(loc => {
    if(loc.page() == 1) {
      let headers = (
        if ("open-access" in fm) {[#smallcaps[Open Access] #open-access-link()]},
        if ("doi" in fm) { link("https://doi.org/" + fm.doi, "https://doi.org/" + fm.doi)}
      )
      // TODO: There is a bug in the first page state update
      // https://github.com/typst/typst/issues/2987
      return align(left, text(size: 8pt, font: theme.font, fill: gray, show-spaced-content(headers)))
    } else {
      return align(right, text(size: 8pt, font: theme.font, fill: gray.darken(50%),
        show-spaced-content((
          if ("short-title" in fm) { fm.short-title } else if ("title" in fm) { fm.title },
          if ("citation" in fm) { fm.citation },
        ))
      ))
    }
  })
}

/// Show abstracts
///
/// ```example
/// #pubmatter.show-abstracts(fm)
/// ```
///
/// - fm (fm): The frontmatter object
/// -> content
#let show-abstracts(fm) = {
  let abstracts
  if (type(fm) == "content") {
    abstracts = ((title: "Abstract", content: fm),)
  } else if (type(fm) == dictionary and "abstracts" in fm) {
    abstracts = fm.abstracts
  } else {
    return
  }

  with-theme((theme) => {
    abstracts.map(abs => {
      set text(font: theme.font)
      text(fill: theme.color, weight: "semibold", size: 9pt, abs.title)
      parbreak()
      set par(justify: true)
      text(size: 9pt, abs.content)
    }).join(parbreak())
  })
}

/// Show keywords
///
/// ```example
/// #pubmatter.show-keywords(fm)
/// ```
///
/// - fm (fm): The frontmatter object
/// -> content
#let show-keywords(fm) = {
  let keywords
  if (type(fm) == dictionary and "keywords" in fm) {
    keywords = fm.keywords
  } else {
    return
  }
  if (keywords.len() > 0) {
    with-theme((theme) => {
      text(size: 9pt, font: theme.font, {
        text(fill: theme.color, weight: "semibold", "Keywords")
        h(8pt)
        keywords.join(", ")
      })
    })
  }
}

/// Show abstract-block
///
/// ```example
/// #pubmatter.show-abstract-block(fm)
/// ```
///
/// - fm (fm): The frontmatter object
/// -> content
#let show-abstract-block(fm) = {
  box(inset: (top: 16pt, bottom: 16pt), stroke: (top: 0.5pt + gray.lighten(30%), bottom: 0.5pt + gray.lighten(30%)), show-abstracts(fm))
  show-keywords(fm)
  v(10pt)
}
