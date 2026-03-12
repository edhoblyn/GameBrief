import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "gamebrief:profile-notification-toggles"

export default class extends Controller {
  static targets = ["toggle", "state"]

  connect() {
    this.savedStates = this.loadStates()
    this.toggleTargets.forEach((toggle) => this.applyState(toggle, this.currentState(toggle)))
  }

  toggle(event) {
    const toggle = event.currentTarget
    const nextState = this.currentState(toggle) === "on" ? "off" : "on"

    this.savedStates[toggle.dataset.notificationKey] = nextState
    this.persistStates()
    this.applyState(toggle, nextState)
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
