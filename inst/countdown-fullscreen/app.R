library(shiny)
library(countdown)
options(htmltools.dir.version = FALSE)

ui <- basicPage(
    tags$head(tags$style(
        "iframe { height: 99vh; }",
        "#about:hover { text-decoration: none; }"
    )),
    fluidRow(
        style = "padding-top: 1em",
        column(
            class = "text-center col-md-3",
            width = 4,
            h1(actionLink("about", "Countdown"), style = "line-height: 20px")
        ),
        column(
            class = "text-center col-md-9",
            width = 8,
            div(
                class = "form-inline",
                selectInput("minutes", "Minutes", choices = sprintf("%02d", 0:99), selected = "05", width = "20%"),
                selectInput("seconds", "Seconds", choices = sprintf("%02d", 0:59), selected = "00", width = "20%"),
                selectInput("warn_when", "Warning (s)", choices = sprintf("%02d", 0:(99*60)), selected = "00", width = "20%"),
                selectInput("update_every", "Update Every (s)", choices = sprintf("%02d", 1:(60*5)), selected = "01", width = "20%"),
                # checkboxInput("play_sound", "Play Sound", value = FALSE, width = "10%"),
                actionButton("reset", "Reset", class = "btn-primary", style = "margin-top: 5px")
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
                # play_sound = input$play_sound,
                line_height = "94vh"
            ),
            file = file.path(getwd(), tmpfile)
        )

        tmpfile <- sub("www/", "", tmpfile)
        tags$iframe(src = tmpfile, width = "100%", height = "100vh")
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
