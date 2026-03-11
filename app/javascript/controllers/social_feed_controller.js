import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tabBtn", "tabPanel"]

  switchTab(event) {
    const tab = event.currentTarget.dataset.tab

    this.tabBtnTargets.forEach(btn => {
      btn.classList.toggle("active", btn.dataset.tab === tab)
    })

    this.tabPanelTargets.forEach(panel => {
      panel.classList.toggle("d-none", panel.dataset.panel !== tab)
    })
  }

  toggleLike(event) {
    const btn = event.currentTarget
    const isLiked = btn.classList.contains("is-liked")
    const icon = btn.querySelector("i")
    const countEl = btn.querySelector(".interaction-count")
    const count = this.parseCount(countEl.textContent.trim())

    btn.classList.toggle("is-liked")
    if (isLiked) {
      icon.classList.replace("fa-heart", "fa-heart-o")
      countEl.textContent = this.formatCount(count - 1)
    } else {
      icon.classList.replace("fa-heart-o", "fa-heart")
      countEl.textContent = this.formatCount(count + 1)
    }
  }

  toggleRepost(event) {
    const btn = event.currentTarget
    const isReposted = btn.classList.contains("is-reposted")
    const countEl = btn.querySelector(".interaction-count")
    const count = this.parseCount(countEl.textContent.trim())

    btn.classList.toggle("is-reposted")
    countEl.textContent = this.formatCount(isReposted ? count - 1 : count + 1)
  }

  toggleFollow(event) {
    const btn = event.currentTarget
    const isFollowing = btn.classList.contains("is-following")
    btn.classList.toggle("is-following")
    btn.textContent = isFollowing ? "Follow" : "Following"
  }

  toggleCommunity(event) {
    const btn = event.currentTarget
    const isJoined = btn.classList.contains("btn-community--joined")
    btn.classList.toggle("btn-community--joined")
    btn.textContent = isJoined ? "Join" : "Joined ✓"
  }

  parseCount(str) {
    if (str.endsWith("K")) return Math.round(parseFloat(str) * 1000)
    return parseInt(str, 10) || 0
  }

  formatCount(n) {
    if (n >= 10000) return (n / 1000).toFixed(0) + "K"
    if (n >= 1000) return (n / 1000).toFixed(1).replace(/\.0$/, "") + "K"
    return n.toString()
  }
}
