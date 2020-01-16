defmodule Server.Tunnel do
  @moduledoc """
  通道
  """

  @port 5555
  @key "HelloWorld"
  @base_id "xyz"

  use GenServer
  require Logger

  def start_link(args) do
    name = Keyword.get(args, :name, __MODULE__)
    GenServer.start_link(__MODULE__, args, name: name)
  end

  def recv() do
    socket = Server.SockStore.lookup(@base_id)
    {:ok, [data]} = :chumak.recv_multipart(socket)
    data
  end

  def decode_recv() do
    <<sid::size(16), data::binary>> =
      recv()
      |> Common.Crypto.aes_decrypt(@key, base64: false)

    {<<sid::size(16)>>, <<data::binary>>}
  end

  def send2(data) do
    GenServer.cast(__MODULE__, {:send, data})
  end

  def encode_send(sid, data) do
    (sid <> data)
    |> Common.Crypto.aes_encrypt(@key, base64: false)
    |> send2()
  end

  #### callback

  def init(_args) do
    {:ok, socket} = :chumak.socket(:pair)
    {:ok, _} = :chumak.bind(socket, :tcp, '0.0.0.0', @port)
    Process.send_after(self(), :register, 1000)
    {:ok, %{socket: socket}}
  end

  def handle_info(:register, state) do
    Server.SockStore.register(@base_id, state.socket)
    Logger.info("start listening on port #{@port}")
    Server.Listener.start_loop()
    {:noreply, state}
  end

  def handle_cast({:send, data}, state) do
    :ok = :chumak.send_multipart(state.socket, [data])
    {:noreply, state}
  end
end