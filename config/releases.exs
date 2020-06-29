import Config

config :hello, HelloWeb.Endpoint,
       url: [host: System.get_env("HOST"), port: 443, scheme: "https"]

config :hello,
       secret_key_base: System.get_env("SECRET_KEY_BASE")

# Configure logger to output to $LOG_PATH file (last time checked: /var/log/webapp/production.log)
config :logger,
       backends: [{LoggerFileBackend, :prod_log}],
       prod_log: [
         path: System.get_env("LOG_PATH"),
         format: "$date $time $metadata[$level]$levelpad $message\n",
         metadata: [:request_id, :request_ip, :user_id, :user_agent]
       ],
       level: :info,
       utc_log: true

config :libcluster,
       topologies: [
         hello: [
           strategy: Cluster.Strategy.Kubernetes,
           config: [
             mode: :ip,
             kubernetes_node_basename: System.get_env("RELEASE_BASENAME"),
             kubernetes_namespace: System.get_env("NAMESPACE"),
             kubernetes_selector: "app=hello-elixir"
           ],
         ]
       ]
#
#config :epmdless,
#       dist_proto_port: System.get_env("DIST_PROTO_PORT")
