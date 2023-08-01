import {Socket} from "phoenix"

let priceSocket = new Socket("/price_socket", {params: {}})

priceSocket.connect()

// Now that you are connected, you can join channels with a topic.
// Let's assume you have a channel with a topic named `price` and the
// subtopic is its id - in this case `eth_usd`:
let priceChannel = priceSocket.channel("price:eth_usd", {})
let priceContainer = document.querySelector("#price")

priceChannel.on("new_price", payload => {
  priceContainer.innerText = payload.formatted_price
})

priceChannel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default priceSocket
