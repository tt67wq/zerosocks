use Mix.Config

config :logger,
  backends: [{LoggerFileBackend, :info_log}]

config :logger, :info_log,
  format: "$date $time $metadata [$level] $message\n",
  path: "/var/log/zerosocks/zerosocks.log",
  metadata: [:line, :file],
  level: :debug
