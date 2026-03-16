import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "form", "input", "submit", "counter", "counterValue", "limitMessage"]

  static values = {
    maxMessages: Number,
    streamUrl: String,
    userMessageCount: Number
  }

  connect() {
    this.submitLabel = this.hasSubmitTarget ? this.submitTarget.value : "Ask Chat"
    this.updateCounterState()
    this.scrollToBottom()
  }

  disconnect() {
    this.closeStream()
  }

  submit(event) {
    if (!this.hasStreamUrlValue) return

    event.preventDefault()
    if (this.isStreaming) return

    const content = this.inputTarget.value.trim()
    if (!content || this.limitReached()) return

    this.removeEmptyState()
    this.pendingUserMessage = this.appendMessage("user", content)
    this.pendingAssistantBubble = this.appendStreamingAssistantMessage()
    this.inputTarget.value = ""
    this.setSubmittingState(true)

    const url = new URL(this.streamUrlValue, window.location.origin)
    url.searchParams.set("content", content)

    this.streamAccepted = false
    this.streamCompleted = false
    this.closeStream()
    this.eventSource = new EventSource(url.toString())
    this.eventSource.addEventListener("accepted", (streamEvent) => this.handleAccepted(streamEvent))
    this.eventSource.addEventListener("token", (streamEvent) => this.handleToken(streamEvent))
    this.eventSource.addEventListener("done", () => this.handleDone())
    this.eventSource.addEventListener("error", (streamEvent) => this.handleError(streamEvent))
  }

  handleAccepted(streamEvent) {
    const data = this.parseEventData(streamEvent)
    this.streamAccepted = true

    if (typeof data.user_message_count === "number") {
      this.userMessageCountValue = data.user_message_count
    } else {
      this.userMessageCountValue += 1
    }

    this.updateCounterState()
  }

  handleToken(streamEvent) {
    const data = this.parseEventData(streamEvent)
    if (!data.token || !this.pendingAssistantBubble) return

    this.pendingAssistantBubble.textContent += data.token
    this.scrollToBottom()
  }

  handleDone() {
    this.streamCompleted = true

    if (this.pendingAssistantBubble) {
      this.pendingAssistantBubble.classList.remove("chatbot__bubble--streaming")
    }

    this.finishStream()
  }

  handleError(streamEvent) {
    if (this.streamCompleted) return

    const data = this.parseEventData(streamEvent)
    const message = this.errorMessageFor(data.error)

    if (!this.streamAccepted && this.pendingUserMessage) {
      this.pendingUserMessage.remove()
      this.pendingUserMessage = null
    }

    if (this.pendingAssistantBubble) {
      if (this.pendingAssistantBubble.textContent.trim() === "") {
        this.pendingAssistantBubble.textContent = message
      } else {
        this.pendingAssistantBubble.textContent = `${this.pendingAssistantBubble.textContent}\n\n${message}`
      }
      this.pendingAssistantBubble.classList.remove("chatbot__bubble--streaming")
    }

    if (data.error === "limit") {
      this.userMessageCountValue = this.maxMessagesValue
      this.updateCounterState()
    } else {
      this.restoreEmptyStateIfNeeded()
    }

    this.finishStream()
  }

  finishStream() {
    this.closeStream()
    this.pendingAssistantBubble = null
    this.pendingUserMessage = null
    this.setSubmittingState(false)
    this.scrollToBottom()
  }

  appendMessage(role, content) {
    const wrapper = document.createElement("div")
    wrapper.className = `chatbot__message chatbot__message--${role}`

    const bubble = document.createElement("div")
    bubble.className = "chatbot__bubble"
    bubble.textContent = content

    wrapper.appendChild(bubble)
    this.messagesTarget.appendChild(wrapper)
    this.scrollToBottom()
    return wrapper
  }

  appendStreamingAssistantMessage() {
    const wrapper = document.createElement("div")
    wrapper.className = "chatbot__message chatbot__message--assistant"

    const bubble = document.createElement("div")
    bubble.className = "chatbot__bubble chatbot__bubble--streaming"
    bubble.textContent = ""

    wrapper.appendChild(bubble)
    this.messagesTarget.appendChild(wrapper)
    this.scrollToBottom()
    return bubble
  }

  setSubmittingState(isSubmitting) {
    this.isStreaming = isSubmitting

    if (this.hasInputTarget) {
      this.inputTarget.disabled = isSubmitting || this.limitReached()
    }

    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = isSubmitting || this.limitReached()
      this.submitTarget.value = isSubmitting ? "Thinking..." : this.submitLabel
    }
  }

  updateCounterState() {
    if (this.hasCounterValueTarget) {
      this.counterValueTarget.textContent = `${this.userMessageCountValue}/${this.maxMessagesValue}`
    }

    if (this.hasCounterTarget) {
      this.counterTarget.className = this.counterClassNames()
    }

    if (this.hasLimitMessageTarget) {
      this.limitMessageTarget.hidden = !this.limitReached()
    }

    if (!this.isStreaming) {
      this.setSubmittingState(false)
    }
  }

  counterClassNames() {
    const classes = ["chatbot__counter"]

    if (this.limitReached()) {
      classes.push("chatbot__counter--limit")
    } else if (this.userMessageCountValue >= this.maxMessagesValue - 1) {
      classes.push("chatbot__counter--warning")
    }

    return classes.join(" ")
  }

  limitReached() {
    return this.userMessageCountValue >= this.maxMessagesValue
  }

  removeEmptyState() {
    const emptyState = this.messagesTarget.querySelector(".chatbot__empty")
    if (emptyState) emptyState.remove()
  }

  restoreEmptyStateIfNeeded() {
    if (this.messagesTarget.querySelector(".chatbot__message")) return
    if (this.messagesTarget.querySelector(".chatbot__empty")) return

    const emptyState = document.createElement("p")
    emptyState.className = "chatbot__empty"
    emptyState.textContent = 'Ask anything about this patch — e.g. "What changed for snipers?" or "Should I log in?"'
    this.messagesTarget.appendChild(emptyState)
  }

  closeStream() {
    if (!this.eventSource) return

    this.eventSource.close()
    this.eventSource = null
  }

  scrollToBottom() {
    if (!this.hasMessagesTarget) return
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  parseEventData(streamEvent) {
    try {
      return streamEvent.data ? JSON.parse(streamEvent.data) : {}
    } catch (_error) {
      return {}
    }
  }

  errorMessageFor(errorCode) {
    switch (errorCode) {
    case "limit":
      return "You have reached the 5-question limit for this chat."
    case "empty":
      return "Please enter a question before sending."
    default:
      return "Sorry, something went wrong while generating the response."
    }
  }
}
