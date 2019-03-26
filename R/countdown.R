#' Countdown Timer
#'
#' Creates a countdown timer using HTML, CSS, and vanilla Javascript, suitable
#' for use in web-based presentations, such as those created by
#' [xaringan::infinite_moon_reader()].
#'
#' @param minutes The number of minutes for which the timer should run. This
#'   value is added to `seconds`.
#' @param seconds The number of seconds for which the timer should run. This
#'   value is added to `minutes`.
#' @param ... Ignored
#' @param id A optional unique ID for the `<div>` containing the timer. A unique
#'   ID will be created if none is specified. All of the timers in a single
#'   document need to have unique IDs to function properly. Unless you have a
#'   specific reason, it would probably be best to leave this unset.
#' @param class Optional additional classes to be added to the `<div>`
#'   containing the timer. The `"countdown"` class is added automatically. If
#'   you want to modify the style of the timer, you can modify the `"countdown"`
#'   class or specify addtional styles here that extend the base CSS.
#' @param play_sound Play a sound at the end of the timer? If `TRUE`, plays the
#'   "stage complete" sound courtesy of [beepr].
#' @param font_size The font size of the time displayed in the timer.
#' @param margin The margin applied to the timer container, default is
#'   `"0.5em"`.
#' @param padding The padding within the timer container, default is `"0 15px"`.
#' @param right Position of the timer within its container. By default the timer
#'   is right-aligned using `right = "0"`. If `left` is set, `right` defaults to
#'   `NULL`.
#' @param bottom Position of the timer within its container. By default the
#'   timer is bottom-aligned using `bottom = "0"`. If `top` is set, `bottom`
#'   defaults to `NULL`.
#' @param left Position of the timer within its container. By default `left` is
#'   unset (`NULL`).
#' @param top Position of the timer within its container. By default `top` is
#'   unset (`NULL`).
#' @param box_shadow Shadow specification for the timer, set to `NULL` to remove
#'   the shadow.
#' @param border_width Width of the timer border (all states).
#' @param border_radius Radius of timer border corners (all states).
#' @param color_border Color of the timer border when not yet activated.
#' @param color_background Color of the timer background when not yet activated.
#' @param color_text Color of the timer text when not yet activated.
#' @param color_running_background Color of the timer background when running.
#'   Colors are automatically chosen for the running timer border and text
#'   (`color_running_border` and `color_running_text`, respectively) from the
#'   running background color.
#' @param color_running_border Color of the timer border when running.
#' @param color_running_text Color of the timer text when running.
#' @param color_finished_background Color of the timer background when finished.
#'   Colors are automatically chosen for the finished timer border and text
#'   (`color_finished_border` and `color_finished_text`, respectively) from the
#'   finished background color.
#' @param color_finished_border Color of the timer border when finished.
#' @param color_finished_text Color of the timer text when finished.
#' @importFrom htmltools HTML htmlDependency div code span
#' @export
countdown <- function(
  minutes = 1L,
  seconds = 0L,
  ...,
  id = NULL,
  class = NULL,
  play_sound = FALSE,
  font_size = "3em",
  margin = "0.6em",
  padding = "0 15px",
  bottom = if (is.null(top)) "0",
  right = if (is.null(left)) "0",
  top = NULL,
  left = NULL,
  box_shadow = "0px 4px 10px 0px rgba(50, 50, 50, 0.4)",
  border_width = "3px",
  border_radius = "15px",
  color_border = "#ddd",
  color_background = "inherit",
  color_text = "inherit",
  color_running_background = "#43ac6a",
  color_running_border = darken_color(color_running_background, 0.1),
  color_running_text = choose_dark_or_light(color_running_background),
  color_finished_background = "#F04124",
  color_finished_border = darken_color(color_finished_background, 0.1),
  color_finished_text = choose_dark_or_light(color_finished_background)
) {
  time <- minutes * 60 + seconds
  minutes <- as.integer(floor(time / 60))
  seconds <- as.integer(time - minutes * 60)
  stopifnot(minutes < 100)

  if (is.null(id)) {
    uid <- make_unique_id()
    id <- paste0("timer_", uid)
  }
  id <- validate_html_id(id)

  class <- unique(c("countdown", class))

  `%+?%` <- function(x, y) if (!is.null(x)) paste0(y, ":", x, ";")

  x <- div(
    class = paste(class, collapse = " "),
    id = id,
    style = paste0(top %+?% "top",
                   right %+?% "right",
                   bottom %+?% "bottom",
                   left %+?% "left",
                   if (!missing(margin)) margin %+?% "margin",
                   if (!missing(padding)) padding %+?% "padding",
                   if (!missing(font_size)) font_size %+?% "font-size"),
    code(
      HTML(
        paste0(
          span(class = "digits minutes", sprintf("%02d", minutes)),
          span(class = "digits colon", ":"),
          span(class = "digits seconds", sprintf("%02d", seconds))
        )
      )
    )
  )

  if (play_sound) x$attribs$`data-audio` <- "true"

  tmpdir <- tempfile("countdown")
  dir.create(tmpdir)
  file.copy(system.file("countdown.js", package = "countdown"),
            file.path(tmpdir, "countdown.js"))
  file.copy(system.file("smb_stage_clear.mp3", package = "countdown"),
            file.path(tmpdir, "smb_stage_clear.mp3"))

  css_template <- readLines(system.file("countdown.css", package = "countdown"))
  css <- whisker::whisker.render(css_template)
  css_file <- file.path(tmpdir, "countdown.css")
  writeLines(css, css_file)

  htmltools::htmlDependencies(x) <- htmlDependency(
      "countdown",
      version = utils::packageVersion("countdown"),
      src = gsub("//", "/", dirname(css_file)),
      script = "countdown.js",
      stylesheet = "countdown.css",
      all_files = TRUE
    )

  htmltools::browsable(x)
}


make_unique_id <- function(safe = TRUE) {
  uniqid <- function() as.hexmode(as.integer(Sys.time() + runif(1) * 1000))

  if (!safe) return(uniqid())
  callr::r_safe(
    function() countdown:::make_unique_id(safe = FALSE)
  )
}

validate_html_id <- function(id) {
  stop_because <- function(...) {
    stop(paste0('"', id, '" is not a valid HTML ID: ', ...))
  }
  if (!grepl("^[a-zA-Z]", id)) {
    stop_because("Must start with a letter")
  }
  if (grepl("[^0-9a-zA-Z_:.-]", id)) {
    invalid <- gsub("[0-9a-zA-Z_:.-]", "", id)
    invalid <- strsplit(invalid, character(0))[[1]]
    invalid <- unique(invalid)
    invalid[invalid == " "] <- "' '"
    invalid <- paste(invalid, collapse = ", ")
    stop_because('Cannot contain the character',
                 if (nchar(invalid) > 1) "s: ", invalid)
  }
  id
}
