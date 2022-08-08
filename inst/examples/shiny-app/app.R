library(shiny)

ui <- fluidPage(
  div(
    class = "container",
    h2("Simple {countdown} Timer App"),
    p("Here's a simple timer, created with the {countdown} package."),
    withTags(.noWS = "inside", pre(code('countdown(id = "countdown")'))),
    countdown(id = "countdown", style = "position:relative;width: 5em;max-width: 100%;"),
    p(
      "The countdown timer reports the state of the timer whenever key actions",
      "are perfomed. On the Shiny side, the input ID is the same as the timer's",
      "ID - in this case", code("input$countdown"), "— and the data sent to",
      "Shiny reports both the action taken by the user and the current state",
      "of the timer."
    ),
    verbatimTextOutput("debug"),
    p(
      "You may also use the", code("countdown_action()"), "button to trigger",
      "actions with the timer from Shiny. Interact with the timer directly or",
      "use the buttons below to start, stop, reset, or bump the timer up or down."
    ),
    uiOutput("buttons", inline = TRUE)
  )
)

server <- function(input, output, session) {
  output$debug <- renderPrint(str(input$countdown))

  output$buttons <- renderUI({
    is_running <- !is.null(input$countdown) && input$countdown$timer$is_running

    div(
      class = "btn-group",
      actionButton("start", "Start", icon = icon("play")),
      actionButton("stop",  "Stop",  icon = icon("pause")),
      actionButton("reset", "Reset", icon = icon("sync")),
      if (is_running) {
        actionButton("bumpUp", "Bump Up", icon = icon("arrow-up"))
      },
      if (is_running) {
        actionButton("bumpDown", "Bump Down", icon = icon("arrow-down"))
      }
    )
  })

  observeEvent(input$start,    countdown_action("countdown", "start"))
  observeEvent(input$stop,     countdown_action("countdown", "stop"))
  observeEvent(input$reset,    countdown_action("countdown", "reset"))
  observeEvent(input$bumpUp,   countdown_action("countdown", "bumpUp"))
  observeEvent(input$bumpDown, countdown_action("countdown", "bumpDown"))
}

shinyApp(ui = ui, server = server)
