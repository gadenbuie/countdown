library(shiny)
library(countdown)
options(htmltools.dir.version = FALSE)

utc0 <- function(x) {
  x <- as.integer(x)
  as.POSIXct(x, tz = "UTC", origin = "1970-01-01")
}

slider_col_class <- "col-md-2 col-xs-8 col-xs-offset-2 col-sm-offset-0"

ui <- basicPage(
  tags$head(tags$style(
    "iframe { height: 99vh; }",
    "#about:hover { text-decoration: none; }",
    ".sliders div { margin-right: 2em; }",
    # BS .fivecolumns from https://stackoverflow.com/a/18006074/2022615
    "
@media (min-width: 768px){
    .fivecolumns .col-md-2, .fivecolumns .col-sm-2, .fivecolumns .col-lg-2  {
        width: 20%;
        *width: 20%;
    }
}
@media (min-width: 1200px) {
    .fivecolumns .col-md-2, .fivecolumns .col-sm-2, .fivecolumns .col-lg-2 {
        width: 20%;
        *width: 20%;
    }
}
@media (min-width: 768px) and (max-width: 979px) {
    .fivecolumns .col-md-2, .fivecolumns .col-sm-2, .fivecolumns .col-lg-2 {
        width: 20%;
        *width: 20%;
    }
}
    "
  )),
  fluidRow(
    style = "padding-top: 1em; padding-bottom: 1em;",
    column(
      class = "text-center col-md-3",
      width = 4,
      h1(actionLink("about", "Countdown"), style = "line-height: 35px")
    ),
    column(
      class = "text-center col-md-9",
      width = 8,
      fluidRow(
        class = "fivecolumns",
        column(
          width = 12,
          class = slider_col_class,
          sliderInput("minutes", "Minutes", value = 5L, width = "100%",
                      min = 0, max = 99, step = 1L)
        ),
        column(
          width = 12,
          class = slider_col_class,
          sliderInput("seconds", "Seconds", value = 0L, width = "100%",
                      min = 0, max = 59, step = 5L)
        ),
        column(
          width = 12,
          class = slider_col_class,
          sliderInput("warn_when", "Warning", value = utc0(60), width = "100%",
                      min = utc0(0), max = utc0(5*60), timeFormat = "%M:%S", step = 1L)
        ),
        column(
          width = 12,
          class = slider_col_class,
          sliderInput("update_every", "Update Every", value = utc0(1), width = "100%",
                      min = utc0(0), max = utc0(1*60), step = 5L, timeFormat = "%M:%S")
        ),
        column(
          width = 12,
          class = "col-md-2 col-xs-12",
          actionButton("reset", "Reset", class = "btn-primary", style = "margin-top: 18px")
        )
      )
    )
  ),
  fluidRow(
    column(
      width = 12,
      uiOutput("timer")
    )
  )
)

server <- function(input, output, session) {
  session_token <- session$token

  session_dir <- file.path("www", "tmp", session_token)
  dir.create(session_dir)

  onSessionEnded(function() unlink(session_dir, recursive = TRUE))

  output$timer <- renderUI({
    input$reset
    tmpfile <- tempfile("countdown", session_dir, ".html")
    htmltools::save_html(
      countdown_fullscreen(
        minutes = as.integer(input$minutes),
        seconds = as.integer(input$seconds),
        warn_when = as.integer(input$warn_when),
        update_every = as.integer(input$update_every),
        line_height = "94vh"
      ),
      file = file.path(getwd(), tmpfile)
    )

    tmpfile <- sub("www/", "", tmpfile)
    tags$iframe(src = tmpfile, width = "100%", height = "100vh")
  })

  observe({
    min <- input$minutes
    sec <- input$seconds
    s <- min * 60 + sec
    updateSliderInput(session, "warn_when", value = utc0(floor(s/5)), max = utc0(s), timeFormat = "%M:%S")
  })

  observeEvent(input$about, {
    showModal(
      modalDialog(
        title = "About Countdown",
        p(
          code(a("countdown", href = "https://pkg.garrickadenbuie.com/countdown")),
          "is a small R package for creating HTML-based timers.",
          "Learn", em("why"), "and", em("how"), "at",
          a("pkg.garrickadenbuie.com/countdown.", href = "https://pkg.garrickadenbuie.com/countdown")
        ),
        p(
          style = "padding-top: 3em",
          "By Garrick Aden-Buie", br(),
          a("garrickadenbuie.com", href = "https://www.garrickadenbuie.com")
        )
      )
    )
  })
}

shinyApp(ui = ui, server = server)
