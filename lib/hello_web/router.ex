defmodule HelloWeb.Router do
  use HelloWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug HelloWeb.NodeNameAppenderPlug
  end

  scope "/", HelloWeb do
    pipe_through :api

    get "/", PageController, :index
    get "/isItWorking", HealthController, :is_it_working
    get "/whoAmI", HealthController, :who_am_i
    get "/health", HealthController, :health
  end

  # Other scopes may use custom stacks.
  # scope "/api", HelloWeb do
  #   pipe_through :api
  # end
end
