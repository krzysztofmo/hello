use Mix.Config

config :libcluster,
       topologies: [
         kx_widget: [
           strategy: Cluster.Strategy.Epmd,
           config: [
             hosts: System.get_env("CLUSTER_NODES", "") |> String.split(",") |> Enum.map(&String.to_atom(&1))
           ],
         ]
       ]

config :epmdless,
  dist_proto_port: System.get_env("DIST_PROTO_PORT")

#
#config :libcluster,
#       topologies: [
#         kx_widget: [
#           strategy: Cluster.Strategy.ErlangHosts,
#           config: [timeout: 30_000]
#         ]
#       ]