import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.lastScrollY = window.scrollY
    this.ticking = false
    this.hidden = false

    this.onScroll = () => {
      if (!this.ticking) {
        window.requestAnimationFrame(() => {
          this.handleScroll()
          this.ticking = false
        })
        this.ticking = true
      }
    }

    window.addEventListener("scroll", this.onScroll, { passive: true })
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
  }

  handleScroll() {
    const currentScrollY = window.scrollY
    const delta = currentScrollY - this.lastScrollY

    if (currentScrollY < 80) {
      this.show()
    } else if (delta > 6 && !this.hidden) {
      this.hide()
    } else if (delta < -6 && this.hidden) {
      this.show()
    }

    this.lastScrollY = currentScrollY
  }

  hide() {
    this.hidden = true
    this.element.classList.add("nav--hidden")
  }

  show() {
    this.hidden = false
    this.element.classList.remove("nav--hidden")
  }
}
