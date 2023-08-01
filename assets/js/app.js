// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

import "../css/app.css"

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import "./price_socket.js"
import "./threshold_socket.js"
import "./price.js"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Reload the page when it comes back into visibility.
//
// On mobile, websockets timeout after 60 seconds in firefox when the tab is
// not in focus. This leads to the socket almost always being closed when
// returning to the tab, with stale data. Phoenix attempts to remedy this
// by listening to the 'pageshow' and 'pagehide' events and reconnecting to
// the socket, but these events only really work properly on desktop browsers,
// not mobile.
//
// Regardless, even with a reconnect, the data would still be stale since all
// updates after disconnection will have been missed. A more complicated
// approach would involve checking the socket connection, reconnecting if
// necessary and requesting the relevant data. This is cleaner, but with
// the current complexity of this page, a reload is cheaper and much easier.
const phxWindow = typeof window !== "undefined" ? window : null

if(phxWindow && phxWindow.addEventListener){
  phxWindow.addEventListener("visibilitychange", _event => {
    if(phxWindow.document.visibilityState == 'visible') {
      location.reload()
    }
  })
}

