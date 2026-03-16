import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit(event) {
    event.preventDefault()
    const btn = this.element.querySelector(".game-card__follow-btn")
    btn.classList.add("game-card__follow-btn--falling")
    btn.addEventListener("animationend", () => this.element.submit(), { once: true })
  }
}
