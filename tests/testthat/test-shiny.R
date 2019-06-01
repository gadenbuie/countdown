context("test-shiny")

describe("countdown_app()", {

  it("errors if shiny not available", {
    with_mock(
      requireNamespace = function(...) FALSE,
      expect_error(countdown_app())
    )
  })

})
