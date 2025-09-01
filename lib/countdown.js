/* countdown
 * countdown timer for slides and HTML docs in Quarto, R Markdown, and Shiny
 *
 * https://pkg.garrickadenbuie.com/countdown
 *
 * Copyright (c) 2025 countdown authors
 *
 * This software is released under the MIT License.
 * https://opensource.org/licenses/MIT
 */

/* globals Shiny,Audio */
class CountdownTimer extends window.HTMLElement {
  constructor () {
    super()

    // Initialize properties without DOM access
    this.end = null
    this.is_running = false
    this.timeout = null
    this.remaining = null
    this.display = { minutes: 0, seconds: 0 }
    this.src_location = null

    // For backward compatibility
    this.countdown = this
  }

  static get observedAttributes () {
    return [
      'warn-when',
      'update-every',
      'play-sound',
      'blink-colon',
      'start-immediately',
      'minutes',
      'seconds'
    ]
  }

  connectedCallback () {
    // Ensure countdown class is present for backward compatibility
    if (!this.classList.contains('countdown')) {
      this.classList.add('countdown')
    }

    // Initialize from DOM structure and attributes
    this.initializeFromDOM()

    // Set up event listeners
    this.addEventListeners()

    // Handle start immediately behavior
    if (this.startImmediately) {
      this.handleStartImmediately()
    }

    // For backward compatibility - attach to element
    this.element = this
  }

  disconnectedCallback () {
    this.cleanup()
  }

  attributeChangedCallback (name, oldValue, newValue) {
    if (oldValue === newValue) return

    switch (name) {
      case 'warn-when':
        this.warn_when = parseInt(newValue) || -1
        break
      case 'update-every':
        this.update_every = parseInt(newValue) || 1
        break
      case 'play-sound':
        this.play_sound = this.attrIsTrue(newValue) || newValue
        break
      case 'blink-colon':
        this.blink_colon = this.attrIsTrue(newValue)
        if (!this.blink_colon) {
          this.classList.remove('blink-colon')
        }
        break
      case 'start-immediately':
        this.startImmediately = this.attrIsTrue(newValue)
        break
      case 'minutes':
      case 'seconds':
        // Re-initialize when minutes or seconds change
        const minutes = parseInt(this.getAttribute('minutes') || '0')
        const seconds = parseInt(this.getAttribute('seconds') || '0')
        this.duration = minutes * 60 + seconds
        this.display = { minutes, seconds }

        // Update the display if DOM exists
        if (this.querySelector('.minutes') && this.querySelector('.seconds')) {
          this.update(true)
        }
        break
    }
  }

  createInnerDOM () {
    // Clear existing content
    this.innerHTML = ''

    // Create controls
    const controls = document.createElement('div')
    controls.className = 'countdown-controls'

    const bumpDown = document.createElement('button')
    bumpDown.className = 'countdown-bump-down'
    bumpDown.innerHTML = '&minus;'

    const bumpUp = document.createElement('button')
    bumpUp.className = 'countdown-bump-up'
    bumpUp.innerHTML = '&plus;'

    controls.appendChild(bumpDown)
    controls.appendChild(bumpUp)

    // Create time display
    const timeCode = document.createElement('code')
    timeCode.className = 'countdown-time'

    const minutesSpan = document.createElement('span')
    minutesSpan.className = 'countdown-digits minutes'
    minutesSpan.innerText = String(this.display.minutes).padStart(2, '0')

    const colonSpan = document.createElement('span')
    colonSpan.className = 'countdown-digits colon'
    colonSpan.innerText = ':'

    const secondsSpan = document.createElement('span')
    secondsSpan.className = 'countdown-digits seconds'
    secondsSpan.innerText = String(this.display.seconds).padStart(2, '0')

    timeCode.appendChild(minutesSpan)
    timeCode.appendChild(colonSpan)
    timeCode.appendChild(secondsSpan)

    // Append to element
    this.appendChild(controls)
    this.appendChild(timeCode)
  }

  initializeFromDOM () {
    // Get minutes and seconds from attributes, defaulting to 0
    const minutes = parseInt(this.getAttribute('minutes') || '0')
    const seconds = parseInt(this.getAttribute('seconds') || '0')

    this.duration = minutes * 60 + seconds
    this.display = { minutes, seconds }

    // Create the inner DOM structure
    this.createInnerDOM()

    // Initialize properties from attributes (changed from dataset)
    this.warn_when = parseInt(this.getAttribute('warn-when')) || -1
    this.update_every = parseInt(this.getAttribute('update-every')) || 1
    this.play_sound =
      this.attrIsTrue(this.getAttribute('play-sound')) ||
      this.getAttribute('play-sound')
    this.blink_colon = this.attrIsTrue(this.getAttribute('blink-colon'))
    this.startImmediately = this.attrIsTrue(
      this.getAttribute('start-immediately')
    )

    // Get source location from script tag if available
    const currentScript = document.querySelector('script[src*="countdown.js"]')
    if (currentScript) {
      this.src_location = currentScript.getAttribute('src')
    }
  }

  cleanup () {
    if (this.timeout) {
      clearTimeout(this.timeout)
      this.timeout = null
    }
    this.is_running = false
  }

  attrIsTrue (x) {
    if (typeof x === 'undefined') return false
    if (x === true) return true
    return !!(x === 'true' || x === '' || x === '1')
  }

  addEventListeners () {
    const self = this

    function haltEvent (ev) {
      ev.preventDefault()
      ev.stopPropagation()
    }
    function isSpaceOrEnter (ev) {
      return ev.code === 'Space' || ev.code === 'Enter'
    }
    function isArrowUpOrDown (ev) {
      return ev.code === 'ArrowUp' || ev.code === 'ArrowDown'
    }

    ['click', 'touchend'].forEach(function (eventType) {
      self.addEventListener(eventType, function (ev) {
        haltEvent(ev)
        self.is_running ? self.stop({ manual: true }) : self.start()
      })
    })

    this.addEventListener('keydown', function (ev) {
      if (ev.code === 'Escape') {
        self.reset()
        haltEvent(ev)
      }
      if (!isSpaceOrEnter(ev) && !isArrowUpOrDown(ev)) return
      haltEvent(ev)
      if (isSpaceOrEnter(ev)) {
        self.is_running ? self.stop({ manual: true }) : self.start()
        return
      }

      if (!self.is_running) return

      if (ev.code === 'ArrowUp') {
        self.bumpUp()
      } else if (ev.code === 'ArrowDown') {
        self.bumpDown()
      }
    })

    this.addEventListener('dblclick', function (ev) {
      haltEvent(ev)
      if (self.is_running) self.reset()
    })

    this.addEventListener('touchmove', haltEvent)

    const btnBumpDown = this.querySelector('.countdown-bump-down')
    if (btnBumpDown) {
      ['click', 'touchend'].forEach(function (eventType) {
        btnBumpDown.addEventListener(eventType, function (ev) {
          haltEvent(ev)
          if (self.is_running) self.bumpDown()
        })
      })
      btnBumpDown.addEventListener('keydown', function (ev) {
        if (!isSpaceOrEnter(ev) || !self.is_running) return
        haltEvent(ev)
        self.bumpDown()
      })
    }

    const btnBumpUp = this.querySelector('.countdown-bump-up')
    if (btnBumpUp) {
      ['click', 'touchend'].forEach(function (eventType) {
        btnBumpUp.addEventListener(eventType, function (ev) {
          haltEvent(ev)
          if (self.is_running) self.bumpUp()
        })
      })
      btnBumpUp.addEventListener('keydown', function (ev) {
        if (!isSpaceOrEnter(ev) || !self.is_running) return
        haltEvent(ev)
        self.bumpUp()
      })
    }

    const controlsEl = this.querySelector('.countdown-controls')
    if (controlsEl) {
      controlsEl.addEventListener('dblclick', function (ev) {
        haltEvent(ev)
      })
    }
  }

  handleStartImmediately () {
    const self = this

    if (window.remark && window.slideshow) {
      // Remark (xaringan) support
      const isOnVisibleSlide = () => {
        return document.querySelector('.remark-visible').contains(self)
      }
      if (isOnVisibleSlide()) {
        self.start()
      } else {
        let started_once = 0
        window.slideshow.on('afterShowSlide', function () {
          if (started_once > 0) return
          if (isOnVisibleSlide()) {
            self.start()
            started_once = 1
          }
        })
      }
    } else if (window.Reveal) {
      // Revealjs (quarto) support
      const isOnVisibleSlide = () => {
        const currentSlide = document.querySelector('.reveal .slide.present')
        return currentSlide ? currentSlide.contains(self) : false
      }
      if (isOnVisibleSlide()) {
        self.start()
      } else {
        const revealStartTimer = () => {
          if (isOnVisibleSlide()) {
            self.start()
            window.Reveal.off('slidechanged', revealStartTimer)
          }
        }
        window.Reveal.on('slidechanged', revealStartTimer)
      }
    } else if (window.IntersectionObserver) {
      // All other situations use IntersectionObserver
      const onVisible = (element, callback) => {
        new window.IntersectionObserver((entries, observer) => {
          entries.forEach((entry) => {
            if (entry.intersectionRatio > 0) {
              callback(element)
              observer.disconnect()
            }
          })
        }).observe(element)
      }
      onVisible(this, (el) => el.countdown.start())
    } else {
      // or just start the timer as soon as it's initialized
      this.start()
    }
  }

  remainingTime () {
    const remaining = this.is_running
      ? (this.end - Date.now()) / 1000
      : this.remaining || this.duration

    let minutes = Math.floor(remaining / 60)
    let seconds = Math.ceil(remaining - minutes * 60)

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

    this.emitStateEvent('start')

    this.classList.remove('finished')
    this.classList.add('running')
    this.update(true)
    this.tick()
  }

  tick (run_again) {
    if (typeof run_again === 'undefined') {
      run_again = true
    }

    if (!this.is_running) return

    const { seconds: secondsWas } = this.display
    this.update()

    if (run_again) {
      const delay = this.end - Date.now() > 10000 ? 1000 : 250
      this.blinkColon(secondsWas)
      this.timeout = setTimeout(this.tick.bind(this), delay)
    }
  }

  blinkColon (secondsWas) {
    // don't blink unless option is set
    if (!this.blink_colon) return
    // warn_when always updates the seconds
    if (this.warn_when > 0 && Date.now() + this.warn_when > this.end) {
      this.classList.remove('blink-colon')
      return
    }
    const { seconds: secondsIs } = this.display
    if (secondsIs > 10 || secondsWas !== secondsIs) {
      this.classList.toggle('blink-colon')
    }
  }

  update (force) {
    if (typeof force === 'undefined') {
      force = false
    }

    const { remaining, minutes, seconds } = this.remainingTime()

    const setRemainingTime = (selector, time) => {
      const timeContainer = this.querySelector(selector)
      if (!timeContainer) return
      time = Math.max(time, 0)
      timeContainer.innerText = String(time).padStart(2, 0)
    }

    if (this.is_running && remaining < 0.25) {
      this.stop()
      setRemainingTime('.minutes', 0)
      setRemainingTime('.seconds', 0)
      this.playSound()
      return
    }

    const should_update =
      force ||
      Math.round(remaining) < this.warn_when ||
      Math.round(remaining) % this.update_every === 0

    if (should_update) {
      const is_warning = remaining <= this.warn_when
      if (is_warning && !this.classList.contains('warning')) {
        this.emitStateEvent('warning')
      }
      this.classList.toggle('warning', is_warning)
      this.display = { minutes, seconds }
      setRemainingTime('.minutes', minutes)
      setRemainingTime('.seconds', seconds)
    }
  }

  stop ({ manual = false } = {}) {
    const { remaining } = this.remainingTime()
    if (remaining > 1) {
      this.remaining = remaining
    }
    this.classList.remove('running')
    this.classList.remove('warning')
    this.classList.remove('blink-colon')
    this.classList.add('finished')
    this.is_running = false
    this.end = null
    this.emitStateEvent(manual ? 'stop' : 'finished')
    this.timeout = clearTimeout(this.timeout)
  }

  reset () {
    this.stop({ manual: true })
    this.remaining = null
    this.update(true)

    this.classList.remove('finished')
    this.classList.remove('warning')
    this.emitEvents = true
    this.emitStateEvent('reset')
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
        this.classList.remove('blink-colon')
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
    this.emitStateEvent('update')
    this.update(true)
  }

  bumpTimer (val, round) {
    round = typeof round === 'boolean' ? round : true
    const { remaining } = this.remainingTime()
    let newRemaining = remaining + val
    if (newRemaining <= 0) {
      this.setRemaining(0)
      this.stop()
      return
    }
    if (round && newRemaining > 10) {
      newRemaining = Math.round(newRemaining / 5) * 5
    }
    this.setRemaining(newRemaining)
    this.emitStateEvent(val > 0 ? 'bumpUp' : 'bumpDown')
    this.update(true)
  }

  bumpUp (val) {
    if (!this.is_running) {
      console.error('timer is not running')
      return
    }
    this.bumpTimer(
      val || this.bumpIncrementValue(),
      typeof val === 'undefined'
    )
  }

  bumpDown (val) {
    if (!this.is_running) {
      console.error('timer is not running')
      return
    }
    this.bumpTimer(
      val || -1 * this.bumpIncrementValue(),
      typeof val === 'undefined'
    )
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
    if (!url || url === 'false') return
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

  emitStateEvent (action) {
    const data = {
      action,
      time: new Date().toISOString(),
      timer: {
        is_running: this.is_running,
        end: this.end ? new Date(this.end).toISOString() : null,
        remaining: this.remainingTime()
      }
    }

    this.reportStateToShiny(data)
    this.dispatchEvent(
      new CustomEvent('countdown', { detail: data, bubbles: true })
    )
  }

  reportStateToShiny (data) {
    if (!window.Shiny) return

    if (!window.Shiny.setInputValue) {
      // We're in Shiny but it isn't ready for input updates yet
      setTimeout(() => this.reportStateToShiny(data), 100)
      return
    }

    const { action, time, timer } = data

    const shinyData = { event: { action, time }, timer }

    window.Shiny.setInputValue(this.id, shinyData)
  }
}

if (!customElements.get('countdown-timer')) {
  customElements.define('countdown-timer', CountdownTimer)
}

(function () {
  if (!window.Shiny) {
    return
  }
  Shiny.addCustomMessageHandler('countdown:update', function (x) {
    if (!x.id) {
      console.error('No `id` provided, cannot update countdown')
      return
    }
    const el = document.getElementById(x.id)
    if (el && el.setValues) {
      el.setValues(x)
    }
  })

  Shiny.addCustomMessageHandler('countdown:start', function (id) {
    const el = document.getElementById(id)
    if (!el) return
    if (el.start) {
      el.start()
    }
  })

  Shiny.addCustomMessageHandler('countdown:stop', function (id) {
    const el = document.getElementById(id)
    if (!el) return
    if (el.stop) {
      el.stop({ manual: true })
    }
  })

  Shiny.addCustomMessageHandler('countdown:reset', function (id) {
    const el = document.getElementById(id)
    if (!el) return
    if (el.reset) {
      el.reset()
    }
  })

  Shiny.addCustomMessageHandler('countdown:bumpUp', function (id) {
    const el = document.getElementById(id)
    if (!el) return
    if (el.bumpUp) {
      el.bumpUp()
    }
  })

  Shiny.addCustomMessageHandler('countdown:bumpDown', function (id) {
    const el = document.getElementById(id)
    if (!el) return
    if (el.bumpDown) {
      el.bumpDown()
    }
  })
})()
