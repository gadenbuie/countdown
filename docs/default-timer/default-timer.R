options(htmltools.dir.version = FALSE)
htmltools::save_html(
  countdown::countdown(0, 15, top = 0, left = 0),
  file = "~/repos/countdown/docs/default-timer/index.html"
)
