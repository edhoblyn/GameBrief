import { Controller } from "@hotwired/stimulus"

const SOUND_STORAGE_KEY = "gamebrief-sound-muted"

export default class extends Controller {
  play() {
    if (localStorage.getItem(SOUND_STORAGE_KEY) === "true") return

    const audio = new Audio("/assets/noway.wav")
    audio.play().catch(() => {})
  }
}
