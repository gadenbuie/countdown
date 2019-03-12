
darken_color <- function(x, strength = 0.8) {
  if (!is_hex_color(x)) return(x)
  stopifnot(strength >= 0 && strength <= 1)
  color_rgb <- col2rgb(x)
  color_rgb <- (1 - strength) * color_rgb
  rgb(color_rgb[1], color_rgb[2], color_rgb[3], maxColorValue = 255)
}

choose_dark_or_light <- function(x, black = "#000000", white = "#FFFFFF") {
  if (!is_hex_color(x)) return(sample(c(black, white), 1))
  color_rgb <- col2rgb(x)
  # from https://stackoverflow.com/a/3943023/2022615
  color_rgb <- color_rgb / 255
  color_rgb[color_rgb <= 0.03928] <- color_rgb[color_rgb <= 0.03928]/12.92
  color_rgb[color_rgb > 0.03928] <- ((color_rgb[color_rgb > 0.03928] + 0.055)/1.055)^2.4
  lum <- t(c(0.2126, 0.7152, 0.0722)) %*% color_rgb
  if (lum[1, 1] > 0.179) eval(black) else eval(white)
}

col2rgb <- function(x) {
  x <- sub("^#", "", x)
  if (!is_hex_color(x)) {
    stop(paste0('"', x, '" is not a hexadecimal color'))
  }
  stopifnot(length(x) == 1)

  str_c <- function(...) paste(..., collapse = "", sep = "")

  is_short <- nchar(x) == 3
  x <- strsplit(x, character(0))[[1]]
  value <- rep(0L, 3)
  for (i in 0:2) {
    if (is_short) {
      hex <- x[i + 1]
      hex <- str_c(hex, hex)
    } else {
      hex <- x[1:2 + i * 2]
    }
    value[i + 1] <- as.hexmode(str_c(hex))
  }
  as.integer(value)
}

is_hex_color <- function(x) {
  x <- sub("^#", "", x)
  wrong_number_of_chars <- nchar(x) != 3 && nchar(x) != 6
  has_bad_values <- nchar(gsub("[a-fA-F0-9]", "", x)) > 0
  !(wrong_number_of_chars || has_bad_values)
}
