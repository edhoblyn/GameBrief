import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "menu"]

  connect() {
    this.handleDocumentClick = this.handleDocumentClick.bind(this)
    this.handleDocumentKeydown = this.handleDocumentKeydown.bind(this)

    document.addEventListener("click", this.handleDocumentClick)
    document.addEventListener("keydown", this.handleDocumentKeydown)
  }

  disconnect() {
    document.removeEventListener("click", this.handleDocumentClick)
    document.removeEventListener("keydown", this.handleDocumentKeydown)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.hidden = false
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.element.classList.add("is-open")
  }

  close() {
    this.menuTarget.hidden = true
    this.buttonTarget.setAttribute("aria-expanded", "false")
    this.element.classList.remove("is-open")
  }

  handleDocumentClick(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  handleDocumentKeydown(event) {
    if (event.key === "Escape") this.close()
  }

  get isOpen() {
    return !this.menuTarget.hidden
  }
}
