#' Countdown Timer
#'
#' Creates a countdown timer using HTML, CSS, and vanilla JavaScript, suitable
#' for use in web-based presentations, such as those created by
#' [xaringan::infinite_moon_reader()].
#'
#' @examples
#' if (interactive()) {
#'   countdown(minutes = 0, seconds = 42)
#'
#'   countdown(
#'     minutes = 1,
#'     seconds = 30,
#'     left = 0,
#'     right = 0,
#'     padding = "15px",
#'     margin = "5%",
#'     font_size = "6em"
#'   )
#'
#'   # For a stand-alone full-screen countdown timer, use countdown_fullscreen()
#'   # with default parameters.
#'   countdown_fullscreen(1, 30)
#'
#'   # For xaringan slides, use percentages for `margin` to set the distance from
#'   # the edge of the slide and use `font_size` to adjust the size of the digits.
#'   # If you need to nudge the text up or down vertically, increase or decrease
#'   # `line_height`.
#'   countdown_fullscreen(
#'     minutes = 0,
#'     seconds = 90,
#'     margin = "5%",
#'     font_size = "8em",
#'   )
#'
#'   # To position the timer "inline" in R Markdown documents,
#'   # use the `style` argument on each timer:
#'   countdown(1, 30, style = "position: relative; width: min-content;")
#' }
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
#'
#'   `countdown()` provides two built-in classes:
#'
#'    * Use `"inline"` to create an inline, rather than absolutely-positioned,
#'      timer. This is useful for timers in prose or documents.
#'    * Use `"no-controls"` for a timer without the up/down controls.
#' @param style CSS rules to be applied inline to the timer. Use `style` to
#'   override any global CSS rules for the timer. For example, to display the
#'   timer relative to the position where it is called (rather than positioned
#'   absolutely, as in the default), set
#'   `style = "position: relative; width: min-content;"`.
#' @param play_sound Play a sound at the end of the timer? If `TRUE`, plays the
#'   "stage complete" sound courtesy of \link[beepr:beepr-package]{beepr}.
#'   Alternatively, `play_sound` can be a relative or absolute URL to a sound
#'   file, such as an `mp3`, `wav`, `ogg`, or other audio file type.
#' @param font_size The font size of the time displayed in the timer.
#' @param margin The margin applied to the timer container, default is
#'   `"0.5em"`.
#' @param padding The padding within the timer container, default is `"10px 15px"`.
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
#' @param start_immediately If `TRUE`, the countdown timer starts as soon as its
#'   created (or as soon as the slides, document or Shiny app are loaded).
#' @param box_shadow Shadow specification for the timer, set to `NULL` to remove
#'   the shadow.
#' @param border_width Width of the timer border (all states).
#' @param border_radius Radius of timer border corners (all states).
#' @param line_height Line height of timer digits text. Use this value to nudge
#'   the timer digits up or down vertically. The best value generally depends on
#'   the fonts used in your slides or document. The default value is `1`.
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
  style = NULL,
  play_sound = FALSE,
  bottom = if (is.null(top)) "0",
  right = if (is.null(left)) "0",
  top = NULL,
  left = NULL,
  warn_when = 0L,
  update_every = 1L,
  blink_colon = update_every > 1L,
  start_immediately = FALSE,
  font_size = NULL,
  margin = NULL,
  padding = NULL,
  box_shadow = NULL,
  border_width = NULL,
  border_radius = NULL,
  line_height = NULL,
  color_border = NULL,
  color_background = NULL,
  color_text = NULL,
  color_running_background = NULL,
  color_running_border = NULL,
  color_running_text = NULL,
  color_finished_background = NULL,
  color_finished_border = NULL,
  color_finished_text = NULL,
  color_warning_background = NULL,
  color_warning_border = NULL,
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

  play_sound <- if (isTRUE(play_sound)) {
    "true"
  } else if (is.character(play_sound) && nzchar(play_sound)) {
    play_sound
  }

  warn_when <- if (warn_when > 0) warn_when
  update_every <- as.integer(update_every)

  css_vars <- make_countdown_css_vars(
    margin = margin,
    padding = padding,
    font_size = font_size,
    box_shadow = box_shadow,
    border_width = border_width,
    border_radius = border_radius,
    line_height = line_height,
    color_border = color_border,
    color_background = color_background,
    color_text = color_text,
    color_running_background = color_running_background,
    color_running_border = color_running_border,
    color_running_text = color_running_text,
    color_finished_background = color_finished_background,
    color_finished_border = color_finished_border,
    color_finished_text = color_finished_text,
    color_warning_background = color_warning_background,
    color_warning_border = color_warning_border,
    color_warning_text = color_warning_text
  )

  x <- div(
    class = class,
    id = id,
    `data-warn-when` = warn_when,
    `data-update-every` = update_every,
    `data-play-sound` = play_sound,
    `data-blink-colon` = if (isTRUE(blink_colon)) "true",
    `data-start-immediately` = if (isTRUE(start_immediately)) "true",
    tabindex = 0,
    style = css(
      top = top,
      right = right,
      bottom = bottom,
      left = left,
      !!!css_vars,
    ),
    style = style,
    # This looks weird but it keeps pandoc from adding paragraph tags
    HTML(paste0(
      '<div class="countdown-controls">',
      '<button class="countdown-bump-down">&minus;</button>',
      '<button class="countdown-bump-up">&plus;</button>',
      '</div>'
    )),
    code(
      class = "countdown-time",
      HTML(
        paste0(
          span(class = "countdown-digits minutes", sprintf("%02d", minutes)),
          span(class = "countdown-digits colon", ":"),
          span(class = "countdown-digits seconds", sprintf("%02d", seconds))
        )
      )
    ),
    html_dependency_countdown()
  )

  htmltools::browsable(x)
}

html_dependency_countdown <- function() {
  htmlDependency(
    "countdown",
    version = utils::packageVersion("countdown"),
    package = "countdown",
    src = "countdown",
    script = "countdown.js",
    stylesheet = "countdown.css",
    all_files = TRUE
  )
}

# ---- Countdown Full Screen ----

#' @describeIn countdown A full-screen timer that takes up the entire view port
#'   and uses the largest reasonable font size.
#'
#' @export
countdown_fullscreen <- function(
  minutes = 1,
  seconds = 0,
  ...,
  class = NULL,
  start_immediately = FALSE,
  font_size = "30vw",
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
    minutes,
    seconds,
    class = c("countdown-fullscreen", class),
    font_size = font_size,
    border_width = border_width,
    border_radius = border_radius,
    margin = margin,
    padding = padding,
    start_immediately = start_immediately,
    top = top,
    right = right,
    bottom = bottom,
    left = left,
    ...
  )
}

# ---- Style Countdown ----

#' @describeIn countdown Set global default countdown timer styles using CSS.
#'   Use this function to globally style all countdown timers in a document or
#'   app. Individual timers can still be customized.
#' @param .selector In `countdown_style()`: the CSS selector to which the styles
#'   should be applied. The default is `:root` for global styles, but you can
#'   also provide a custom class name to create styles for a particular class.
#' @export
countdown_style <- function(
  font_size = "3rem",
  margin = "0.6em",
  padding = "10px 15px",
  box_shadow = "0px 4px 10px 0px rgba(50, 50, 50, 0.4)",
  border_width = "0.1875 rem",
  border_radius = "0.9rem",
  line_height = "1",
  color_border = "#ddd",
  color_background = "inherit",
  color_text = "inherit",
  color_running_background = "#43AC6A",
  color_running_border = prismatic::clr_darken(color_running_background, 0.1),
  color_running_text = NULL,
  color_finished_background = "#F04124",
  color_finished_border = prismatic::clr_darken(color_finished_background, 0.1),
  color_finished_text = NULL,
  color_warning_background = "#E6C229",
  color_warning_border = prismatic::clr_darken(color_warning_background, 0.1),
  color_warning_text = NULL,
  .selector = "root"
) {
  # get user args and defaults of current call
  arg_names <- names(formals(countdown_style))
  arg_names <- setdiff(arg_names, ".selector")
  dots <- lapply(arg_names, get, envir = environment())
  names(dots) <- arg_names

  css_vars <- make_countdown_css_vars(.list = dots)
  declarations <- css(!!!css_vars)

  tags$style(HTML(sprintf(":%s {%s}", .selector, declarations)))
}

make_countdown_css_vars <- function(..., .list = list()) {
  dots <- compact(c(list(...), .list))

  if (length(dots) == 0) {
    return(NULL)
  }

  # Set text based on background color, if provided
  # Users can set the text color to "" (empty string to disable this)
  states <- c("running", "finished", "warning")
  for (state in states) {
    fg <- paste0("color_", state, "_text")
    bg <- paste0("color_", state, "_background")

    if (is.null(dots[[fg]]) && !is.null(dots[[bg]])) {
      dots[[fg]] <- choose_dark_or_light(dots[[bg]])
    }
  }


  names(dots) <- paste0(
    "--countdown-",
    gsub("_", "-", names(dots))
  )
  dots
}
