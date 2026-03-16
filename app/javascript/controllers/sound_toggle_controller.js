import { Controller } from "@hotwired/stimulus"

const SOUND_STORAGE_KEY = "gamebrief-sound-muted"

export default class extends Controller {
  connect() {
    this.apply()
  }

  toggle() {
    const muted = localStorage.getItem(SOUND_STORAGE_KEY) === "true"
    localStorage.setItem(SOUND_STORAGE_KEY, (!muted).toString())
    document.documentElement.dataset.soundMuted = (!muted).toString()
    this.apply()
  }

  apply() {
    const muted = localStorage.getItem(SOUND_STORAGE_KEY) === "true"
    this.element.classList.toggle("app-settings-menu__sound-button--muted", muted)
    this.element.classList.toggle("app-settings-menu__sound-button--enabled", !muted)
    this.element.setAttribute("aria-pressed", muted.toString())
    this.element.setAttribute("aria-label", muted ? "Sound effects off" : "Sound effects on")

    const icon = this.element.querySelector(".app-settings-menu__sound-icon")
    if (icon) {
      icon.classList.remove("fa-volume-up", "fa-volume-off")
      icon.classList.add(muted ? "fa-volume-off" : "fa-volume-up")
    }
  }
}
