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

parse_mmss <- function(x = "") {
  error_msg <- list(error = "Please enter a time as MM or MM:SS")
  if (is.null(x) || x == "") return(list(minutes = 0L, seconds = 0L))

  invalid <- !grepl("\\d", x) || grepl("[^:0-9]", x) || grepl(":$", x)
  if (invalid) return(error_msg)

  m <- if (grepl(":", x)) {
    if (!grepl("^\\d{1,2}:\\d{1,2}$", x)) return(error_msg)
    regexec("^(\\d{1,2}):(\\d{1,2})$", x)
  } else {
    if (!grepl("^\\d{1,2}$", x)) return(error_msg)
    regexec("(\\d{1,2})", x)
  }

  x <- regmatches(x, m)[[1]]
  time <- list(minutes = as.integer(x[2]), seconds = as.integer(x[3]))

  if (is.na(time$seconds)) time$seconds <- 0

  time
}
