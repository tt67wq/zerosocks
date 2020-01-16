defmodule Common.Compressor do
  @moduledoc """
  压缩算法
  """

  def compress(data) do
    {:ok, compressed_data} = :snappy.compress(data)
    compressed_data
  end

  def decompress(compressed_data) do
    {:ok, data} = :snappy.decompress(compressed_data)
    data
  end
end
