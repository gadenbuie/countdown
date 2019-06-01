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
