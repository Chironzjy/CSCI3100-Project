import consumer from "channels/consumer"

let subscription

function escapeHtml(str) {
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/\"/g, "&quot;")
    .replace(/'/g, "&#39;")
}

function renderMessage(data, currentUserId) {
  const mine = Number(data.sender_id) === Number(currentUserId)
  const safeName = escapeHtml(data.sender_name)
  const safeBody = escapeHtml(data.body).replace(/\n/g, "<br>")
  const safeTime = escapeHtml(data.created_at)
  const wrapper = document.createElement("div")
  wrapper.className = `d-flex mb-2 ${mine ? "justify-content-end" : "justify-content-start"}`

  wrapper.innerHTML = `
    <div class="chat-bubble ${mine ? "chat-bubble-me" : "chat-bubble-other"}">
      <div class="small fw-semibold mb-1">${safeName}</div>
      <div>${safeBody}</div>
      <div class="chat-time">${safeTime}</div>
    </div>
  `

  return wrapper
}

function setupConversationSubscription() {
  const container = document.querySelector("#messages[data-conversation-id]")
  if (!container) {
    if (subscription) {
      consumer.subscriptions.remove(subscription)
      subscription = null
    }
    return
  }

  const conversationId = container.dataset.conversationId
  const currentUserId = container.dataset.currentUserId

  if (subscription) {
    consumer.subscriptions.remove(subscription)
    subscription = null
  }

  subscription = consumer.subscriptions.create(
    { channel: "ConversationChannel", conversation_id: conversationId },
    {
      received(data) {
        container.appendChild(renderMessage(data, currentUserId))
        container.scrollTop = container.scrollHeight
      }
    }
  )

  container.scrollTop = container.scrollHeight
}

document.addEventListener("turbo:load", setupConversationSubscription)
