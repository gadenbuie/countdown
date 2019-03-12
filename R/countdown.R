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
#' @param bottom Position of the timer within its container. By default `top` is
#'   unset (`NULL`).
#' @param border_color Color of the timer border when not yet activated.
#' @param border_width Width of the timer border (all states).
#' @param border_radius Radius of timer border corners (all states).
#' @param box_shadow Shadow specification for the timer, set to `NULL` to remove
#'   the shadow.
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
  font_size = "3em",
  margin = "0.5em",
  padding = "0 15px",
  right = if (is.null(top)) "0",
  bottom = if (is.null(left)) "0",
  top = NULL,
  left = NULL,
  border_color = "#ddd",
  border_width = "3px",
  border_radius = "15px",
  box_shadow = "0px 4px 10px 0px rgba(50, 50, 50, 0.4)",
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
    uid <- system('Rscript -e "countdown:::make_unique_id()"', intern = TRUE)
    id <- paste0("timer_", uid)
  }

  class <- unique(c("countdown", class))

  x <- div(
    class = paste(class, collapse = " "), id = id,
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

  tmpdir <- tempfile("countdown")
  dir.create(tmpdir)
  file.copy(system.file("countdown.js", package = "countdown"),
            file.path(tmpdir, "countdown.js"))

  css_template <- readLines(system.file("countdown.css", package = "countdown"))
  css <- whisker::whisker.render(css_template)
  css_file <- file.path(tmpdir, "countdown.css")
  writeLines(css, css_file)

  htmltools::htmlDependencies(x) <- htmlDependency(
      "countdown",
      version = packageVersion("countdown"),
      src = gsub("//", "/", dirname(css_file)),
      script = "countdown.js",
      stylesheet = "countdown.css"
    )

  x
}


darken_color <- function(color_hex, strength = 0.8) {
  stopifnot(strength >= 0 && strength <= 1)
  color_rgb <- col2rgb(color_hex)[, 1]
  color_rgb <- (1 - strength) * color_rgb
  rgb(color_rgb[1], color_rgb[2], color_rgb[3], maxColorValue = 255)
}

choose_dark_or_light <- function(x, black = "#000000", white = "#FFFFFF") {
  # x = color_hex
  # black <- substitute(black)
  # white <- substitute(white)
  color_rgb <- col2rgb(x)[, 1]
  # from https://stackoverflow.com/a/3943023/2022615
  color_rgb <- color_rgb / 255
  color_rgb[color_rgb <= 0.03928] <- color_rgb[color_rgb <= 0.03928]/12.92
  color_rgb[color_rgb > 0.03928] <- ((color_rgb[color_rgb > 0.03928] + 0.055)/1.055)^2.4
  lum <- t(c(0.2126, 0.7152, 0.0722)) %*% color_rgb
  if (lum[1, 1] > 0.179) eval(black) else eval(white)
}

make_unique_id <- function() {
  cat(sample(c(letters[1:6], 0:9), 8, replace = TRUE), sep = "")
}
