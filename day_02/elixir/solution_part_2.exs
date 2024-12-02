defmodule Solution do
  def ascending?([first | levels]) do
    levels
    |> Enum.reduce_while({first, false}, fn n, {prev, _status} ->
      if prev - n > 0 and abs(n - prev) in [1, 2, 3] do
        {:cont, {n, true}}
      else
        {:halt, {n, false}}
      end
    end)
    |> then(fn {_, status} -> status end)
  end

  def descending?([first | diffs]) do
    diffs
    |> Enum.reduce_while({first, false}, fn n, {prev, _status} ->
      if prev - n < 0 and abs(n - prev) in [1, 2, 3] do
        {:cont, {n, true}}
      else
        {:halt, {n, false}}
      end
    end)
    |> then(fn {_, status} -> status end)
  end
end

"../input.txt"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.map(fn levels ->
  levels
  |> String.split(" ", trim: true)
  |> Enum.map(&String.to_integer(&1))
end)
|> Enum.reduce([], fn levels, acc ->
  if Solution.ascending?(levels) or Solution.descending?(levels) do
    [levels | acc]
  else
    one_step_away =
      levels
      |> List.duplicate(length(levels))
      |> Enum.with_index()
      |> Enum.map(fn {l, idx} -> List.delete_at(l, idx) end)
      |> Enum.filter(fn levels ->
        Solution.ascending?(levels) or Solution.descending?(levels)
      end)
      |> List.first()

    if is_nil(one_step_away) do
      acc
    else
      [one_step_away | acc]
    end
  end
end)
|> Enum.count()
|> IO.inspect()
