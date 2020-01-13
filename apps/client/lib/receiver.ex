defmodule Client.Receiver do
  @moduledoc """
  本地接收者
  """
  require Logger

  def start_loop() do
    Task.Supervisor.start_child(Client.TaskSupervisor, fn -> run() end)
  end

  def run() do
    {sid, data} = Client.Tunnel.decode_recv()

    Logger.debug("recv from tunnel: #{inspect(data)}")

    case Client.SockStore.lookup(sid) do
      nil ->
        Logger.warn("ignored msg: #{inspect(data)}")

      client ->
        Socket.Stream.send(client, data)
    end

    run()
  end
end
