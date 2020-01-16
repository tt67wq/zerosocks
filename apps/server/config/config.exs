use Mix.Config

config :logger,
  backends: [{LoggerFileBackend, :info_log}]

config :logger, :info_log,
  format: "$date $time $metadata [$level] $message\n",
  path: "/root/zerosocks.log",
  metadata: [:line, :file],
  level: :debug
