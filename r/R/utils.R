`%||%` <- function(x, y) if (is.null(x)) y else x

compact <- function(.x) {
  .x[as.logical(vapply(.x, length, NA_integer_))]
}

make_unique_id <- function() {
  with_private_seed <- utils::getFromNamespace("withPrivateSeed", "htmltools")
  with_private_seed({
    rand_id <- as.hexmode(sample(256, 4, replace = TRUE) - 1)
    paste(format(rand_id, width = 2), collapse = "")
  })
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
    stop_because(
      "Cannot contain the character",
      if (nchar(invalid) > 1) "s: ",
      invalid
    )
  }
  id
}
