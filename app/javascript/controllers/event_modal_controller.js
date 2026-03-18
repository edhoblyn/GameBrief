import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["body"]

  open(event) {
    event.preventDefault()
    const url = event.currentTarget.getAttribute("href") + "?modal=true"

    fetch(url, {
      headers: { "Accept": "text/html", "X-Requested-With": "XMLHttpRequest" }
    })
      .then(r => r.text())
      .then(html => {
        this.bodyTarget.innerHTML = html
        bootstrap.Modal.getOrCreateInstance(
          document.getElementById("event-modal")
        ).show()
      })
  }
}
