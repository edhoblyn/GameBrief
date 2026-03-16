import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "panel", "input"]
  static values = { open: Boolean }

  connect() {
    this.render()
  }

  toggle() {
    this.openValue = !this.openValue
    this.render()
  }

  submit() {
    this.openValue = false
    this.render()
  }

  render() {
    if (this.hasPanelTarget) {
      this.panelTarget.hidden = !this.openValue
    }

    if (this.hasTriggerTarget) {
      this.triggerTarget.classList.toggle("home-games__suggestion-trigger--active", this.openValue)
      this.triggerTarget.setAttribute("aria-expanded", this.openValue.toString())
    }

    if (this.openValue && this.hasInputTarget) {
      requestAnimationFrame(() => this.inputTarget.focus())
    }
  }
}
