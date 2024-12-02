"../input.txt"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.reduce({[], []}, fn line, {acc_a, acc_b} ->
  [a, b] = String.split(line, " ", trim: true)
  a = String.to_integer(a)
  b = String.to_integer(b)

  {[a | acc_a], [b | acc_b]}
end)
|> then(fn {a, b} ->
  counts = b |> Enum.frequencies()

  Enum.reduce(a, 0, fn x, total ->
    total + x * Map.get(counts, x, 0)
  end)
end)
|> IO.inspect()
