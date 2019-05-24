options(htmltools.dir.version = FALSE)
htmltools::save_html(
  countdown::countdown(0, 15, warn_when = 5, top = 0, left = 0),
  file = file.path(getwd(), "docs/default-timer/index.html")
)
