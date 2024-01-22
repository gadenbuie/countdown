# countdown() structure snapshot

    Code
      cat(format(countdown(minutes = 1, seconds = 30, id = "timer_1", class = "extra-class",
        warn_when = 15, update_every = 10, start_immediately = TRUE, blink_colon = TRUE,
        play_sound = TRUE)))
    Output
      <div class="countdown extra-class" id="timer_1" data-warn-when="15" data-update-every="10" data-play-sound="true" data-blink-colon="true" data-start-immediately="true" tabindex="0" style="right:0;bottom:0;">
        <div class="countdown-controls"><button class="countdown-bump-down">&minus;</button><button class="countdown-bump-up">&plus;</button></div>
        <code class="countdown-time"><span class="countdown-digits minutes">01</span><span class="countdown-digits colon">:</span><span class="countdown-digits seconds">30</span></code>
      </div>

