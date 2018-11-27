defmodule MerkleRoot do
  alias Helper, as: H
  @moduledoc """
  functionality for generating merkle root of a list of transactions
  """

  @doc """
  returns merkle root of raw transactions
  """
  def get_root(transactions) do

    if length(transactions) == 1 do
      [coinbase | _] = transactions
      coinbase |> H.double_hash(:sha256)
    else
      construct_tree(transactions, [])
    end
  end

  @doc """
  generates merkle parent(s) when there are numtiple children
  """
  def construct_tree([child1, child2 | children], parents) do
    child1_hash = child1 |> H.double_hash(:sha256)
    child2_hash = child2 |> H.double_hash(:sha256)

    parent = "#{child1_hash}#{child2_hash}" |> H.double_hash(:sha256)
    parents = parents ++ [parent]
    construct_tree(children, parents)
  end

  @doc """
  generates merkle parent when there is one child
  """
  def construct_tree([child], parents) do
    if length(parents) == 0 do
      child
    else
      child_hash = child |> H.double_hash(:sha256)
      parent = "#{child_hash}#{child_hash}" |> H.double_hash(:sha256)
      parents = parents ++ [parent]
      construct_tree(parents, [])
    end
  end

  @doc """
  generates merkle grandparent(s)
  """
  def construct_tree([], parents) do
    construct_tree(parents, [])
  end
end
