options(htmltools.dir.version = FALSE)
dir.create(here::here("docs/default-timer"), showWarnings = FALSE)
htmltools::save_html(
  countdown::countdown(0, 15, warn_when = 5, top = 0, left = 0),
  file = file.path(getwd(), "docs/default-timer/index.html")
)
dir.create(here::here("docs/fullscreen"), showWarnings = FALSE)
htmltools::save_html(
  countdown::countdown_fullscreen(0, 15, warn_when = 5),
  file = file.path(getwd(), "docs/fullscreen/index.html")
)
