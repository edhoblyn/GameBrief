import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "count"]

  update() {
    const length = this.inputTarget.value.length
    this.countTarget.textContent = length

    if (length >= 160) {
      this.countTarget.classList.add("edit-profile-form__char-count--limit")
    } else {
      this.countTarget.classList.remove("edit-profile-form__char-count--limit")
    }
  }
}
