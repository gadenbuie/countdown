# countdown (development version)

## Breaking changes

* The first `countdown()` timer no longer provides global styles for all other
  countdown timers. Instead, use `countdown_style()` with the same style-related
  arguments to set global styles for all countdown timers. (#36)

## New features and improvements

* The countdown JavaScript implementation was entirely re-written as a custom
  `<countdown-timer>` element. This improves lifecycle management of the timer
  component, making it possible to use countdown timers with dynamic UI in
  Shiny apps. (#59)

* Rewritten countdown timer CSS now uses CSS variables rather than a template
  rendered in R. This improves how countdown's dependencies are handled and
  makes it easier to customize and use countdown in other projects and
  settings. (#36)

* Implemented emitting of native browser events alongside Shiny communication. (#37)

* Added two new event types: `"finished"` when the timer completes its cycle
  and `"warning"` when it reaches the warning period. (#37)

* Set `class = "inline"` in `countdown()` to create an inline, rather than
  absolute-positioned, countdown timer. (#36)

* Set `class = "no-controls"` in `countdown()` to create a countdown timer
  without the controls. (#40)

## Bug fixes

* Fixed an issue where custom URLs for `play_sound` were not used for the timer
  end sound. (thanks @jannismain, #38)

* Fixed `countdown_fullscreen()` not passing along `class` and `start_immediately` parameters. (#43)

## Changes

* Switched to using `{bslib}` to stylize the demo countdown shiny app. (#37)

* Clarified `play_sound` documentation to emphasize custom sounds require the
  `countdown` clock to be embedded in a website, presentation, or Shiny app to
  be played due to JavaScript limitations on local files. (#44)

# countdown 0.4.0

* {countdown} now uses {prismatic} for color calculations.

* The JavaScript implementation of countdown has been completely rewritten. It
  now supports a wide range of new interactions:

    * Start, pause, and reset the timer (click, click again, double click).

    * `+` or `-` buttons to bump timer up or down.

    * Keyboard shortcuts: Space/Enter to start/stop, Escape to reset, and up/down
      arrows to bump timer.

    * The timers now work on mobile devices (in particular in xaringan slides).

* countdown timers can now be used in or controlled by Shiny apps:

    * Use `countdown_update()` to update key initial timer settings.

    * Use `countdown_action()` to trigger common action: start, stop, reset,
      bump up or bump down.

    * State changes are reported back to the Shiny app, e.g. Shiny apps can
      use `input$timer` to receive event data from the timer with
      `id = "timer"`.

    * `countdown_shiny_example()` runs a Shiny app that demonstrates key
      Shiny app features.

* Timers can now start immediately by setting the argument
  `start_immediately = TRUE`. When `TRUE`, timers will start as soon as they
  are visible. This feature works in xaringan slides, Quarto slides and general
  HTML web pages (thanks @Dr-Joe-Roberts, @davidkane9, #12).

* The `countdown_app()` now supports bookmarking, making it possible to share
  pre-configured timer URLs. This feature improves the usability of the
  timer available at <https://apps.garrickadenbuie.com/countdown>.


# countdown 0.3.5

* Any sound file hosted online can no be played in place of the default sound
  by setting `play_sound` to the absolute or relative URL of the sound file.

* The default CSS styles were updated for better automatic vertical centering
  of the countdown digits.

# countdown 0.3.3

* Added `.countdown-time` class to `<code>` element of timer. Renamed `.digits`
  class to `.countdown-digits`. This ensures that it's possible to write CSS
  rules with high specificity values (#10).

* Added `style` argument to `countdown()` for inlining CSS rules to the parent
  `div` of the timer.

# countdown 0.3.0

* Added a warning state to the coundown timer that is enabled by setting
  `warn_when = N`. The `warning` class is applied to the timer for the last `N`
  seconds, and the colors of this state are configured with the arguments with
  `color_warning_` prefix (thanks @hadley, #5).

* Added a new convenience function for full-screen (and stand-alone) countdown
  timers, `countdown_fullscreen()`. This function's defaults work best when
  called from RStudio, in xaringan slides it will still be necessary to fiddle
  with `font_size`, `margin`, and `padding` (thanks @hadley, #6).

* Add `countdown_app()` to launch an interactive Shiny app with a full-screen
  countdown timer.

# countdown 0.2.0

* Added `update_every` argument to `countdown()` to only update the timer every
  N seconds. Normal updating (second-by-second) is always used for the last
  two periods of the countdown time. Thanks @mine-cetinkaya-rundel for the
  suggestion.

* Added `blink_colon` argument to `countdown()` to animate the `:` in the
  countdown timer colon to blink every second. Enabled by default when the
  `update_every` interval is greater than 1 to provide feedback that the timer
  is running.
