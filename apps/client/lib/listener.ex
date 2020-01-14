defmodule Client.Listener do
  @moduledoc """
  本地监听
  """

  @local_port 1080

  require Logger
  alias Client.Tunnel

  def listen() do
    {:ok, listener} = Socket.TCP.listen(@local_port)
    Logger.info("listening on port #{@local_port}")
    loop_accept(listener)
  end

  defp loop_accept(listener) do
    {:ok, client} = Socket.TCP.accept(listener)
    sid = gen_socket_id()
    Client.SockStore.register(sid, client)
    Task.Supervisor.start_child(Client.TaskSupervisor, fn -> serve_local(sid, client) end)
    loop_accept(listener)
  end

  defp serve_local(sid, client) do
    case Socket.Stream.recv(client) do
      {:ok, data} when data != nil ->
        Logger.debug("recv from local: #{inspect(data)}")
        Tunnel.encode_send(sid, data)
        serve_local(sid, client)

      _ ->
        Logger.debug("client socket exit")
        Socket.Stream.close(client)
        Client.SockStore.unregister(sid)
    end
  end

  defp gen_socket_id(), do: <<Enum.random(0..255), Enum.random(0..255)>>
end
