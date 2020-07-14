import "../css/app.scss"

import "phoenix_html"
import {
  Socket
} from "phoenix"
import NProgress from "nprogress"
import {
  LiveSocket
} from "phoenix_live_view"
import "alpinejs"

const Hooks = {}

Hooks.Modal = {
  mounted() {
    window.modalHook = this
  },
  destroyed() {
    window.modalHook = null
  },
  modalClosing(leaveDuration) {
    // Inform modal component when leave transition completes.
    setTimeout(() => {
      var selector = '#' + this.el.id
      if (document.querySelector(selector)) {
        this.pushEventTo(selector, 'modal-closed', {})
      }
    }, leaveDuration);
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute('content')
let liveSocket = new LiveSocket('/live', Socket, {
  dom: {
    onBeforeElUpdated(from, to) {
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
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// liveSocket.enableDebug()
// liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
