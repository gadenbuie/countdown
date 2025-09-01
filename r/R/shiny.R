#' Launch Countdown Shiny App
#'
#' Launches a full screen, interactive countdown timer as a
#' \link[shiny]{shiny-package} app.
#'
#' @examples
#' if (interactive()) {
#'   countdown_app()
#' }
#'
#' @inheritDotParams shiny::runApp port launch.browser host workerId quiet
#'   display.mode test.mode
#'
#' @return Runs the countdown timer Shiny app in the current R session.
#'
#' @family Shiny functions
#' @export
countdown_app <- function(...) {
  require_shiny("`countdown_app()`")

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

#' Update a Countdown Timer in a Shiny App
#'
#' Updates the settings of a countdown timer dynamically in a Shiny app via
#' server logic. See [countdown_shiny_example()] for an example app
#' demonstrating the usage of `countdown_update()`.
#'
#' @param id A character vector with one or more `id` values for timers created
#'   with [countdown()] or [countdown_fullscreen()]. Be sure to set the `id`
#'   value when creating the timer.
#' @inheritParams countdown
#' @param session The reactive `session` object for the current Shiny session.
#'   In general, only required for expert or unusual use cases.
#' @param ... Ignored, but included for future compatibility.
#'
#' @return Invisibly returns the options sent to update the countdown timer(s).
#'
#' @family Shiny functions
#' @export
countdown_update <- function(
  id,
  ...,
  minutes = NULL,
  seconds = NULL,
  warn_when = NULL,
  update_every = NULL,
  blink_colon = NULL,
  play_sound = NULL,
  session = NULL
) {
  require_shiny("`countdown_update()`")
  session <- session %||% shiny::getDefaultReactiveDomain()

  if (is.null(id) || !is.character(id) || length(id) < 1) {
    stop("`id` is required and must be a character vector")
  }

  duration <- if (!is.null(minutes) || !is.null(seconds)) {
    (minutes %||% 0L) * 60L + (seconds %||% 0L)
  }

  opts <- list(
    duration = duration,
    warn_when = warn_when,
    update_every = update_every,
    blink_colon = blink_colon,
    play_sound = play_sound,
    ...
  )

  not_null <- vapply(opts, Negate(is.null), logical(1))
  opts <- opts[not_null]

  for (id_this in id) {
    opts$id <- id_this
    session$sendCustomMessage("countdown:update", opts)
  }

  invisible(opts)
}

#' Perform a Countdown Timer Action in a Shiny App
#'
#' Performs an action in a countdown timer dynamically in a Shiny app via server
#' logic. You can start, stop, reset, or bump time time (when the timer is
#' running) up or down. See [countdown_shiny_example()] for an example app
#' demonstrating the usage of `countdown_action()`.
#'
#' @inheritParams countdown_update
#' @param action The action to perform, one of `"start"`, `"stop"`, `"reset"`,
#'   `"bumpUp"`, or `"bumpDown"`.
#'
#' @return Invisibly returns the `id` of the updated countdown timer(s).
#'
#' @family Shiny functions
#' @export
countdown_action <- function(
  id,
  action = c("start", "stop", "reset", "bumpUp", "bumpDown"),
  session = NULL
) {
  require_shiny("`countdown_action()`")
  action <- match.arg(action)
  session <- session %||% shiny::getDefaultReactiveDomain()

  action <- sprintf("countdown:%s", action)
  for (id_this in id) {
    session$sendCustomMessage(action, id)
  }

  invisible(id)
}

#' Example Countdown Shiny App
#'
#' An example app that demonstrates the ways that countdown timers can be
#' integrated into Shiny apps.
#'
#' @examples
#' if (interactive()) {
#'   countdown_shiny_example()
#' }
#'
#' @inheritParams shiny::runApp
#'
#' @return Runs the example Shiny app in the current R session.
#'
#' @family Shiny functions
#' @export
countdown_shiny_example <- function(
  display.mode = c("showcase", "normal", "auto")
) {
  shiny::runApp(
    system.file("examples", "shiny-app", package = "countdown"),
    display.mode = match.arg(display.mode)
  )
}

countdown_app_file <- function(...) {
  system.file("countdown-fullscreen", ..., package = "countdown") #nocov
}

parse_mmss <- function(x = "") {
  error_msg <- list(error = "Please enter a time as MM or MM:SS")
  if (is.null(x) || x == "") {
    return(list(minutes = 0L, seconds = 0L))
  }

  invalid <- !grepl("\\d", x) || grepl("[^:0-9]", x) || grepl(":$", x)
  if (invalid) {
    return(error_msg)
  }

  m <- if (grepl(":", x)) {
    if (!grepl("^\\d{1,2}:\\d{1,2}$", x)) {
      return(error_msg)
    }
    regexec("^(\\d{1,2}):(\\d{1,2})$", x)
  } else {
    if (!grepl("^\\d{1,2}$", x)) {
      return(error_msg)
    }
    regexec("(\\d{1,2})", x)
  }

  x <- regmatches(x, m)[[1]]
  time <- list(minutes = as.integer(x[2]), seconds = as.integer(x[3]))

  if (is.na(time$seconds)) {
    time$seconds <- 0
  }

  time
}

require_shiny <- function(reason) {
  if (!has_shiny()) {
    stop(reason, " requires shiny: install.packages('shiny')", call. = FALSE)
  }
}

has_shiny <- function() {
  requireNamespace("shiny", quietly = TRUE)
}
