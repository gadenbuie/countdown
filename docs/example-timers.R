## DON'T RUN INTERACTIVELY, SCRIPT EXECUTED BY index.Rmd ##
options(htmltools.dir.version = FALSE)
dir.create("default-timer", showWarnings = FALSE)
htmltools::save_html(
  countdown::countdown(0, 15, warn_when = 5, top = 0, left = 0, right = 0),
  file = "default-timer/index.html"
)
dir.create("fullscreen", showWarnings = FALSE)
htmltools::save_html(
  countdown::countdown_fullscreen(0, 15, warn_when = 5),
  file = "fullscreen/index.html"
)
