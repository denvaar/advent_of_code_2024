"../input.txt"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.map(fn line ->
  line
  |> String.split(" ", trim: true)
  |> Enum.reduce_while({nil, nil, :unsafe}, fn n, {direction, prev, _status} ->
    cond do
      is_nil(direction) and is_nil(prev) ->
        {:cont, {nil, String.to_integer(n), :safe}}

      (prev - String.to_integer(n)) in [1, 2, 3] and
          direction in [nil, :dec] ->
        {:cont, {:dec, String.to_integer(n), :safe}}

      (prev - String.to_integer(n)) in [-1, -2, -3] and
          direction in [nil, :inc] ->
        {:cont, {:inc, String.to_integer(n), :safe}}

      true ->
        {:halt, {nil, nil, :unsafe}}
    end
  end)
  |> then(fn {_, _, result} -> result end)
end)
|> Enum.filter(&(&1 == :safe))
|> Enum.count()
|> IO.inspect()
