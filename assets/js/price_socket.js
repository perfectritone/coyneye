// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import {Socket} from "phoenix"

// And connect to the path in "lib/coyneye_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.
let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/coyneye_web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/coyneye_web/templates/layout/app.html.heex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/coyneye_web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:

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

socket.connect()

// Now that you are connected, you can join channels with a topic.
// Let's assume you have a channel with a topic named `price` and the
// subtopic is its id - in this case 42:
let priceChannel = socket.channel("price:eth_usd", {})
let priceContainer = document.querySelector("#price")

priceChannel.on("new_price", payload => {
  priceContainer.innerText = payload.formatted_price
})

let thresholdChannel = socket.channel("threshold:eth_usd", {})
let maxThresholdContainer = document.querySelector("#max-threshold-amount")
let minThresholdContainer = document.querySelector("#min-threshold-amount")

thresholdChannel.on("max_threshold_met", payload => {
  let new_threshold = payload.new_max_threshold || ''
  maxThresholdContainer.innerText = `(${new_threshold})`
})

thresholdChannel.on("min_threshold_met", payload => {
  let new_threshold = payload.new_min_threshold || ''
  minThresholdContainer.innerText = `(${new_threshold})`
})

priceChannel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })
thresholdChannel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
