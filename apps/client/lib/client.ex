defmodule Client do
  @moduledoc """
  Documentation for Client.
  """

  def start(_type, _args) do
    children = [
      # {Task.Supervisor, name: SsLocal.TaskSupervisor},
      {Registry, keys: :unique, name: Client.SockStore},
      Client.Tunnel,
      Client.PingPong,
      {Task, fn -> Client.Listener.listen() end},
      {Task.Supervisor, name: Client.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Client.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
