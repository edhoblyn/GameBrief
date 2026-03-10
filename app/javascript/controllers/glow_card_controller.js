import { Controller } from "@hotwired/stimulus"

// Tracks pointer position and animates a conic-gradient border glow
// that follows the mouse — faithful port of the GlowingEffect React component.
export default class extends Controller {
  static targets = ["card"]

  #lastX = 0
  #lastY = 0
  #rafId = null

  // Config (mirrors the React component props)
  #proximity = 80
  #spread = 20
  #inactiveZone = 0.7
  #duration = 400   // ms — approximates movementDuration easing

  connect() {
    this.#onPointerMove = this.#onPointerMove.bind(this)
    this.#onScroll = this.#onScroll.bind(this)
    window.addEventListener("pointermove", this.#onPointerMove, { passive: true })
    window.addEventListener("scroll",      this.#onScroll,      { passive: true })
  }

  disconnect() {
    window.removeEventListener("pointermove", this.#onPointerMove)
    window.removeEventListener("scroll",      this.#onScroll)
    cancelAnimationFrame(this.#rafId)
  }

  #onPointerMove(e) {
    this.#lastX = e.clientX
    this.#lastY = e.clientY
    this.#scheduleUpdate()
  }

  #onScroll() {
    this.#scheduleUpdate()
  }

  #scheduleUpdate() {
    cancelAnimationFrame(this.#rafId)
    this.#rafId = requestAnimationFrame(() => this.#update(this.#lastX, this.#lastY))
  }

  #update(mouseX, mouseY) {
    this.cardTargets.forEach(card => {
      const { left, top, width, height } = card.getBoundingClientRect()
      const cx = left + width  * 0.5
      const cy = top  + height * 0.5

      // Inactive dead-zone in the centre of the card
      const inactiveRadius = 0.5 * Math.min(width, height) * this.#inactiveZone
      const distFromCenter = Math.hypot(mouseX - cx, mouseY - cy)

      if (distFromCenter < inactiveRadius) {
        card.style.setProperty("--active", "0")
        return
      }

      const isNear =
        mouseX > left - this.#proximity &&
        mouseX < left + width  + this.#proximity &&
        mouseY > top  - this.#proximity &&
        mouseY < top  + height + this.#proximity

      card.style.setProperty("--active", isNear ? "1" : "0")
      if (!isNear) return

      // Angle from card centre to mouse
      const targetAngle =
        (180 * Math.atan2(mouseY - cy, mouseX - cx)) / Math.PI + 90

      const current = parseFloat(card.style.getPropertyValue("--start")) || 0
      const diff    = ((targetAngle - current + 180) % 360) - 180
      const newAngle = current + diff

      // Smooth interpolation via rAF
      this.#animateProp(card, "--start", current, newAngle, this.#duration)
    })
  }

  #animateProp(el, prop, from, to, duration) {
    const start = performance.now()
    const tick = (now) => {
      const t = Math.min((now - start) / duration, 1)
      // ease out expo
      const eased = t === 1 ? 1 : 1 - Math.pow(2, -10 * t)
      el.style.setProperty(prop, String(from + (to - from) * eased))
      if (t < 1) requestAnimationFrame(tick)
    }
    requestAnimationFrame(tick)
  }
}
