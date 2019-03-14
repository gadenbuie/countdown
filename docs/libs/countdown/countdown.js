var counters = {timer: {}};
var update_timer = function(timer) {
	var secs = timer.value;
  var mins = Math.floor(secs / 60); // 1 min = 60 secs
  secs -= mins * 60;

  // Update HTML
  timer.min.innerHTML = String(mins).padStart(2, 0);
  timer.sec.innerHTML = String(secs).padStart(2, 0);
}
var countdown = function (e) {
  target = e.target;
  if (target.classList.contains("digits")) {
    target = target.parentElement;
  }
  if (target.tagName == "CODE") {
    target = target.parentElement;
  }

  // Init counter
  if (!counters.timer.hasOwnProperty(target.id)) {
    counters.timer[target.id] = {};
    // Set the containers
	  counters.timer[target.id].min = target.getElementsByClassName("minutes")[0];
  	counters.timer[target.id].sec = target.getElementsByClassName("seconds")[0];
  	counters.timer[target.id].div = target;
  }

  if (!counters.timer[target.id].running) {
    if (!counters.timer[target.id].end) {
      counters.timer[target.id].end   = parseInt(counters.timer[target.id].min.innerHTML) * 60;
		  counters.timer[target.id].end  += parseInt(counters.timer[target.id].sec.innerHTML);
    }

    counters.timer[target.id].value = counters.timer[target.id].end;
    update_timer(counters.timer[target.id]);
    if (counters.ticker) counters.timer[target.id].value += 1;

    // Start if not past end date
    if (counters.timer[target.id].value > 0) {
      target.className = "countdown running";
      counters.timer[target.id].running = true;

      if (!counters.ticker) {
        counters.ticker = setInterval(counter_update_all, 1000);
      }
    }
  } else {
    // Bump timer value if running & clicked
    counters.timer[target.id].value += counter_bump_increment(counters.timer[target.id].end);
    update_timer(counters.timer[target.id]);
    counters.timer[target.id].value += 1;
  }
};

var counter_bump_increment = function(val) {
  if (val <= 30) {
    return 5;
  } else if (val <= 300) {
    return 15;
  } else if (val <= 3000) {
    return 30;
  } else {
    return 60;
  }
}

var counter_update_all = function() {
  // Iterate over all running timers
  for (var i in counters.timer) {
    // Stop if passed end time
    console.log(counters.timer[i].id)
    counters.timer[i].value--;
    if (counters.timer[i].value <= 0) {
      counters.timer[i].min.innerHTML = "00";
      counters.timer[i].sec.innerHTML = "00";
      counters.timer[i].div.className = "countdown finished";
      counters.timer[i].running = false;
    } else {
      // Update
      update_timer(counters.timer[i]);

      // Play countdown sound if data-audio=true on container div
      if (counters.timer[i].div.dataset.audio && counters.timer[i].value == 5) {
        counter_play_sound();
      }
    }
  }

  // If no more running timers, then clear ticker
  var timerIsRunning = false;
  for (var t in counters.timer) {
    timerIsRunning = timerIsRunning || counters.timer[t].running
  }
  if (!timerIsRunning) {
    clearInterval(counters.ticker);
    counters.ticker = null;
  }
}

var counter_play_sound = function() {
  try {
    var finished_sound = new Audio('libs/countdown/smb_stage_clear.mp3');
    finished_sound.play();
  } catch (e) {
    try {
      var finished_sound = new Audio('smb_stage_clear.mp3');
      finished_sound.play();
    } catch (e) {
      console.log("Unable to locate sound file smb_stage_clear.mp3.")
    }
  }
}

var counter_addEventListener = function() {
  if (!document.getElementsByClassName("countdown").length) {
    setTimeout(counter_addEventListener, 2);
    return;
  }
  var counter_divs = document.getElementsByClassName("countdown");
  console.log(counter_divs);
  for (var i = 0; i < counter_divs.length; i++) {
    counter_divs[i].addEventListener("click", countdown, false);
  }
};

counter_addEventListener();
