defmodule Server do
  @moduledoc """
  Documentation for Server.
  """
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Server.SockStore},
      Server.Tunnel,
      {Task.Supervisor, name: Server.TaskSupervisor}
      # {Task, fn -> Server.Listener.loop_serve() end}
    ]

    opts = [strategy: :one_for_one, name: Server.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
