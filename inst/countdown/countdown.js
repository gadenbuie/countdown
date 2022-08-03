/* globals Shiny,Audio */
class CountdownTimer {
  constructor (el, opts) {
    if (typeof el === 'string' || el instanceof String) {
      el = document.querySelector(el)
    }

    if (el.counter) {
      return el.counter
    }

    const self = this
    el.addEventListener('click', function () {
      self.is_running ? self.stop() : self.start()
    })
    el.addEventListener('dblclick', function () {
      if (self.is_running) self.reset()
    })
    el.querySelector('.countdown-bump-down').addEventListener('click', function(ev) {
      ev.preventDefault()
      ev.stopPropagation()
      if (self.is_running) self.bumpDown()
    })
    el.querySelector('.countdown-bump-up').addEventListener('click', function(ev) {
      ev.preventDefault()
      ev.stopPropagation()
      if (self.is_running) self.bumpUp()
    })
    el.querySelector('.countdown-controls').addEventListener('dblclick', function(ev) {
      ev.preventDefault()
      ev.stopPropagation()
    })

    const minutes = el.querySelector('.minutes') || '0'
    const seconds = el.querySelector('.seconds') || '0'
    const duration = parseInt(minutes.innerHTML) * 60 + parseInt(seconds.innerHTML)

    function attrIsTrue (x) {
      if (x === true) return true
      return !!(x === 'true' || x === '' || x === '1')
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

    if (opts.src_location) {
      this.src_location = opts.src_location
    }

    if (attrIsTrue(el.dataset.startImmediately)) {
      this.start()
    }
  }

  remainingTime () {
    const remaining = this.is_running
      ? (this.end - Date.now()) / 1000
      : this.duration

    let minutes = Math.floor(remaining / 60)
    let seconds = Math.round(remaining - minutes * 60)
    if (seconds > 59) {
      minutes = minutes + 1
      seconds = seconds - 60
    }

    return { remaining, minutes, seconds }
  }

  start () {
    if (this.is_running) return

    this.is_running = true

    if (this.remaining) {
      // Having a static remaining time indicates timer was paused
      this.end = Date.now() + this.remaining * 1000
      this.remaining = null
    } else {
      this.end = Date.now() + this.duration * 1000
    }

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

    if (this.is_running && remaining < 0.5) {
      this.stop()
      setRemainingTime('.minutes', 0)
      setRemainingTime('.seconds', 0)
      this.playSound()
      return
    }

    if (!force && this.blink_colon) {
      this.element.classList.toggle('blink-colon')
    }

    const should_update = force ||
      Math.round(remaining) < this.warn_when ||
      Math.round(remaining) % this.update_every === 0

    if (should_update) {
      this.element.classList.toggle('warning', remaining <= this.warn_when)
      setRemainingTime('.minutes', minutes)
      setRemainingTime('.seconds', seconds)
    }
  }

  stop () {
    const { remaining } = this.remainingTime()
    if (remaining > 1) {
      this.remaining = remaining
    }
    this.element.classList.remove('running')
    this.element.classList.remove('warning')
    this.element.classList.remove('blink-colon')
    this.element.classList.add('finished')
    this.is_running = false
    this.end = null
    this.timeout = clearTimeout(this.timeout)
  }

  reset () {
    this.stop()
    this.remaining = null
    this.update(true)
    this.element.classList.remove('finished')
    this.element.classList.remove('warning')
  }

  setValues (opts) {
    if (typeof opts.warn_when !== 'undefined') {
      this.warn_when = opts.warn_when
    }
    if (typeof opts.update_every !== 'undefined') {
      this.update_every = opts.update_every
    }
    if (typeof opts.blink_colon !== 'undefined') {
      this.blink_colon = opts.blink_colon
      if (!opts.blink_colon) {
        this.element.classList.remove('blink-colon')
      }
    }
    if (typeof opts.play_sound !== 'undefined') {
      this.play_sound = opts.play_sound
    }
    if (typeof opts.duration !== 'undefined') {
      this.duration = opts.duration
      if (this.is_running) {
        this.reset()
        this.start()
      }
    }
    this.update(true)
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
      const src = this.src_location
        ? this.src_location.replace('/countdown.js', '')
        : 'libs/countdown'
      url = src + '/smb_stage_clear.mp3'
    }
    const sound = new Audio(url)
    sound.play()
  }

  bumpIncrementValue (val) {
    val = val || this.remainingTime().remaining
    if (val <= 30) {
      return 5
    } else if (val <= 300) {
      return 15
    } else if (val <= 3000) {
      return 30
    } else {
      return 60
    }
  }
}

(function () {
  const CURRENT_SCRIPT = document.currentScript.getAttribute('src')

  document.addEventListener('DOMContentLoaded', function () {
    const els = document.querySelectorAll('.countdown')
    if (!els || !els.length) {
      return
    }
    els.forEach(function (el) {
      el.countdown = new CountdownTimer(el, { src_location: CURRENT_SCRIPT })
    })

    if (window.Shiny) {
      Shiny.addCustomMessageHandler('countdown:update', function (x) {
        if (!x.id) {
          console.error('No `id` provided, cannot update countdown')
          return
        }
        const el = document.getElementById(x.id)
        el.countdown.setValues(x)
      })

      Shiny.addCustomMessageHandler('countdown:start', function (id) {
        const el = document.getElementById(id)
        if (!el) return
        el.countdown.start()
      })

      Shiny.addCustomMessageHandler('countdown:stop', function (id) {
        const el = document.getElementById(id)
        if (!el) return
        el.countdown.stop()
      })

      Shiny.addCustomMessageHandler('countdown:reset', function (id) {
        const el = document.getElementById(id)
        if (!el) return
        el.countdown.reset()
      })

      Shiny.addCustomMessageHandler('countdown:bumpUp', function (id) {
        const el = document.getElementById(id)
        if (!el) return
        el.countdown.bumpUp()
      })

      Shiny.addCustomMessageHandler('countdown:bumpDown', function (id) {
        const el = document.getElementById(id)
        if (!el) return
        el.countdown.bumpDown()
      })
    }
  })
})()
