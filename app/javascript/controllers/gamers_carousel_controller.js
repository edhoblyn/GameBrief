import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track"]

  connect() {
    this.index = 0
    this.cards = Array.from(this.trackTarget.querySelectorAll(".gamers-carousel__card"))
    this.total = this.cards.length
    this.startAutoplay()
    this.element.addEventListener("mouseenter", () => this.stopAutoplay())
    this.element.addEventListener("mouseleave", () => this.startAutoplay())
  }

  disconnect() {
    this.stopAutoplay()
  }

  next() {
    this.index = (this.index + 1) % this.total
    this.slide()
    this.resetAutoplay()
  }

  prev() {
    this.index = (this.index - 1 + this.total) % this.total
    this.slide()
    this.resetAutoplay()
  }

  slide() {
    const card = this.cards[0]
    const gap = parseInt(getComputedStyle(this.trackTarget).gap) || 16
    const offset = this.index * (card.offsetWidth + gap)
    this.trackTarget.style.transform = `translateX(-${offset}px)`
  }

  startAutoplay() {
    this.timer = setInterval(() => this.next(), 3500)
  }

  stopAutoplay() {
    clearInterval(this.timer)
  }

  resetAutoplay() {
    this.stopAutoplay()
    this.startAutoplay()
  }
}
