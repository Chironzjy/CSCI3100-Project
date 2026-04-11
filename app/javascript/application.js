// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import * as ActiveStorage from "@rails/activestorage"
import "@hotwired/turbo-rails"
import "controllers"
import "channels/conversation_channel"

ActiveStorage.start()

function initUserMenu() {
  const toggles = document.querySelectorAll("[data-user-menu-toggle]")
  if (!toggles.length) return

  const closeAllMenus = () => {
    toggles.forEach((toggle) => {
      const menu = toggle.parentElement.querySelector("[data-user-menu]")
      if (!menu) return
      toggle.setAttribute("aria-expanded", "false")
      menu.classList.remove("show")
    })
  }

  if (!window.userMenuOutsideHandlerAttached) {
    document.addEventListener("click", (event) => {
      if (!event.target.closest("[data-user-menu-toggle]") && !event.target.closest("[data-user-menu]")) {
        closeAllMenus()
      }
    })
    window.userMenuOutsideHandlerAttached = true
  }

  toggles.forEach((toggle) => {
    if (toggle.dataset.boundUserMenu === "true") return

    toggle.addEventListener("click", (event) => {
      event.preventDefault()
      event.stopPropagation()

      const menu = toggle.parentElement.querySelector("[data-user-menu]")
      if (!menu) return

      const isOpen = menu.classList.contains("show")
      closeAllMenus()

      if (!isOpen) {
        menu.classList.add("show")
        toggle.setAttribute("aria-expanded", "true")
      }
    })

    toggle.dataset.boundUserMenu = "true"
  })
}

document.addEventListener("turbo:load", initUserMenu)
