class CountdownTimer {
  constructor (el) {
    if (typeof el === 'string' || el instanceof String) {
      el = document.querySelector(el)
    }

    if (el.counter) {
      return el.counter
    }

    const self = this
    el.addEventListener('click', function() {
      self.is_running ? self.bumpUp() : self.start()
    })

    const minutes = el.querySelector('.minutes') || '0'
    const seconds = el.querySelector('.seconds') || '0'
    const duration = parseInt(minutes.innerHTML) * 60 + parseInt(seconds.innerHTML)

    function attrIsTrue (x) {
      if (x === true) return true
      return x === 'true' || x === '' || x === '1' ? true : false
    }

    this.element = el
    this.duration = duration
    this.end = null
    this.is_running = false
    this.warn_when = parseInt(el.dataset.warnWhen) || -1
    this.update_every = parseInt(el.dataset.updateEvery) || 1
    this.play_sound = attrIsTrue(el.dataset.playSound)
    this.blink_colon = attrIsTrue(el.dataset.blinkColon)
    this.timeout = null
  }

  remainingTime () {
    const remaining = (this.end - Date.now()) / 1000

    let minutes = Math.floor(remaining / 60)
    let seconds = Math.round(remaining - minutes * 60)
    if (seconds > 59) {
      minutes = minutes + 1
      seconds = seconds - 60
    }

    return {remaining, minutes, seconds}
  }

  start () {
    this.is_running = true
    this.end = Date.now() + this.duration * 1000
    this.element.classList.remove('finished')
    this.element.classList.add('running')
    this.tick()
  }

  tick (run_again) {
    if (typeof run_again === 'undefined') {
      run_again = true
    }

    if (!this.is_running) return

    this.update()

    if (run_again) {
      this.timeout = setTimeout(this.tick.bind(this), 1000 - Date.now() % 1000)
    }
  }

  update (force) {
    if (typeof force === 'undefined') {
      force = false
    }

    const { remaining, minutes, seconds } = this.remainingTime()

    const setRemainingTime = (selector, time) => {
      const timeContainer = this.element.querySelector(selector)
      if (!timeContainer) return
      time = Math.max(time, 0)
      timeContainer.innerText = String(time).padStart(2, 0)
    }

    if (remaining < 0.5) {
      this.stop()
      setRemainingTime('.minutes', 0)
      setRemainingTime('.seconds', 0)
      this.playSound()
      return
    }

    if (this.blink_colon) {
      this.element.classList.toggle('blink-colon')
    }

    const should_update = force ||
      Math.round(remaining) < this.warn_when ||
      Math.round(remaining) % this.update_every == 0

    console.log({ remaining, should_update })

    if (should_update) {
      this.element.classList.toggle('warning', remaining <= this.warn_when)
      setRemainingTime('.minutes', minutes)
      setRemainingTime('.seconds', seconds)
    }
  }

  stop () {
    this.element.classList.remove('running')
    this.element.classList.remove('blink-colon')
    this.element.classList.add('finished')
    this.is_running = false
    this.timeout = clearTimeout(this.timeout)
  }

  bumpUp (val) {
    if (!this.is_running) {
      console.error('timer is not running')
      return
    }
    val = val || this.bumpIncrementValue()
    this.end += val * 1000
    this.update(true)
  }

  bumpDown (val) {
    if (!this.is_running) {
      console.error('timer is not running')
      return
    }
    val = val || this.bumpIncrementValue()
    this.end -= val * 1000
    this.update(true)
  }

  setRemaining (val) {
    if (!this.is_running) {
      console.error('timer is not running')
      return
    }
    this.end = Date.now() + val * 1000
    this.update(true)
  }

  playSound () {
    let url = this.play_sound
    if (!url) return
    if (typeof url === 'boolean') {
      url = 'libs/countdown/smb_stage_clear.mp3'
    }
    const sound = new Audio(url)
    sound.play()
  }

  bumpIncrementValue (val) {
    val = val || this.remainingTime().remaining
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
}

document.addEventListener('DOMContentLoaded', function() {
  const els = document.querySelectorAll('.countdown')
  if (!els || !els.length) {
    return;
  }
  els.forEach(function(el) {
    el.countdown = new CountdownTimer(el)
  })
})
