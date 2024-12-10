defmodule Solution do
  def condense(n_blocks, freespaces, idx, max_idx, result \\ [])

  def condense(_n_blocks, _freespaces, idx, max_idx, result) when idx > max_idx do
    result
  end

  def condense(n_blocks, freespaces, idx, max_idx, result) do
    front = get_front(n_blocks, idx)

    n_blocks = put_elem(n_blocks, idx, {elem(n_blocks, idx), :used})

    n_spaces = elem(freespaces, idx)

    {n_blocks, spaces} = fill([], n_blocks, n_spaces, max_idx)

    condense(n_blocks, freespaces, idx + 1, max_idx, result ++ front ++ spaces)
  end

  defp get_front(n_blocks, idx) do
    case elem(n_blocks, idx) do
      {n, :used} -> List.duplicate(nil, n)
      n -> List.duplicate(idx, n)
    end
  end

  defp fill(spaces, n_blocks, 0, _idx), do: {n_blocks, spaces}

  defp fill(spaces, n_blocks, target, idx) when idx < 0 do
    {n_blocks, spaces ++ List.duplicate(nil, target)}
  end

  defp fill(spaces, n_blocks, target, idx) do
    case elem(n_blocks, idx) do
      {_b, :used} ->
        fill(spaces, n_blocks, target, idx - 1)

      b ->
        case target - b do
          diff when diff >= 0 ->
            spaces = spaces ++ List.duplicate(idx, b)
            n_blocks = put_elem(n_blocks, idx, {elem(n_blocks, idx), :used})
            fill(spaces, n_blocks, diff, idx - 1)

          diff when diff < 0 ->
            fill(spaces, n_blocks, target, idx - 1)
        end
    end
  end

  def checksum(compacted) do
    compacted
    |> Enum.with_index()
    |> Enum.reduce(0, fn
      {nil, _idx}, total -> total
      {file_id, idx}, total -> total + file_id * idx
    end)
  end
end

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

  n_blocks_rev = List.to_tuple(Enum.reverse(n_blocks))
  freespaces = List.to_tuple(Enum.reverse(freespaces))

  n_blocks_rev
  |> Solution.condense(freespaces, 0, length - 1)
  |> Solution.checksum()
end)
|> IO.inspect()
