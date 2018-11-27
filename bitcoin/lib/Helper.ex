defmodule Helper do

  @moduledoc """
  contains common helper functions
  """

  @doc """
  facilitates piping
  """
  def hash(data, algorithm), do: :crypto.hash(algorithm, data)

  @doc """
  facilitates merkle parent calculation
  """
  def double_hash(data, algorithm) do
    data |> hash(algorithm) |> hash(algorithm)
  end

end
