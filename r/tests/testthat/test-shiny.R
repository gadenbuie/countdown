# test_that()

describe("countdown_app()", {
  local_edition(2)

  it("errors if shiny not available", {
    local_mocked_bindings(
      has_shiny = function(...) FALSE
    )
  })

})

describe("parse_mmmss()", {

  it("parses MM and MM:SS", {
    expect_time <- function(object, time) {
      time <- list(minutes = time[1], seconds = time[2])
      expect_equal(object, time)
    }

    expect_time(parse_mmss("05:00"), c(5, 0))
    expect_time(parse_mmss("5"), c(5, 0))
    expect_time(parse_mmss("5:0"), c(5, 0))
    expect_time(parse_mmss(""), c(0, 0))
  })

  it("returns list(error) with incorrectly formatted times", {
    expect_parse_error <- function(time) {
      expect_true(!is.null(parse_mmss(time)$error), time)
    }

    expect_parse_error("5:")
    expect_parse_error(":5")
    expect_parse_error("050:0")
    expect_parse_error("5 minutes")
    expect_parse_error("0500")
    expect_parse_error("111")
  })

})

