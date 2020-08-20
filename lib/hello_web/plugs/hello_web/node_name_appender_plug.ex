defmodule HelloWeb.NodeNameAppenderPlug do
  @behaviour Plug

  def init(_opts) do
  end

  def call(conn, _), do: Plug.Conn.put_resp_header(conn, "x-node-name", "#{Node.self}")

end
