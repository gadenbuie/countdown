choose_dark_or_light <- function(x, dark = NULL, light = NULL, strength = 0.75) {
  dark <- dark %||% prismatic::clr_darken(x, shift = strength)
  light <- light %||% prismatic::clr_lighten(x, shift = strength)
  prismatic::best_contrast(x, c(dark, light))
}
