#' @title Generate lighter or darker version of a color
#' @description Produces a linear blend of the color with white or black.
#' @param color_hex A character string representing a hex color
#' @param strength The "strength" of the blend with white or black,
#'   0 low to 1 high.
#' @importFrom grDevices rgb
#' @name lighten_darken_color
NULL

#' @rdname lighten_darken_color
#' @export
lighten <- function(color_hex, strength = 0.7) {
  stopifnot(strength >= 0 && strength <= 1)
  color_rgb <- col2rgb(color_hex)
  color_rgb <- (1 - strength) * color_rgb + strength * 255
  rgb(color_rgb[1], color_rgb[2], color_rgb[3], maxColorValue = 255)
}

#' @rdname lighten_darken_color
#' @export
darken <- function(color_hex, strength = 0.8) {
  stopifnot(strength >= 0 && strength <= 1)
  color_rgb <- col2rgb(color_hex)
  color_rgb <- (1 - strength) * color_rgb
  rgb(color_rgb[1], color_rgb[2], color_rgb[3], maxColorValue = 255)
}

#' Choose dark or light color
#'
#' Takes a color input as `x` and returns either the black or white color if
#' dark or light text should be used over the input color for best contrast.
#' Follows W3C Recommendations.
#'
#' @references <https://stackoverflow.com/a/3943023/2022615>
#' @param x The background color
#' @param black Text or foreground color, e.g. "#22222" or `darken(x, 0.8)`, if
#'   black text provides the best contrast. By default chooses the input color
#'   `x` darkened by `strength`.
#' @param white Text or foreground color or expression, e.g. "#EEEEEE" or
#'   `lighten(x, 0.8)`, if white text provides the best contrast. By default
#'   chooses the input color `x` lightened by `strength`.
#' @param strength Default strength by which `x` is darkened or lightened to
#'   arrive at a color approximating `black` or `white`. Default is 0.75 (75%);
#'   ignored if a value for `black` or `white` is provided.
choose_dark_or_light <- function(
  x,
  black = NULL,
  white = NULL,
  strength = 0.75
) {
  color_rgb <- col2rgb(x)
  # from https://stackoverflow.com/a/3943023/2022615
  color_rgb <- color_rgb / 255
  color_rgb[color_rgb <= 0.03928] <- color_rgb[color_rgb <= 0.03928]/12.92
  color_rgb[color_rgb > 0.03928] <- ((color_rgb[color_rgb > 0.03928] + 0.055)/1.055)^2.4
  lum <- t(c(0.2126, 0.7152, 0.0722)) %*% color_rgb
  chosen_color <- if (lum[1, 1] > 0.179) {
    black %||% darken(x, strength)
  } else {
    white %||% lighten(x, strength)
  }
  rgb2hex(col2rgb(chosen_color))
}

col2rgb <- function(x) {
  if (grepl("^#", x)) {
    x <- sub("^#", "", x)
    if (nchar(x) == 3) {
      x <- strsplit(x, character(0))[[1]]
      x <- rep(x, each = 2)
      x <- paste(x, collapse = "")
    } else if (nchar(x) != 6) {
      stop(paste0('"', x, '" is not a hexadecimal color'))
    }
    x <- paste0("#", x)
  }
  grDevices::col2rgb(x)[, 1]
}

rgb2hex <- function(x) {
  hex <- paste(as.hexmode(x))
  hex[nchar(hex) != 2] <- strrep(hex[nchar(hex) != 2], 2)
  hex <- paste(hex, collapse = "")
  paste0("#", toupper(hex))
}
