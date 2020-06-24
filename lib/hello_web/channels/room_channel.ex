defmodule HelloWeb.RoomChannel do
  use Phoenix.Channel

  require Logger

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    Logger.info("==> Received message: #{body} <==")
    broadcast!(socket, "new_msg", %{body: body, node: to_string(Node.self())})
    {:noreply, socket}
  end

end