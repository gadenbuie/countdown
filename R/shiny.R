#' Launch Countdown Shiny App
#'
#' Launches a full screen, interactive countdown timer as a
#' \link[shiny]{shiny-package} app.
#'
#' @inheritDotParams shiny::runApp port launch.browser host workerId quiet
#'   display.mode test.mode
#' @export
countdown_app <- function(...) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("countdown_app() requires shiny: install.packages('shiny')", call. = FALSE)
  }

  # Create temp dir for app and structure
  # nocov start
  app_dir <- tempfile("")
  dir.create(file.path(app_dir, "www", "tmp"), recursive = TRUE)

  app_file <- countdown_app_file("app.R")
  css_file <- countdown_app_file("www", "bootstrap.min.css")
  file.copy(app_file, app_dir)
  file.copy(css_file, file.path(app_dir, "www"))

  on.exit(unlink(app_dir, recursive = TRUE))

  shiny::runApp(app_dir, ...)
  # nocov end
}

countdown_app_file <- function(...) {
  system.file("countdown-fullscreen", ..., package = "countdown") #nocov
}
