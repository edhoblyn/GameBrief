import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    interval: { type: Number, default: 4000 },
    expectedDuration: { type: Number, default: 25 },
    pending: Boolean,
    requestedAt: String,
    url: String
  }

  static targets = ["progress"]

  connect() {
    if (!this.pendingValue || !this.hasUrlValue) return

    this.updateProgress()
    this.progressTimer = window.setInterval(() => this.updateProgress(), 1000)
    this.schedulePoll()
  }

  disconnect() {
    this.clearPoll()
    this.clearProgressTimer()
  }

  pendingValueChanged() {
    this.clearPoll()
    this.clearProgressTimer()
    if (!this.pendingValue) return

    this.updateProgress()
    this.progressTimer = window.setInterval(() => this.updateProgress(), 1000)
    this.schedulePoll()
  }

  schedulePoll() {
    this.clearPoll()
    this.timeout = window.setTimeout(() => this.refresh(), this.intervalValue)
  }

  clearPoll() {
    if (!this.timeout) return

    window.clearTimeout(this.timeout)
    this.timeout = null
  }

  clearProgressTimer() {
    if (!this.progressTimer) return

    window.clearInterval(this.progressTimer)
    this.progressTimer = null
  }

  updateProgress() {
    if (!this.hasProgressTarget) return

    this.progressTarget.textContent = `${this.progressPercent()}%`
  }

  progressPercent() {
    if (!this.hasRequestedAtValue) return 15

    const requestedAt = new Date(this.requestedAtValue)
    if (Number.isNaN(requestedAt.getTime())) return 15

    const elapsedSeconds = Math.max(0, (Date.now() - requestedAt.getTime()) / 1000)
    const expectedSeconds = Math.max(this.expectedDurationValue, 1)
    const rawPercent = Math.round((elapsedSeconds / expectedSeconds) * 100)

    return Math.min(Math.max(rawPercent, 15), 95)
  }

  async refresh() {
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("_presentation_poll", Date.now().toString())

    try {
      const response = await fetch(url.toString(), {
        headers: {
          Accept: "text/html"
        },
        credentials: "same-origin",
        cache: "no-store"
      })

      if (!response.ok) {
        this.schedulePoll()
        return
      }

      const html = await response.text()
      const wrapper = document.createElement("div")
      wrapper.innerHTML = html.trim()
      const nextFrame = wrapper.querySelector("turbo-frame#patch_notes") || wrapper.firstElementChild

      if (!nextFrame) {
        this.schedulePoll()
        return
      }

      this.element.replaceWith(nextFrame)
    } catch (_error) {
      this.schedulePoll()
    }
  }
}
