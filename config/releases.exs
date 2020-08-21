import Config

config :hello, HelloWeb.Endpoint,
       url: [host: System.get_env("HOST"), port: 443, scheme: "https"]

config :hello,
       secret_key_base: System.get_env("SECRET_KEY_BASE")

# Configure logger to output to $LOG_PATH file (last time checked: /var/log/webapp/production.log)


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
