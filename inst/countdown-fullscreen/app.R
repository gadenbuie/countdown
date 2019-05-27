library(shiny)
library(countdown)
options(htmltools.dir.version = FALSE)

utc0 <- function(x) {
  x <- as.integer(x)
  as.POSIXct(x, tz = "UTC", origin = "1970-01-01")
}

inputs_col_class <- "col-md-3 col-xs-8 col-xs-offset-2 col-sm-offset-0"

update_every_choices <- setNames(
  c(1, 5, 10, 15, 30, 60),
  c(paste(c(1, 5, 10, 15, 30), "sec"), "1 min")
)

parse_mmss <- function(x = "") {
  error_msg <- list(error = "Please enter a time as MM:SS")
  valid <- TRUE
  if (is.null(x) || x == "") return(list(minutes = 0L, seconds = 0L))
  if (!grepl(":", x)) valid <- FALSE
  if (!grepl("\\d", x)) valid <- FALSE
  if (!valid) return(error_msg)
  m <- regexec("([0-9]{1,2}):([0-9]{1,2})", x)
  x <- regmatches(x, m)[[1]]
  if (length(x) != 3) return(error_msg)
  list(minutes = as.integer(x[2]), seconds = as.integer(x[3]))
}

ui <- basicPage(
  tags$head(tags$style(
    "iframe { height: 99vh; border: none; }",
    "#about:hover { text-decoration: none; }"
  )),
  fluidRow(
    style = "padding-top: 1em; padding-bottom: 1em;",
    column(
      class = "text-center col-md-3",
      width = 4,
      h1(actionLink("about", "Countdown"), style = "line-height: 35px")
    ),
    column(
      class = "text-left col-md-9",
      width = 8,
      fluidRow(
        column(
          width = 12,
          class = inputs_col_class,
          textInput("time", "Time", value = "5:00", placeholder = "MM:SS"),
          uiOutput("timer_error_ui")
        ),
        column(
          width = 12,
          class = inputs_col_class,
          textInput("warn_time", "Warn Time Remaining", value = "1:00", placeholder = "MM:SS"),
          uiOutput("warn_time_error_ui")
        ),
        column(
          width = 12,
          class = inputs_col_class,
          selectInput(
            "update_every", "Update Every",
            choices = update_every_choices,
            selected = "1 sec"
          )
        ),
        column(
          width = 12,
          class = "col-md-2 col-xs-12 text-center",
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

  timer <- reactive({
    parse_mmss(input$time)
  })

  warn_when <- reactive({
    x <- parse_mmss(input$warn_time)
    x$seconds <- x$minutes * 60 + x$seconds
    x
  })

  output$timer_error_ui <- renderUI({
    req(timer()$error)
    p(class = "text-danger small text-left", timer()$error)
  })

  output$warn_time_error_ui <- renderUI({
    req(warn_when()$error)
    p(class = "text-danger small text-left", warn_when()$error)
  })

  output$timer <- renderUI({
    req(timer()$minutes, warn_when()$seconds)
    input$reset
    tmpfile <- tempfile("countdown", session_dir, ".html")
    htmltools::save_html(
      countdown_fullscreen(
        minutes = as.integer(timer()$minutes),
        seconds = as.integer(timer()$seconds),
        warn_when = as.integer(warn_when()$seconds),
        update_every = as.integer(input$update_every),
        line_height = "94vh",
        border_radius = "15px",
        border_width = "3px"
      ),
      file = file.path(getwd(), tmpfile)
    )

    tmpfile <- sub("www/", "", tmpfile)
    tags$iframe(src = tmpfile, width = "100%", height = "100vh")
  })

  observe({
    req(timer()$minutes)
    s_update_every <- isolate(input$update_every)
    s <- timer()$minutes * 60 + timer()$seconds
    c_update_every <- update_every_choices[update_every_choices <= s]
    if (!s_update_every %in% c_update_every) {
      s_update_every <- c_update_every[length(c_update_every)]
    }
    updateSelectInput(session, "update_every", choices = c_update_every,
                      selected = s_update_every)
  })

  observe({
    req(timer()$minutes)
    if (input$update_every == 1L) {
      min <- timer()$minutes
      sec <- timer()$seconds
      s <- (min * 60 + sec) * 0.2
    } else {
      s <- as.integer(input$update_every) * 2
    }
    min <- floor(s/ 60)
    sec <- s - min*60
    updateTextInput(session, "warn_time", value = sprintf("%02d:%02d", min, sec))
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
