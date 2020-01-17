defmodule Common.Compressor do
  @moduledoc """
  压缩算法
  """
  require Logger

  def compress(data), do: :zlib.zip(data)
  def decompress(compressed_data), do: :zlib.unzip(compressed_data)
end
