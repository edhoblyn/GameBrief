import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "gamebrief:profile-notification-toggles"

export default class extends Controller {
  static targets = ["toggle", "state", "recommendationCallout", "recommendationText", "recommendationAction"]

  connect() {
    this.savedStates = this.loadStates()
    this.toggleTargets.forEach((toggle) => this.applyState(toggle, this.currentState(toggle)))
    this.syncRecommendations()
  }

  toggle(event) {
    const toggle = event.currentTarget
    const nextState = this.currentState(toggle) === "on" ? "off" : "on"

    this.savedStates[toggle.dataset.notificationKey] = nextState
    this.persistStates()
    this.applyState(toggle, nextState)
    this.syncRecommendations()
  }

  currentState(toggle) {
    return this.savedStates[toggle.dataset.notificationKey] || toggle.dataset.notificationDefaultState || "off"
  }

  applyState(toggle, state) {
    const stateLabel = toggle.querySelector("[data-notification-toggles-target='state']")
    const isOn = state === "on"

    toggle.classList.toggle("profile-sidebar__control--active", isOn)
    toggle.setAttribute("aria-pressed", isOn.toString())
    stateLabel.textContent = isOn ? "On" : "Off"
    stateLabel.classList.toggle("profile-sidebar__control-state--active", isOn)
  }

  syncRecommendations() {
    if (!this.hasRecommendationTextTarget || !this.hasRecommendationCalloutTarget) return

    const recommendationsEnabled = (this.savedStates["recommendation-updates"] || "off") === "on"

    this.recommendationCalloutTarget.classList.toggle("profile-rail-callout--active", recommendationsEnabled)
    this.recommendationTextTarget.textContent = recommendationsEnabled
      ? "Recommendation updates are on. As you follow more games and activity grows, this section will surface suggestions for you."
      : "Recommendation updates are off right now. Turn them on in the sidebar to start building this feed."

    if (this.hasRecommendationActionTarget) {
      this.recommendationActionTarget.classList.toggle("d-none", !recommendationsEnabled)
    }
  }

  loadStates() {
    try {
      return JSON.parse(window.localStorage.getItem(STORAGE_KEY)) || {}
    } catch (error) {
      return {}
    }
  }

  persistStates() {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(this.savedStates))
  }
}
