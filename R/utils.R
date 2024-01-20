compact <- function(.x) {
  .x[as.logical(vapply(.x, length, NA_integer_))]
}
