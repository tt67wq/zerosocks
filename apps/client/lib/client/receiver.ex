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
    process_data(sid, data)
    run()
  end

  defp process_data(sid, data) do
    case Client.SockStore.lookup(sid) do
      nil ->
        Logger.warn("ignored data: #{inspect(data)}")

      client ->
        Socket.Stream.send(client, data)
    end
  end
end
