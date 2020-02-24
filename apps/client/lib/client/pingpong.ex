defmodule Client.PingPong do
  @moduledoc """
  doc
  """

  @pingpong_id "ping"
  @delta 10_000

  use GenServer
  require Logger

  def start_link(args) do
    name = Keyword.get(args, :name, __MODULE__)
    GenServer.start_link(__MODULE__, args, name: name)
  end

  def pong(), do: GenServer.cast(__MODULE__, :pong)

  def init(_args) do
    Process.send_after(self(), :ping, 10_000)
    {:ok, %{ts: 0}}
  end

  def handle_info(:ping, _state) do
    Client.Tunnel.encode_send(@pingpong_id, "ping")
    Process.send_after(self(), :ping, @delta)
    {:noreply, %{ts: timestamp(:milli_seconds)}}
  end

  def handle_cast(:pong, %{ts: 0}), do: {:noreply, %{ts: 0}}

  def handle_cast(:pong, %{ts: ts}) do
    Logger.info("pong! delay => #{timestamp(:milli_seconds) - ts}ms")
    {:noreply, %{ts: 0}}
  end

  defp timestamp(typ \\ :seconds), do: :os.system_time(typ)
end
