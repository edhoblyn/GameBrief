import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  play(event) {
    const audio = new Audio("/assets/noway.wav")
    audio.play().catch(() => {})
  }
}
