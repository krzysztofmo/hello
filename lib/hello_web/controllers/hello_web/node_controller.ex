defmodule HelloWeb.NodeController do
  use HelloWeb, :controller

  def index(conn, _) do
    text(conn, "#{Node.list ++ [Node.self] |> Enum.join(", ")}")
  end

end
