defmodule Solution do
  def compact(s, len, len2 \\ 0)

  def compact(s, len, len2) do
    if done?(s) do
      s
    else
      <<head::binary-size(len), n::binary-size(1), last::binary-size(len2)>> = s

      s = head <> last <> "."

      [front, back] = String.split(s, ".", parts: 2)
      compact(front <> n <> back, len - 1, len2 + 1)
    end
  end

  def sum(s, idx \\ 0, total \\ 0)

  def sum(<<".", _::binary>>, _idx, total), do: total

  def sum(<<n::binary-size(1), s::binary>>, idx, total) do
    total =
      n
      |> String.to_integer()
      |> Kernel.*(idx)
      |> Kernel.+(total)

    sum(s, idx + 1, total)
  end

  defp done?(s) do
    [_front, back] = String.split(s, ".", parts: 2)

    back
    |> String.split("", trim: true)
    |> MapSet.new()
    |> MapSet.equal?(MapSet.new(["."]))
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
|> Enum.with_index()
|> Enum.reduce("", fn
  {[n_block], idx}, acc ->
    acc
    |> Kernel.<>(
      idx
      |> List.duplicate(n_block)
      |> Enum.join()
    )

  {[n_block, freesp], idx}, acc ->
    s1 =
      idx
      |> List.duplicate(n_block)
      |> Enum.join()

    s2 =
      "."
      |> List.duplicate(freesp)
      |> Enum.join()

    acc <> s1 <> s2
end)
|> then(fn s ->
  s
  |> Solution.compact(String.length(s) - 1)
  |> Solution.sum()
end)
|> IO.inspect()
