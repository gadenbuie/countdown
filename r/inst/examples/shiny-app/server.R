library(shiny)
library(countdown)

server <- function(input, output, session) {
  output$debug <- renderPrint({
    str(input$countdown)
  })

  timer_is_running <- reactiveVal(FALSE)

  observeEvent(input$countdown, {
    req(input$countdown)
    is_running <- input$countdown$timer$is_running
    if (is_running != timer_is_running()) {
      timer_is_running(is_running)
    }
  })

  output$buttons <- renderUI({
    is_running <- timer_is_running()

    div(
      class = "btn-group",
      actionButton("start", "Start", icon = icon("play")),
      actionButton("stop", "Stop", icon = icon("pause")),
      actionButton("reset", "Reset", icon = icon("sync")),
      if (is_running) {
        actionButton("bumpUp", "Bump Up", icon = icon("arrow-up"))
      },
      if (is_running) {
        actionButton("bumpDown", "Bump Down", icon = icon("arrow-down"))
      }
    )
  })

  observeEvent(input$start, countdown_action("countdown", "start"))
  observeEvent(input$stop, countdown_action("countdown", "stop"))
  observeEvent(input$reset, countdown_action("countdown", "reset"))
  observeEvent(input$bumpUp, countdown_action("countdown", "bumpUp"))
  observeEvent(input$bumpDown, countdown_action("countdown", "bumpDown"))
}
