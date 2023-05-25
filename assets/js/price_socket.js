// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import {Socket} from "phoenix"

// And connect to the path in "lib/coyneye_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.
let socket = new Socket("/socket", {timeout: 100000, heartbeatIntervalMs: 10000, params: {token: window.userToken}})

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
let openSocketContainer = document.querySelector("#open-socket-time")
let closeSocketContainer = document.querySelector("#close-socket-time")
let errorSocketContainer = document.querySelector("#error-socket-time")
let pageshowContainer = document.querySelector("#page-show-time")
let pagehideContainer = document.querySelector("#page-hide-time")
let currentTime = function() {
  var today = new Date()
  return today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds()
}

const phxWindow = typeof window !== "undefined" ? window : null
if(phxWindow && phxWindow.addEventListener){
  phxWindow.addEventListener("visibilitychange", event => {
    //let isPersisted = event.persisted ? "persisted" : "not persisted"
    switch (phxWindow.document.visibilityState) {
      case 'hidden':
        pagehideContainer.innerText = "Page hidden at: " + currentTime()
        break
      case 'visible':
      pageshowContainer.innerText = "Page last shown at: " + currentTime()
        break
      default:
      pageshowContainer.innerText = "weird page visibility"
        break
    }
  })
}
socket.onOpen(callback => {
  openSocketContainer.innerText = "Socket open at: " + currentTime()
})
socket.onClose(callback => {
  closeSocketContainer.innerText = "Socket close at: " + currentTime()
})
socket.onError(callback => {
  errorSocketContainer.innerText = "Socket error at: " + currentTime()
})
socket.connect()

// Now that you are connected, you can join channels with a topic.
// Let's assume you have a channel with a topic named `price` and the
// subtopic is its id - in this case 42:
let priceChannel = socket.channel("price:eth_usd", {})
let priceContainer = document.querySelector("#price")

// Debugging
let openContainer = document.querySelector("#open-time")
let lastContainer = document.querySelector("#last-update-time")
let closeContainer = document.querySelector("#close-time")
let errorContainer = document.querySelector("#error-time")

priceChannel.on("new_price", payload => {
  priceContainer.innerText = payload.formatted_price
  lastContainer.innerText = "Last price at " + currentTime()
})

// Debugging
priceChannel.onClose(callback => {
  closeContainer.innerText = "Close at: " + currentTime()
})
priceChannel.onError(function(error) {
  errorContainer.innerText = "Error at: " + currentTime()
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
  .receive("ok", resp => { openContainer.innerText = "Open at " + currentTime(); console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })
thresholdChannel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
