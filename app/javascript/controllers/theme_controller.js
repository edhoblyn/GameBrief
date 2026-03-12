import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "gamebrief-theme"
const DEFAULT_THEME = "nebula"
const THEMES = new Set(["nebula", "ion", "toxic", "ember"])

export default class extends Controller {
  static targets = ["option"]

  connect() {
    const savedTheme = localStorage.getItem(STORAGE_KEY)
    this.applyTheme(THEMES.has(savedTheme) ? savedTheme : DEFAULT_THEME)
  }

  select(event) {
    const themeName = event.currentTarget.dataset.themeName
    if (!THEMES.has(themeName)) return

    this.applyTheme(themeName)
    localStorage.setItem(STORAGE_KEY, themeName)

    const details = event.currentTarget.closest("details")
    if (details) details.open = false
  }

  applyTheme(themeName) {
    document.documentElement.setAttribute("data-theme", themeName)
    this.optionTargets.forEach((option) => {
      const active = option.dataset.themeName === themeName
      option.classList.toggle("app-settings-menu__theme-option--active", active)
      option.setAttribute("aria-pressed", active)
    })
  }
}
