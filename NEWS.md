# countdown 0.2.0

* Added `update_every` argument to `countdown()` to only update the timer every
  N seconds. Normal updating (second-by-second) is always used for the last
  two periods of the countdown time. Thanks @mine-cetinkaya-rundel for the
  suggestion.
  
* Added `blink_colon` argument to `countdown()` to animate the `:` in the 
  countdown timer colon to blink every second. Enabled by default when the 
  `update_every` interval is greater than 1 to provide feedback that the timer 
  is running.
