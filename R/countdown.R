`%||%` <- function(x, y) if (is.null(x)) y else x

#' Countdown Timer
#'
#' Creates a countdown timer using HTML, CSS, and vanilla JavaScript, suitable
#' for use in web-based presentations, such as those created by
#' [xaringan::infinite_moon_reader()].
#'
#' @examples
#'
#' \dontrun{
#' countdown(minutes = 0, seconds = 42)
#'
#' countdown(
#'   minutes = 1, seconds = 30,
#'   left = 0, right = 0,
#'   padding = "15px", margin = "5%",
#'   font_size = "6em"
#' )
#'
#' # For a stand-alone full-screen countdown timer, use countdown_fullscreen()
#' # with default parameters.
#' countdown_fullscreen(1, 30)
#'
#' # For xaringan slides, use percentages for `margin` and `padding` and set
#' # `font_size` and `line_height`. In general, the following is a good place
#' # to start and then tweak the font size up or down as needed.
#' countdown_fullscreen(
#'   minutes = 0, seconds = 90,
#'   padding = "20%", margin = "5%",
#'   font_size = "8em", line_height = "1.5"
#' )}
#'
#' @return A vanilla JavaScript countdown timer as HTML, with dependencies.
#' @seealso [countdown_app()]
#'
#' @param minutes The number of minutes for which the timer should run. This
#'   value is added to `seconds`.
#' @param seconds The number of seconds for which the timer should run. This
#'   value is added to `minutes`.
#' @param ... Ignored by [countdown()]. In [countdown_fullscreen()], additional
#'   arguments are passed on to [countdown()].
#' @param id A optional unique ID for the `<div>` containing the timer. A unique
#'   ID will be created if none is specified. All of the timers in a single
#'   document need to have unique IDs to function properly. Unless you have a
#'   specific reason, it would probably be best to leave this unset.
#' @param class Optional additional classes to be added to the `<div>`
#'   containing the timer. The `"countdown"` class is added automatically. If
#'   you want to modify the style of the timer, you can modify the `"countdown"`
#'   class or specify additional styles here that extend the base CSS.
#' @param play_sound Play a sound at the end of the timer? If `TRUE`, plays the
#'   "stage complete" sound courtesy of \link[beepr:beepr-package]{beepr}.
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
#' @param warn_when Change the countdown to "warning" state when `warn_when`
#'   seconds remain. This is achieved by adding the `warning` class to the timer
#'   when `warn_when` seconds or less remain. Only applied when greater than
#'   `0`.
#' @param update_every Update interval for the timer, in seconds. When this
#'   argument is greater than `1`, the timer run but the display will only
#'   update, once every `update_every` seconds. The timer will switch to normal
#'   second-by-second updating for the last two `update_every` periods.
#' @param blink_colon Adds an animation to the blink the colon of the digital
#'   timer at each second. Because the blink animation is handled via CSS and
#'   not by the JavaScript process that decrements the timer, so the animation
#'   may fall out of sync with the timer. For this reason, the blink animation
#'   is only shown, by default, when `update_every` is greater than 1, i.e. when
#'   the countdown time is updated periodically rather than each second.
#' @param box_shadow Shadow specification for the timer, set to `NULL` to remove
#'   the shadow.
#' @param border_width Width of the timer border (all states).
#' @param border_radius Radius of timer border corners (all states).
#' @param line_height Line height of timer digits text. Line height needs to be
#'   set correctly for CSS to vertically align the text within the timer box.
#'   The default value of `1.2` means that the line height will be 1.2 times the
#'   `font_size` of the timer text. Note that the choice of `font_size` value
#'   and unit, in combination with the overall dimensions of the timer
#'   container, will impact the best value of `line_height`. If the timer text
#'   is above the midline, then you may need to increase `line_height`; if it's
#'   below the midline, try decreasing `line_height`.
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
#' @param color_warning_background Color of the timer background when the timer
#'   is below `warn_when` seconds. Colors are automatically chosen for the
#'   warning timer border and text (`color_warning_border` and
#'   `color_warning_text`, respectively) from the warning background color.
#' @param color_warning_border Color of the timer border when the timer is below
#'   `warn_when` seconds.
#' @param color_warning_text Color of the timer text when the timer is below
#'   `warn_when` seconds.
#' @importFrom htmltools HTML htmlDependency div code span
#' @name countdown
NULL

#' @describeIn countdown Create a countdown timer for use in presentations and
#'   HTML documents.
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
  warn_when = 0L,
  update_every = 1L,
  blink_colon = update_every > 1L,
  box_shadow = "0px 4px 10px 0px rgba(50, 50, 50, 0.4)",
  border_width = "3px",
  border_radius = "15px",
  line_height = "1.2",
  color_border = "#ddd",
  color_background = "inherit",
  color_text = "inherit",
  color_running_background = "#43AC6A",
  color_running_border = darken(color_running_background, 0.1),
  color_running_text = NULL,
  color_finished_background = "#F04124",
  color_finished_border = darken(color_finished_background, 0.1),
  color_finished_text = NULL,
  color_warning_background = "#E6C229",
  color_warning_border = darken(color_warning_background, 0.1),
  color_warning_text = NULL
) {
  time <- minutes * 60 + seconds
  minutes <- as.integer(floor(time / 60))
  seconds <- as.integer(time - minutes * 60)
  stopifnot(minutes < 100)
  warn_when <- suppressWarnings(as.integer(warn_when))
  if (is.na(warn_when)) {
    stop("`warn_when` must be an integer number of seconds")
  }

  if (is.null(id)) {
    uid <- make_unique_id()
    id <- paste0("timer_", uid)
  }
  id <- validate_html_id(id)

  class <- paste(unique(c("countdown", class)), collapse = " ")

  if (blink_colon) class <- paste(class, "blink-colon")

  update_every <- as.integer(update_every)
  if (update_every > 1L) {
    class <- paste0(class, " noupdate-", update_every)
  }

  `%:?%` <- function(x, y) if (!is.null(x)) paste0(y, ":", x, ";")

  x <- div(
    class = class,
    id = id,
    style = paste0(
      top %:?% "top",
      right %:?% "right",
      bottom %:?% "bottom",
      left %:?% "left",
      if (!missing(margin)) margin %:?% "margin",
      if (!missing(padding)) padding %:?% "padding",
      if (!missing(font_size)) font_size %:?% "font-size",
      if (!missing(line_height)) line_height %:?% "line-height"
    ),
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
  x$attribs$`data-warnwhen` <- if (warn_when > 0) warn_when else 0L

  tmpdir <- tempfile("countdown")
  dir.create(tmpdir)
  file.copy(system.file("countdown.js", package = "countdown"),
            file.path(tmpdir, "countdown.js"))
  file.copy(system.file("smb_stage_clear.mp3", package = "countdown"),
            file.path(tmpdir, "smb_stage_clear.mp3"))

  # Set text based on background color
  color_running_text <- color_running_text %||%
    choose_dark_or_light(color_running_background)
  color_finished_text <- color_finished_text %||%
    choose_dark_or_light(color_finished_background)
  color_warning_text <- color_warning_text %||%
    choose_dark_or_light(color_warning_background)

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

#' @describeIn countdown A full-screen timer that takes up the entire view port
#'   and uses the largest reasonable font size.
#'
#' @export
countdown_fullscreen <- function(
  minutes = 1,
  seconds = 0,
  ...,
  font_size = "30vw",
  line_height = "96vh",
  border_width = "0",
  border_radius = "0",
  margin = "0",
  padding = "0",
  top = 0,
  right = 0,
  bottom = 0,
  left = 0
) {
  countdown(
    minutes, seconds,
    font_size = font_size,
    line_height = line_height,
    border_width = border_width,
    border_radius = border_radius,
    margin = margin,
    padding = padding,
    top = top, right = right, bottom = bottom, left = left,
    ...
  )
}


make_unique_id <- function(safe = TRUE) {
  uniqid <- function() as.hexmode(as.integer(Sys.time() + stats::runif(1) * 1000))

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
