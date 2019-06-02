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

ui <- basicPage(
  tags$head(tags$style(
    "@import url('https://fonts.googleapis.com/css?family=Nova+Square');",
    "iframe { height: 99vh; border: none; }",
    "#about:hover, #about:active, #about:focus { text-decoration: none; color: #28A5CA; }",
    "#about { font-family: 'Nova Square'; color: #4389A0; }"
  )),
  includeCSS("www/bootstrap.min.css"), # https://bootswatch.com/3/slate/
  tags$head(tags$style(
    ".form-control { background: #3E444C !important; color: #ddd !important; }"
  )),
  fluidRow(
    style = "padding-top: 1em; padding-bottom: 1em;",
    column(
      class = "text-center col-md-3",
      width = 4,
      h1(actionLink("about", "countdown", class = "text-info"), style = "line-height: 35px")
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
            selected = "1 sec",
            selectize = FALSE
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
  clean_session_files <- function() {
    message("Cleaning up session files: ", session_dir)
    unlink(session_dir, recursive = TRUE)
  }

  onStop(clean_session_files)

  timer <- reactive({
    req(input$time)
    countdown:::parse_mmss(input$time)
  })

  warn_when <- reactive({
    x <- countdown:::parse_mmss(input$warn_time)
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
      htmltools::tagList(
        htmltools::tags$head(htmltools::tags$style(
          "@import url('https://fonts.googleapis.com/css?family=Roboto+Mono');",
          ".countdown .digits { font-family: 'Roboto Mono'; }"
        )),
        countdown_fullscreen(
          minutes = as.integer(timer()$minutes),
          seconds = as.integer(timer()$seconds),
          warn_when = as.integer(warn_when()$seconds),
          update_every = as.integer(input$update_every),
          line_height = "94vh",
          border_width = "5px",
          color_border = "#7A8288",
          color_background = "#272B30",
          color_text = "#C8C8C8",
          # color_running_background = "#102B1A",
          color_running_text = "#43AC6A",
          color_running_background = "#272B30",
          color_running_border = "#272B30",
          color_warning_text = "#E6C229",
          color_warning_background = "#272B30",
          color_warning_border = "#E6C229",
          # color_warning_background = darken("#E6C229", 0.6),
          color_finished_background = "#F04124",
          color_finished_text = "#272B30"
        )
      ),
      file = file.path(getwd(), tmpfile)
    )

    tmpfile <- sub("www/", "", tmpfile)
    tags$iframe(src = tmpfile, width = "100%", height = "100vh")
  })

  observe({
    req(timer()$minutes)
    req(timer()$minutes + timer()$seconds > 0)
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
          a("countdown", href = "https://pkg.garrickadenbuie.com/countdown"),
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
