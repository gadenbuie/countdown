#' Launch Countdown Shiny App
#'
#' Launches a full screen, interactive countdown timer as a [shiny] app.
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

  app_file <- system.file("countdown-fullscreen", "app.R", package = "countdown")
  file.copy(app_file, app_dir)

  on.exit(unlink(app_dir, recursive = TRUE))

  library(shiny)
  runApp(app_dir, ...)
  # nocov end
}
