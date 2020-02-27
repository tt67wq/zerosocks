defmodule Server.Tunnel do
  @moduledoc """
  通道
  """

  @port 8989
  @key "HelloWorld"
  @base_id "xyz"

  use GenServer
  require Logger

  def start_link(args) do
    name = Keyword.get(args, :name, __MODULE__)
    GenServer.start_link(__MODULE__, args, name: name)
  end

  def recv() do
    @base_id
    |> Server.SockStore.lookup()
    |> :chumak.recv_multipart()
    |> (fn
          {:ok, [data]} -> data
          _ -> :error
        end).()
  end

  def decode_recv() do
    recv()
    |> Common.Crypto.aes_decrypt(@key, base64: false)
    |> (fn
          <<sid::size(16), data::binary>> -> {<<sid::size(16)>>, <<data::binary>>}
          :error -> :error
        end).()
  end

  def send2(data) do
    GenServer.cast(__MODULE__, {:send, data})
  end

  def encode_send(sid, data) do
    sid
    |> Kernel.<>(data)
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
