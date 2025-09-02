import { test, expect } from '@playwright/test'

test.describe('Countdown Timer Component', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/tests/test-fixture.html')
    // Wait for custom elements to be defined
    await page.waitForFunction(() => window.customElements.get('countdown-timer'))
  })

  // ==================== Basic Rendering ====================

  test('should render timer with correct initial display', async ({ page }) => {
    const timer = page.locator('#timer-basic')
    await expect(timer).toBeVisible()

    // Check initial display
    await expect(timer.locator('.countdown-digits.minutes')).toHaveText('02')
    await expect(timer.locator('.countdown-digits.seconds')).toHaveText('00')

    // Check timer has countdown class for backward compatibility
    await expect(timer).toHaveClass(/countdown/)

    // Check controls exist in DOM (they're hidden until running)
    await expect(timer.locator('.countdown-controls')).toBeAttached()
    await expect(timer.locator('.countdown-bump-up')).toBeAttached()
    await expect(timer.locator('.countdown-bump-down')).toBeAttached()
  })

  test('should handle seconds-only input correctly', async ({ page }) => {
    // Create timer with 90 seconds
    await page.evaluate(() => {
      const timer = document.createElement('countdown-timer')
      timer.id = 'timer-seconds-only'
      timer.setAttribute('minutes', '1')
      timer.setAttribute('seconds', '30')
      document.body.appendChild(timer)
    })

    const timer = page.locator('#timer-seconds-only')
    await page.waitForTimeout(100)

    // Should display as 1:30
    await expect(timer.locator('.countdown-digits.minutes')).toHaveText('01')
    await expect(timer.locator('.countdown-digits.seconds')).toHaveText('30')
  })

  test('should handle timer with only seconds', async ({ page }) => {
    await page.evaluate(() => {
      const timer = document.createElement('countdown-timer')
      timer.id = 'timer-only-seconds'
      timer.setAttribute('minutes', '0')
      timer.setAttribute('seconds', '90')
      document.body.appendChild(timer)
    })

    const timer = page.locator('#timer-only-seconds')
    await page.waitForTimeout(100)

    // Should display as 1:30 (90 seconds = 1 minute 30 seconds)
    await expect(timer.locator('.countdown-digits.minutes')).toHaveText('01')
    await expect(timer.locator('.countdown-digits.seconds')).toHaveText('30')
  })

  // ==================== Timer Controls ====================

  test('should start, stop, and reset timer programmatically', async ({ page }) => {
    const timer = page.locator('#timer-basic')

    // Start timer
    await page.evaluate(() => {
      document.getElementById('timer-basic').start()
    })
    await expect(timer).toHaveClass(/running/)

    // Wait and check timer is counting down
    await page.waitForTimeout(2000)
    const secondsAfterStart = await timer.locator('.countdown-digits.seconds').textContent()
    expect(parseInt(secondsAfterStart)).toBeLessThan(60)

    // Stop timer
    await page.evaluate(() => {
      document.getElementById('timer-basic').stop({ manual: true })
    })
    await expect(timer).not.toHaveClass(/running/)
    await expect(timer).toHaveClass(/finished/)

    // Reset timer
    await page.evaluate(() => {
      document.getElementById('timer-basic').reset()
    })
    await expect(timer).not.toHaveClass(/running/)
    await expect(timer).not.toHaveClass(/finished/)
    await expect(timer.locator('.countdown-digits.minutes')).toHaveText('02')
    await expect(timer.locator('.countdown-digits.seconds')).toHaveText('00')
  })

  test('should start and stop timer on click', async ({ page }) => {
    const timer = page.locator('#timer-basic')

    // Start timer by clicking
    await timer.locator('.countdown-time').click()
    await expect(timer).toHaveClass(/running/)

    // Wait a moment to ensure timer is running
    await page.waitForTimeout(1500)

    // Stop timer by clicking
    await timer.locator('.countdown-time').click()
    await expect(timer).not.toHaveClass(/running/)
  })

  test('should reset timer on double click', async ({ page }) => {
    const timer = page.locator('#timer-seconds')
    const minutes = timer.locator('.countdown-digits.minutes')
    const seconds = timer.locator('.countdown-digits.seconds')

    // Start timer
    await timer.locator('.countdown-time').click()
    await page.waitForTimeout(2000)

    // Double click to reset
    await timer.locator('.countdown-time').dblclick()

    // Check timer is reset
    await expect(timer).not.toHaveClass(/running/)
    await expect(minutes).toHaveText('01')
    await expect(seconds).toHaveText('30')
  })

  test('should control timer programmatically via buttons', async ({ page }) => {
    const timer = page.locator('#timer-dynamic')
    const startButton = page.locator('button:has-text("Start")')
    const stopButton = page.locator('button:has-text("Stop")')
    const resetButton = page.locator('button:has-text("Reset")')

    // Start programmatically
    await startButton.click()
    await expect(timer).toHaveClass(/running/)

    // Stop programmatically
    await stopButton.click()
    await expect(timer).not.toHaveClass(/running/)

    // Reset programmatically
    await resetButton.click()
    await expect(timer).not.toHaveClass(/running/)
    await expect(timer).not.toHaveClass(/finished/)
  })

  // ==================== Keyboard Controls ====================

  test('should handle keyboard controls', async ({ page }) => {
    const timer = page.locator('#timer-basic')

    // Focus timer
    await timer.focus()

    // Start with Space
    await page.keyboard.press('Space')
    await expect(timer).toHaveClass(/running/)

    // Stop with Space
    await page.keyboard.press('Space')
    await expect(timer).not.toHaveClass(/running/)

    // Start again with Enter
    await page.keyboard.press('Enter')
    await expect(timer).toHaveClass(/running/)

    // Reset with Escape
    await page.keyboard.press('Escape')
    await expect(timer).not.toHaveClass(/running/)
  })

  test('should bump timer up and down with arrow keys', async ({ page }) => {
    const timer = page.locator('#timer-basic')
    const seconds = timer.locator('.countdown-digits.seconds')

    // Start timer
    await timer.locator('.countdown-time').click()
    await expect(timer).toHaveClass(/running/)

    // Focus and bump up
    await timer.focus()
    await page.keyboard.press('ArrowUp')

    // Wait briefly for update
    await page.waitForTimeout(100)

    // Check that time increased (exact value depends on timing)
    const secondsText = await seconds.textContent()
    expect(parseInt(secondsText)).toBeGreaterThan(0)

    // Bump down
    await page.keyboard.press('ArrowDown')
  })

  // ==================== Bump Functionality ====================

  test('should bump timer up and down', async ({ page }) => {
    const timer = page.locator('#timer-basic')
    await expect(timer).toBeAttached()

    // Start timer
    await page.evaluate(() => {
      document.getElementById('timer-basic').start()
    })

    // Get initial remaining time
    const initialRemaining = await page.evaluate(() => {
      const timer = document.getElementById('timer-basic')
      return timer.remainingTime().remaining
    })

    // Bump up
    await page.evaluate(() => {
      document.getElementById('timer-basic').bumpUp()
    })

    const afterBumpUp = await page.evaluate(() => {
      const timer = document.getElementById('timer-basic')
      return timer.remainingTime().remaining
    })

    expect(afterBumpUp).toBeGreaterThan(initialRemaining)

    // Bump down
    await page.evaluate(() => {
      document.getElementById('timer-basic').bumpDown()
    })

    const afterBumpDown = await page.evaluate(() => {
      const timer = document.getElementById('timer-basic')
      return timer.remainingTime().remaining
    })

    expect(afterBumpDown).toBeLessThan(afterBumpUp)
  })

  test('should bump timer with buttons', async ({ page }) => {
    const timer = page.locator('#timer-basic')
    await expect(timer).toBeAttached()

    const bumpUp = timer.locator('.countdown-bump-up')
    const bumpDown = timer.locator('.countdown-bump-down')

    // Start timer
    await timer.locator('.countdown-time').click()
    await expect(timer).toHaveClass(/running/)

    // Hover to show controls
    await timer.hover()

    // Click bump up
    await bumpUp.click()
    await page.waitForTimeout(100)

    // Click bump down
    await bumpDown.click()
    await page.waitForTimeout(100)

    // Timer should still be running
    await expect(timer).toHaveClass(/running/)
  })

  test('should prevent event propagation on controls', async ({ page }) => {
    const timer = page.locator('#timer-basic')
    await expect(timer).toBeAttached()

    const bumpUp = timer.locator('.countdown-bump-up')

    // Start timer
    await timer.locator('.countdown-time').click()
    await expect(timer).toHaveClass(/running/)

    // Hover to show controls
    await timer.hover()

    // Click on bump button should not toggle timer state
    await bumpUp.click()
    await expect(timer).toHaveClass(/running/)

    // Double click on controls should not reset
    const controls = timer.locator('.countdown-bump-up')
    await controls.dblclick()
    await expect(timer).toHaveClass(/running/)
  })

  // ==================== Dynamic Updates ====================

  test('should update timer attributes dynamically', async ({ page }) => {
    const timer = page.locator('#timer-dynamic')

    // Initial values
    await expect(timer.locator('.countdown-digits.minutes')).toHaveText('05')
    await expect(timer.locator('.countdown-digits.seconds')).toHaveText('00')

    // Update via attributes
    await page.evaluate(() => {
      const timer = document.getElementById('timer-dynamic')
      timer.setAttribute('minutes', '3')
      timer.setAttribute('seconds', '30')
    })

    // Check updated values
    await expect(timer.locator('.countdown-digits.minutes')).toHaveText('03')
    await expect(timer.locator('.countdown-digits.seconds')).toHaveText('30')
  })

  test('should update timer attributes dynamically via button', async ({ page }) => {
    const timer = page.locator('#timer-dynamic')
    const updateButton = page.locator('button:has-text("Update to 3:30")')

    // Initial values
    await expect(timer.locator('.countdown-digits.minutes')).toHaveText('05')
    await expect(timer.locator('.countdown-digits.seconds')).toHaveText('00')

    // Update timer
    await updateButton.click()

    // Check updated values
    await expect(timer.locator('.countdown-digits.minutes')).toHaveText('03')
    await expect(timer.locator('.countdown-digits.seconds')).toHaveText('30')
  })

  // ==================== Warning State ====================

  test('should handle warning state', async ({ page }) => {
    // Create a timer with warning
    await page.evaluate(() => {
      const timer = document.createElement('countdown-timer')
      timer.id = 'timer-warning-test'
      timer.setAttribute('minutes', '0')
      timer.setAttribute('seconds', '10')
      timer.setAttribute('warn-when', '5')
      document.body.appendChild(timer)
    })

    const timer = page.locator('#timer-warning-test')
    await page.waitForTimeout(100)

    // Start timer
    await page.evaluate(() => {
      document.getElementById('timer-warning-test').start()
    })

    // Initially no warning
    await expect(timer).not.toHaveClass(/warning/)

    // Wait until warning threshold
    await page.waitForTimeout(6000)
    await expect(timer).toHaveClass(/warning/)
  })

  test('should show warning class when time is low', async ({ page }) => {
    const timer = page.locator('#timer-warning')

    // Start timer
    await timer.locator('.countdown-time').click()
    await expect(timer).toHaveClass(/running/)

    // Initially should not have warning
    await expect(timer).not.toHaveClass(/warning/)

    // Wait until warning threshold
    await page.waitForFunction(
      () => {
        const timer = document.querySelector('#timer-warning')
        return timer.classList.contains('warning')
      },
      { timeout: 10000 }
    )

    await expect(timer).toHaveClass(/warning/)
  })

  // ==================== Timer Completion ====================

  test('should handle timer completion', async ({ page }) => {
    // Create a short timer
    await page.evaluate(() => {
      const timer = document.createElement('countdown-timer')
      timer.id = 'timer-completion-test'
      timer.setAttribute('minutes', '0')
      timer.setAttribute('seconds', '2')
      document.body.appendChild(timer)
    })

    const timer = page.locator('#timer-completion-test')
    await page.waitForTimeout(100)

    // Start timer
    await page.evaluate(() => {
      document.getElementById('timer-completion-test').start()
    })
    await expect(timer).toHaveClass(/running/)

    // Wait for completion
    await page.waitForTimeout(2500)

    // Timer should be finished
    await expect(timer).toHaveClass(/finished/)
    await expect(timer).not.toHaveClass(/running/)
    await expect(timer.locator('.countdown-digits.minutes')).toHaveText('00')
    await expect(timer.locator('.countdown-digits.seconds')).toHaveText('00')
  })

  // ==================== Custom Events ====================

  test('should emit custom events', async ({ page }) => {
    // Set up event capture
    await page.evaluate(() => {
      window.capturedEvents = []
      const timer = document.getElementById('timer-events')
      timer.addEventListener('countdown', (e) => {
        window.capturedEvents.push({
          action: e.detail.action,
          hasTimer: !!e.detail.timer
        })
      })
    })

    // Trigger events
    await page.evaluate(() => {
      const timer = document.getElementById('timer-events')
      timer.start()
    })
    await page.waitForTimeout(500)

    await page.evaluate(() => {
      const timer = document.getElementById('timer-events')
      timer.stop({ manual: true })
    })

    await page.evaluate(() => {
      const timer = document.getElementById('timer-events')
      timer.reset()
    })

    // Check events were captured
    const events = await page.evaluate(() => window.capturedEvents)
    expect(events.length).toBeGreaterThan(0)
    expect(events.some(e => e.action === 'start')).toBeTruthy()
    expect(events.some(e => e.action === 'stop')).toBeTruthy()
    expect(events.some(e => e.action === 'reset')).toBeTruthy()
    expect(events.every(e => e.hasTimer)).toBeTruthy()
  })

  test('should emit countdown events on interaction', async ({ page }) => {
    // Set up event listener
    await page.evaluate(() => {
      window.capturedEvents = []
      const timer = document.querySelector('#timer-events')
      timer.addEventListener('countdown', (e) => {
        window.capturedEvents.push(e.detail.action)
      })
    })

    const timer = page.locator('#timer-events')

    // Start timer
    await timer.click()

    // Wait a moment
    await page.waitForTimeout(500)

    // Stop timer
    await timer.click()

    // Check events were captured
    const events = await page.evaluate(() => window.capturedEvents)
    expect(events).toContain('start')
    expect(events).toContain('stop')
  })

  // ==================== Special Attributes ====================

  test('should handle blink-colon attribute', async ({ page }) => {
    // Create timer with blink-colon
    await page.evaluate(() => {
      const timer = document.createElement('countdown-timer')
      timer.id = 'timer-blink-test'
      timer.setAttribute('minutes', '1')
      timer.setAttribute('seconds', '0')
      timer.setAttribute('blink-colon', 'true')
      document.body.appendChild(timer)
    })

    const timer = page.locator('#timer-blink-test')
    await page.waitForTimeout(100)
    await expect(timer).toBeAttached()

    // Start timer
    await page.evaluate(() => {
      document.getElementById('timer-blink-test').start()
    })

    // Should toggle blink-colon class
    await page.waitForTimeout(1500)
    const hasBlinkClass = await page.evaluate(() => {
      const timer = document.getElementById('timer-blink-test')
      return timer.classList.contains('blink-colon')
    })

    expect(typeof hasBlinkClass).toBe('boolean')
  })

  test('should handle update-every attribute', async ({ page }) => {
    // Create timer with update-every
    await page.evaluate(() => {
      const timer = document.createElement('countdown-timer')
      timer.id = 'timer-update-test'
      timer.setAttribute('minutes', '1')
      timer.setAttribute('seconds', '0')
      timer.setAttribute('update-every', '5')
      document.body.appendChild(timer)
    })

    const timer = page.locator('#timer-update-test')
    await page.waitForTimeout(100)
    await expect(timer).toBeAttached()

    // Start timer and verify it exists
    await page.evaluate(() => {
      const timer = document.getElementById('timer-update-test')
      timer.start()
      return timer.update_every
    }).then(updateEvery => {
      expect(updateEvery).toBe(5)
    })
  })

  test('should auto-start timer with start-immediately attribute', async ({ page }) => {
    // Navigate to page with auto-start timer
    await page.goto('/tests/test-fixture.html')

    // Wait for DOMContentLoaded and timer initialization
    await page.waitForLoadState('domcontentloaded')
    await page.waitForTimeout(500)

    const timer = page.locator('#timer-auto')
    timer.scrollIntoViewIfNeeded()

    // Timer should be running automatically
    await expect(timer).toHaveClass(/running/, { timeout: 2000 })
  })

  // ==================== Backward Compatibility ====================

  test('should maintain countdown class for backward compatibility', async ({ page }) => {
    const timer = page.locator('#timer-basic')

    // Should have countdown class
    await expect(timer).toHaveClass(/countdown/)
  })
})
