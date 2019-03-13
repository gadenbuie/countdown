context("test-countdown")

test_that("countdown html_dependency", {
  x <- countdown(1)

  x_deps <- htmltools::htmlDependencies(x)[[1]]

  expect_equal(x_deps$name, "countdown")
  expect_equal(x_deps$script, "countdown.js")
  expect_equal(x_deps$stylesheet, "countdown.css")
  expect_true(inherits(x_deps, "html_dependency"))

})

dir.create(here::here("tests", "testthat", "css_template"), showWarnings = FALSE)

test_that("countdown css template", {
  test_template_file <- function(x, compare_to_filename) {
    x_deps <- htmltools::htmlDependencies(x)[[1]]
    css_template <- readLines(file.path(x_deps$src, x_deps$stylesheet))
    expect_known_output(cat(css_template, sep = "\n"),
                        test_path("css_template", compare_to_filename))
  }

  test_template_file(countdown(), "countdown_default.css")
  test_template_file(countdown(top = 0, left = 0), "countdown_top-left.css")
  test_template_file(countdown(font_size = "1em",
                               color_border = "#123abc",
                               border_width = "2px",
                               border_radius = "5px"),
                     "countdown_font-and-border.css")
  test_template_file(countdown(box_shadow = NULL), "countdown_no-shadow.css")
  test_template_file(countdown(margin = 0, padding = "12px"), "countdown_margin-padding.css")

  test_template_file(countdown(color_running_background = "firebrick3"), "countdown_running-colors.css")
  test_template_file(countdown(color_finished_background = "magenta2"), "countdown_finished-colors.css")
})

test_that("countdown()", {
  x <- countdown(1, 30, id = "timer_1", class = "extra-class")

  expect_true(attr(x, "browsable_html"))
  expect_true(inherits(x, "shiny.tag"))
  expect_equal(x$name, "div")
  expect_equal(x$attribs$class, "countdown extra-class")
  expect_equal(x$attribs$id, "timer_1")
  expect_equal(x$children[[1]]$name, "code")

  test_inner_html <- function(counter, ...) {
    counter_inner <- as.character(counter$children[[1]]$children[[1]])
    expect_equal(counter_inner, paste0(...))
  }

  test_inner_html(x,
                  "<span class=\"digits minutes\">01</span>",
                  "<span class=\"digits colon\">:</span>",
                  "<span class=\"digits seconds\">30</span>")

  # seconds and minutes get added
  test_inner_html(countdown(10.05, 65),
                  "<span class=\"digits minutes\">11</span>",
                  "<span class=\"digits colon\">:</span>",
                  "<span class=\"digits seconds\">08</span>")

  expect_equal(countdown(class = "countdown")$attribs$class, "countdown")
  expect_equal(countdown(class = c("test", "countdown", "test"))$attribs$class, "countdown test")


  expect_error(countdown(100), "minutes")
})

test_that("make_unique_id is always unique", {
  set.seed(4242)
  id1 <- make_unique_id()

  set.seed(4242)
  id2 <- make_unique_id()

  expect_true(id1 != id2)
})

test_that("validates HTML ids", {
  expect_equal(validate_html_id("timer_001"), "timer_001")
  expect_error(validate_html_id("001"), "letter")
  expect_error(validate_html_id("timer&%$&1"), "characters")
  expect_error(validate_html_id("timer#1"), "character")
})
