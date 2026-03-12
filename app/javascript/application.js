import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("turbo:submit-start", () => {
  sessionStorage.setItem("scrollPos", window.scrollY)
})

document.addEventListener("turbo:load", () => {
  const pos = sessionStorage.getItem("scrollPos")
  if (pos) {
    window.scrollTo(0, parseInt(pos))
    sessionStorage.removeItem("scrollPos")
  }
})
