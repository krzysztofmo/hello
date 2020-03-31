// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {Socket} from "phoenix"

const socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()

// Now that you are connected, you can join channels with a topic:
const channel = socket.channel("room:lobby", {});
const chatInput = document.querySelector("#chat-input");
const messagesContainer = document.querySelector("#messages");

chatInput.addEventListener("keypress", event => {
  if (event.keyCode === 13) {
    channel.push("new_msg", {body: chatInput.value});
    chatInput.value = "";
  }
});

channel.on("new_msg", payload => {
  const messageItem = document.createElement("li");
  const opts = {
    year: 'numeric', month: 'numeric', day: 'numeric',
    hour: 'numeric', minute: 'numeric', second: 'numeric',
  };
  const dateFormat = new Intl.DateTimeFormat('pl-PL', opts);
  messageItem.innerText = `[${dateFormat.format(new Date())}][${payload.node}] ${payload.body}`;
  messagesContainer.appendChild(messageItem);
});

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
