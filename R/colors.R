
#' @importFrom grDevices rgb
darken_color <- function(x, strength = 0.8) {
  stopifnot(strength >= 0 && strength <= 1)
  color_rgb <- col2rgb(x)
  color_rgb <- (1 - strength) * color_rgb
  rgb(color_rgb[1], color_rgb[2], color_rgb[3], maxColorValue = 255)
}

choose_dark_or_light <- function(x, black = "#000000", white = "#FFFFFF") {
  color_rgb <- col2rgb(x)
  # from https://stackoverflow.com/a/3943023/2022615
  color_rgb <- color_rgb / 255
  color_rgb[color_rgb <= 0.03928] <- color_rgb[color_rgb <= 0.03928]/12.92
  color_rgb[color_rgb > 0.03928] <- ((color_rgb[color_rgb > 0.03928] + 0.055)/1.055)^2.4
  lum <- t(c(0.2126, 0.7152, 0.0722)) %*% color_rgb
  chosen_color <- if (lum[1, 1] > 0.179) black else white
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
