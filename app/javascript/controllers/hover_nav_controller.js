import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.itemTargets.forEach(item => {
      item.addEventListener("mouseenter", () => this.#animateIn(item))
      item.addEventListener("mouseleave", () => this.#animateOut(item))
    })
  }

  disconnect() {
    this.itemTargets.forEach(item => {
      item.removeEventListener("mouseenter", () => this.#animateIn(item))
      item.removeEventListener("mouseleave", () => this.#animateOut(item))
    })
  }

  #animateIn(item) {
    item.classList.add("hovered")
  }

  #animateOut(item) {
    item.classList.remove("hovered")
  }
}
