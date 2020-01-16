defmodule Server.SockStore do
  @moduledoc """
  链接仓库
  """

  def register(sid, socket) do
    Registry.register(__MODULE__, sid, socket)
  end

  def unregister(sid) do
    Registry.unregister(__MODULE__, sid)
  end

  def lookup(sid) do
    case Registry.lookup(__MODULE__, sid) do
      [] -> nil
      [{_, socket}] -> socket
    end
  end

end
