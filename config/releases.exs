import Config

#config :hello, HelloWeb.Endpoint,
#       url: [host: System.get_env("HOST"), port: 443, scheme: "https"]

config :hello, HelloWeb.Endpoint,
       secret_key_base: System.get_env("SECRET_KEY_BASE")

# Do not print debug messages in production
#config :logger,
#       backends: [{LoggerFileBackend, :prod_log}],
#       prod_log: [
#         path: System.get_env("LOG_PATH"),
#         format: "$date $time $metadata[$level]$levelpad $message\n",
#         metadata: [:request_id, :request_ip, :user_id, :user_agent]
#       ],
#       level: :info,
#       utc_log: true
