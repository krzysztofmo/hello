defmodule HelloWeb.HealthController do
  use HelloWeb, :controller

  def is_it_working(conn, _params) do
    text(conn, "I am working.")
  end

  def who_am_i(conn, _params) do
    text(conn, "You've hit #{Node.self()}")
  end

  def health(conn, _) do
    text(conn, "Other nodes: #{Node.list() |> Enum.join(", ")}, node cookie: #{Node.get_cookie()}")
  end

end
