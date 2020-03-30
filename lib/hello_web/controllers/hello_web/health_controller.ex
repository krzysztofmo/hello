defmodule HelloWeb.HealthController do
  use HelloWeb, :controller

  def is_it_working(conn, _params) do
    text(conn, "I am working.")
  end
end
