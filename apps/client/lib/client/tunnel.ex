defmodule Client.Tunnel do
  @moduledoc """
  链接通道
  """
  @remote '45.32.237.244'
  @port 8989
  @key "HelloWorld"
  @base_id "abc"

  use GenServer
  require Logger

  def start_link(args) do
    name = Keyword.get(args, :name, __MODULE__)
    GenServer.start_link(__MODULE__, args, name: name)
  end

  def recv() do
    socket = Client.SockStore.lookup(@base_id)
    {:ok, [data]} = :chumak.recv_multipart(socket)
    data
  end

  def decode_recv() do
    <<sid::size(16), data::binary>> =
      recv()
      |> Common.Crypto.aes_decrypt(@key, base64: false)
      |> Common.Compressor.decompress()

    {<<sid::size(16)>>, <<data::binary>>}
  end

  def send2(data) do
    GenServer.cast(__MODULE__, {:send, data})
  end

  def encode_send(sid, data) do
    (sid <> data)
    |> Common.Compressor.compress()
    |> Common.Crypto.aes_encrypt(@key, base64: false)
    |> send2()
  end

  #### callback

  def init(_args) do
    {:ok, socket} = :chumak.socket(:pair)
    {:ok, _} = :chumak.connect(socket, :tcp, @remote, @port)
    Process.send_after(self(), :register, 1000)
    {:ok, %{socket: socket}}
  end

  def handle_info(:register, state) do
    Client.SockStore.register(@base_id, state.socket)
    Logger.info("connection to #{@remote}:#{@port} established, recving")
    Client.Receiver.start_loop()
    {:noreply, state}
  end

  def handle_cast({:send, data}, state) do
    :ok = :chumak.send_multipart(state.socket, [data])
    {:noreply, state}
  end
end
