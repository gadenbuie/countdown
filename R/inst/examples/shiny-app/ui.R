library(shiny)
library(bslib)
library(countdown)

ui <- page_fixed(
  title = "{countdown} - Example Shiny App",
  div(
    class = "container",
    h2("Simple {countdown} Timer App"),
    p("Here's a simple timer, created with the {countdown} package."),
    HTML('<pre><code>countdown(id = "countdown")</code></pre>'),
    countdown(
      id = "countdown",
      class = "inline"
    ),
    p(
      "The countdown timer reports the state of the timer whenever key actions",
      "are performed. On the Shiny side, the input ID is the same as the timer's",
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
    uiOutput("buttons", inline = TRUE),
    tags$style("body, pre, .btn { font-size: 16px }")
  )
)
