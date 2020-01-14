defmodule Server.Listener do
  @moduledoc """
  doc
  """
  @connect_succ <<0x05, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>>
  @connect_fail <<0x05, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00>>

  alias Server.Tunnel
  require Logger

  def start_loop() do
    Task.Supervisor.start_child(Server.TaskSupervisor, fn -> loop_serve() end)
  end

  def loop_serve() do
    {sid, data} = Tunnel.decode_recv()
    Logger.debug("recv from tunnel: #{inspect(data)}")
    process(data, sid)
    loop_serve()
  end

  # handshake
  defp process(<<0x05::8, 0x01::8, 0x00::8>>, sid), do: Tunnel.encode_send(sid, <<0x05, 0x00>>)

  # connect by ip
  defp process(<<0x05::8, 0x01::8, 0x00::8, 0x01::8, _addr::binary>> = data, sid),
    do: Task.start(fn -> connect_remote(sid, data) end)

  # connect by hostname
  defp process(<<0x05::8, 0x01::8, 0x00::8, 0x03::8, _addr::binary>> = data, sid),
    do: Task.start(fn -> connect_remote(sid, data) end)

  defp process(data, sid) do
    case Server.SockStore.lookup(sid) do
      nil ->
        Logger.warn("closed sock: #{inspect(sid)}")

      rsock ->
        Socket.Stream.send(rsock, data)
    end
  end

  defp connect_remote(sid, data) do
    with {ipaddr, port} <- parse_remote_addr(data),
         {:ok, rsock} <- Socket.TCP.connect(addr, port) do
      Server.SockStore.register(sid, rsock)
      Tunnel.encode_send(sid, @connect_succ)
      serve_remote(sid, rsock)
    else
      _ ->
        Tunnel.encode_send(sid, @connect_fail)
    end
  end

  # ip类型
  defp parse_remote_addr(<<_pre::24, 0x01::8, ip1::8, ip2::8, ip3::8, ip4::8, port::16>>),
    do: {"#{ip1}.#{ip2}.#{ip3}.#{ip4}", port}

  # hostname类型
  defp parse_remote_addr(<<_pre::24, 0x03::8, len::8, addr::binary>>) do
    host_size = 8 * len

    hostname = binary_part(addr, 0, len)
    Logger.debug("hostname: #{hostname}")

    {:ok, {:hostent, _, _, :inet, 4, [{ip1, ip2, ip3, ip4} | _]}} =
      :inet.gethostbyname(to_charlist(hostname))

    <<_::size(host_size), port::16>> = addr

    {"#{ip1}.#{ip2}.#{ip3}.#{ip4}", port}
  end

  defp serve_remote(sid, rsock) do
    case Socket.Stream.recv(rsock) do
      {:ok, data} when data != nil ->
        Tunnel.encode_send(sid, data)
        serve_remote(sid, rsock)

      _ ->
        Logger.warn("remote sock closed")
        Server.SockStore.unregister(sid)
        Socket.Stream.close(rsock)
    end
  end
end
