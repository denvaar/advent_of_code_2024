defmodule Solution do
  def compact(n_blocks, freespaces, front_idx, back_idx, result \\ nil)

  def compact(n_blocks, _freeespaces, idx, idx, result) do
    IO.inspect(elem(n_blocks, idx))

    # n_blocks
    # |> Tuple.to_list()
    # |> Enum.reverse()
    # # |> Enum.reject(&(&1 == 0))
    # |> Enum.join()
    # |> IO.inspect(printable_limit: :infinity)

    if elem(n_blocks, idx) == 0 do
      result |> Enum.reverse()
    else
      0..(elem(n_blocks, idx) - 1)
      |> Enum.reduce(result, fn _, result -> [idx | result] end)
      |> Enum.reverse()
    end
  end

  def compact(n_blocks, freespaces, front_idx, back_idx, nil) do
    # first time
    result = update_result([], front_idx, elem(n_blocks, front_idx) - 1)
    n_blocks = put_elem(n_blocks, front_idx, 0)
    compact(n_blocks, freespaces, front_idx, back_idx, result)
  end

  def compact(n_blocks, [freesp | freespaces], front_idx, back_idx, result) do
    # IO.inspect(result)

    case freesp - elem(n_blocks, back_idx) do
      diff when diff > 0 ->
        # leftover freespace

        result =
          result
          |> update_result(front_idx, elem(n_blocks, front_idx) - 1)
          |> update_result(back_idx, elem(n_blocks, back_idx) - 1)

        n_blocks
        |> put_elem(front_idx, 0)
        |> put_elem(back_idx, 0)
        |> compact([diff | freespaces], front_idx, back_idx - 1, result)

      diff when diff < 0 ->
        # not enough freespace

        result =
          result
          |> update_result(front_idx, elem(n_blocks, front_idx) - 1)
          |> update_result(back_idx, elem(n_blocks, back_idx) - abs(diff) - 1)

        n_blocks
        |> put_elem(front_idx, 0)
        |> put_elem(back_idx, abs(diff))
        |> compact(freespaces, front_idx + 1, back_idx, result)

      0 ->
        result =
          result
          |> update_result(front_idx, elem(n_blocks, front_idx) - 1)
          |> update_result(back_idx, elem(n_blocks, back_idx) - 1)

        n_blocks
        |> put_elem(front_idx, 0)
        |> put_elem(back_idx, 0)
        |> compact(freespaces, front_idx + 1, back_idx - 1, result)
    end
  end

  def update_result(result, idx, 0) do
    [idx | result]
  end

  def update_result(result, idx, limit) do
    if limit > 0 do
      0..limit
      |> Enum.reduce(result, fn _, result -> [idx | result] end)
    else
      result
    end
  end

  def checksum(compacted) do
    compacted
    |> Enum.with_index()
    |> Enum.reduce(0, fn {file_id, idx}, total ->
      total + file_id * idx
    end)
  end
end

# "233313312141413140233"
# "12345"
# "2333133121414131402"
"../input.txt"
|> File.read!()
|> String.split("", trim: true)
|> Enum.reject(fn
  "\n" -> true
  _ -> false
end)
|> Enum.map(&String.to_integer/1)
|> Enum.chunk_every(2)
|> Enum.reduce({[], []}, fn
  [n_block], {n_blocks, freespaces} ->
    {[n_block | n_blocks], [0 | freespaces]}

  [n_block, freesp], {n_blocks, freespaces} ->
    {[n_block | n_blocks], [freesp | freespaces]}
end)
|> then(fn {n_blocks, freespaces} ->
  length = Enum.count(n_blocks)
  n_blocks = List.to_tuple(Enum.reverse(n_blocks))
  freespaces = Enum.reverse(freespaces)

  front_idx = 0
  back_idx = length - 1 - front_idx

  compacted = Solution.compact(n_blocks, freespaces, front_idx, back_idx)

  File.write!("/Users/denvaar/outp", Enum.join(compacted))

  Solution.checksum(compacted)
end)
|> IO.inspect()
