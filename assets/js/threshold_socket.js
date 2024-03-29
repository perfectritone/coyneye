import {Socket} from "phoenix"

const connectThresholdSocket = () => {
  // And connect to the path in "lib/coyneye_web/endpoint.ex". We pass the
  // token for authentication. Read below how it should be used.
  let userId = window.userId
  let thresholdSocket = new Socket("/threshold_socket", {params: {token: window.userToken}})

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

  thresholdSocket.connect()

  let thresholdChannel = thresholdSocket.channel(`threshold:eth_usd:${userId}`, {})
  let maxThresholdContainer = document.querySelector("#max-threshold-amount")
  let minThresholdContainer = document.querySelector("#min-threshold-amount")

  thresholdChannel.on("max_threshold_met", payload => {
    let newThreshold = payload.new_max_threshold || ''
    maxThresholdContainer.innerText = `(${newThreshold})`
  })

  thresholdChannel.on("min_threshold_met", payload => {
    let newThreshold = payload.new_min_threshold || ''
    minThresholdContainer.innerText = `(${newThreshold})`
  })

  thresholdChannel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })
}

if (window.userId && window.userToken) connectThresholdSocket()
