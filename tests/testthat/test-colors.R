context("test-colors")

test_that("col2rgb()", {
  expect_col2rgb <- function(hex, rgb) {
    rgb <- setNames(rgb, c("red", "green", "blue"))
    expect_equal(col2rgb(hex), rgb)
  }
  expect_col2rgb("#08f", col2rgb("#0088ff"))
  expect_col2rgb("#282828", c(40, 40, 40))
  expect_col2rgb("#fff", c(255, 255, 255))
  expect_col2rgb("#808080", c(128, 128, 128))
  expect_col2rgb("firebrick3", c(205, 38, 38))
  expect_error(col2rgb("#80"))
  expect_error(col2rgb("#8097"))
})

test_that("darken()", {
  expect_equal(darken("beige", 0.1), "#DCDCC6")
  expect_equal(darken("#f5f5dc", 0.1), "#DCDCC6")
  expect_equal(darken("beige", 1), "#000000")
  expect_error(darken("red", 2))
  expect_error(darken("red", -1))
})

test_that("lighten()", {
  expect_equal(lighten("beige", 0.1), "#F6F6DF")
  expect_equal(lighten("#f5f5dc", 0.1), "#F6F6DF")
  expect_equal(lighten("beige", 1), "#FFFFFF")
  expect_error(lighten("red", 2))
  expect_error(lighten("red", -1))
})

test_that("rgb2hex()", {
  expect_equal(rgb2hex(col2rgb("firebrick3")), "#CD2626")
  expect_equal(rgb2hex(c(205, 38, 38)), "#CD2626")
})

test_that("choose_dark_or_light()", {
  expect_equal(choose_dark_or_light("#FFFFFF", black = "#000000"), "#000000")
  expect_equal(choose_dark_or_light("#000000", white = "#FFFFFF"), "#FFFFFF")
  expect_equal(choose_dark_or_light("firebrick3", white = "#FFFFFF"), "#FFFFFF")
  expect_equal(choose_dark_or_light("#cd2626",    white = "#FFFFFF"), "#FFFFFF")
  expect_equal(choose_dark_or_light("lightblue1", black = "#000000"), "#000000")
  expect_equal(choose_dark_or_light("#bfefff",    black = "#000000"), "#000000")
  expect_equal(choose_dark_or_light("lightblue1", "firebrick3"), "#CD2626")
})
