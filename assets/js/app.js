import '../css/app.scss'

import 'phoenix_html'
import { Socket } from 'phoenix'
import NProgress from 'nprogress'
import { LiveSocket } from 'phoenix_live_view'
import 'alpinejs'

window.Alpine.addMagicProperty('phx', function (componentEl) {
  let phxEl = componentEl.closest('[data-phx-view]')

  if (!phxEl)
    console.warn(
      'Alpine: Cannot reference "$phx" outside a Phoenix LiveView component.'
    )

  let view = liveSocket.getViewByEl(phxEl)

  return view
})

const Hooks = {}

Hooks.Modal = {
  mounted () {
    window.modalHook = this
  },
  destroyed () {
    window.modalHook = null
  },
  modalClosing (leaveDuration) {
    // Inform modal component when leave transition completes.
    setTimeout(() => {
      var selector = '#' + this.el.id
      if (document.querySelector(selector)) {
        this.pushEventTo(selector, 'modal-closed', {})
      }
    }, leaveDuration)
  }
}

Hooks.ConnectionStatus = {
  mounted () {
    window.connected = true
  },
  disconnected () {
    window.connected = false
  },
  reconnected () {
    window.connected = true
  }
}

Hooks.Flash = {
  mounted () {
    window.flashHook = this
    this.closeTimeoutId = null
  },
  destroyed () {
    window.flashHook = null
  },
  flashOpened (key, timeout) {
    this.clearCloseFlashTimeout()
    if (key && timeout > 0) {
      this.closeTimeoutId = setTimeout(() => this.closeFlash(key), timeout)
    }
  },
  closeFlash (key) {
    this.clearCloseFlashTimeout()
    if (key) {
      this.pushEvent('lv:clear-flash', {
        key: key
      })
    }
  },
  clearCloseFlashTimeout () {
    if (this.closeTimeoutId != null) {
      clearTimeout(this.closeTimeoutId)
      this.closeTimeoutId = null
    }
  }
}

Hooks.FlashNotice = {
  mounted () {
    this.handleEvent('show-flash-notice', ({ kind, message }) => {
      let timeout = kind === 'info' ? 10000 : 0
      event = new CustomEvent('flash-notice', {
        detail: {
          kind: kind,
          message: message,
          timeout: timeout
        }
      })
      this.el.dispatchEvent(event)
    })
  }
}

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute('content')

let liveSocket = new LiveSocket('/live', Socket, {
  dom: {
    onBeforeElUpdated (from, to) {
      if (from.__x) {
        window.Alpine.clone(from.__x, to)
      }
    }
  },
  params: {
    _csrf_token: csrfToken
  },
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
window.addEventListener('phx:page-loading-start', info => NProgress.start())
window.addEventListener('phx:page-loading-stop', info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// liveSocket.enableDebug()
// liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
