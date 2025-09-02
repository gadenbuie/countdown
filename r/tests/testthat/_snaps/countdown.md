# countdown() structure snapshot

    Code
      cat(format(countdown(minutes = 1, seconds = 30, id = "timer_1", class = "extra-class",
        warn_when = 15, update_every = 10, start_immediately = TRUE, blink_colon = TRUE,
        play_sound = TRUE)))
    Output
      <countdown-timer class="countdown extra-class" id="timer_1" minutes="1" seconds="30" warn-when="15" update-every="10" play-sound="true" blink-colon="true" start-immediately="true" tabindex="0" style="right:0;bottom:0;"></countdown-timer>

