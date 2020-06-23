defmodule HelloWeb.LayoutView do
  use HelloWeb, :view

  def node_name() do
    Node.self()
  end

end
